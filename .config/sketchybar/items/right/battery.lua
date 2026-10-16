-- Battery icon + percentage; click opens dropdown with charge rate + Low Power toggle.
local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")
local icons = require("theme.icons")
local ui = require("ui")

local battery = ui.item("battery", {
    popup = { align = "right" },
    icon = {
        color = tokens.accent,
        string = icons.battery.empty,
        padding_left = metrics.space.sm,
        padding_right = metrics.space.sm,
    },
    label = {
        font = fonts.get("numeric", "Regular", "md"),
        padding_right = metrics.space.sm,
    },
    update_freq = 120,
})

local function hoverable(row)
    row:subscribe("mouse.entered", function()
        row:set({ background = { color = tokens.surface.hover } })
    end)
    row:subscribe("mouse.exited", function()
        row:set({ background = { color = tokens.none } })
    end)
end

local status_row = ui.popup.info(battery, "battery.popup.status")
local time_row = ui.popup.info(battery, "battery.popup.time")

local lowpower_row = ui.popup.row(battery, "battery.popup.lowpower", {
    icon = { string = icons.battery.empty },
    label = { string = "Low Power Mode" },
})
hoverable(lowpower_row)

local popup_open = false
local lowpower_supported = nil  -- nil = unknown, probe on first open
local lowpower_on = false

local function glyph(pct, on_ac)
    if on_ac then
        return icons.battery.charging
    end
    return icons.battery.levels[math.ceil(pct / 10)] or icons.battery.empty
end

local function update()
    sbar.exec("pmset -g batt", function(out)
        local pct = tonumber(out:match("(%d+)%%"))
        if not pct then
            battery:set({ drawing = false })
            return
        end
        battery:set({
            drawing = true,
            icon = { string = glyph(pct, out:find("AC Power") ~= nil) },
            label = { string = pct .. "%" },
        })
    end)
end

local function refresh_lowpower()
    if lowpower_supported == false then
        lowpower_row:set({ label = { string = "Low Power: use System Settings" } })
        return
    end
    -- Probe pmset for low power mode support (macOS 12+ on some Macs).
    sbar.exec("pmset -g 2>/dev/null | grep -i lowpower", function(out)
        out = tostring(out):gsub("%s+$", "")
        if out == "" then
            lowpower_supported = false
            lowpower_row:set({ label = { string = "Low Power: use System Settings" } })
            return
        end
        lowpower_supported = true
        -- Parse state: look for "lowpowermode" followed by 1 (not just any "1").
        lowpower_on = out:match("lowpowermode%s+1") ~= nil
        lowpower_row:set({
            label = { string = lowpower_on and "Turn Low Power Off" or "Turn Low Power On" },
        })
        -- Yellow battery icon when Low Power is ON, purple accent when OFF.
        battery:set({
            icon = { color = lowpower_on and 0xffffcc00 or tokens.accent },
        })
    end)
end

local function refresh_popup()
    sbar.exec("pmset -g batt 2>/dev/null", function(out)
        local pct = tonumber(out:match("(%d+)%%"))
        if not pct then
            status_row:set({ label = { string = "No battery" } })
            time_row:set({ label = { string = "" } })
            return
        end
        local charging = out:find("charging") ~= nil and out:find("discharging") == nil
        local discharging = out:find("discharging") ~= nil
        local status
        if charging then
            status = pct .. "% · Charging"
        elseif discharging then
            status = pct .. "% · On battery"
        else
            status = pct .. "% · Charged"
        end
        status_row:set({ label = { string = status } })
        -- Time estimate from live amperage.
        -- Note: Amperage is an unsigned 64-bit int; negative values (discharging)
        -- appear as 2^64 - x. Convert via string math to avoid float precision loss.
        sbar.exec([[ioreg -rn AppleSmartBattery 2>/dev/null | grep -E '"(Amperage|AppleRawCurrentCapacity|AppleRawMaxCapacity|TimeRemaining)"']], function(o2)
            local o2s = tostring(o2)
            local function signed64(s)
                if not s then return nil end
                s = s:gsub("%s+", "")
                -- Unsigned 64-bit >= 2^63 is a negative signed value (discharging).
                -- 2^63 = 9223372036854775808 (19 digits).
                local is_neg = #s > 19 or (#s == 19 and s >= "9223372036854775808")
                if is_neg then
                    -- Compute -(2^64 - s) via string subtraction.
                    local a = "18446744073709551616" -- 2^64
                    s = string.rep("0", 20 - #s) .. s
                    local borrow, digits = 0, {}
                    for i = 20, 1, -1 do
                        local d = tonumber(a:sub(i, i)) - tonumber(s:sub(i, i)) - borrow
                        if d < 0 then d, borrow = d + 10, 1 else borrow = 0 end
                        table.insert(digits, 1, tostring(d))
                    end
                    local mag_str = table.concat(digits):gsub("^0+", "")
                    return -(tonumber(mag_str ~= "" and mag_str or "0") or 0)
                end
                return tonumber(s)
            end
            local amp = signed64(o2s:match('"Amperage"%s*=%s*(%d+)'))
            local cur = tonumber(o2s:match('"AppleRawCurrentCapacity"%s*=%s*(%d+)'))
            local maxcap = tonumber(o2s:match('"AppleRawMaxCapacity"%s*=%s*(%d+)'))
            local label = ""
            if amp and cur and maxcap and amp ~= 0 and maxcap > 0 then
                local rate = math.abs(amp)
                local hours, fmt
                -- Direction from pmset (matches the status row); magnitude from amperage.
                if charging then
                    hours = (maxcap - cur) / rate
                    fmt = "%d:%02d until full"
                elseif discharging then
                    hours = cur / rate
                    fmt = "%d:%02d hours left"
                end
                if hours and hours >= 0 and hours < 100 then
                    local h = math.floor(hours)
                    local m = math.floor((hours - h) * 60 + 0.5)
                    if m == 60 then h, m = h + 1, 0 end
                    label = string.format(fmt, h, m)
                end
            end
            time_row:set({ label = { string = label } })
        end)
        update()
    end)
    refresh_lowpower()
end

lowpower_row:subscribe("mouse.clicked", function()
    if not lowpower_supported then
        return
    end
    local target = lowpower_on and "0" or "1"
    -- Use sudo (Touch ID via pam_tid.so, configured by user).
    sbar.exec("sudo -n pmset -a lowpowermode " .. target .. " 2>&1 || sudo pmset -a lowpowermode " .. target .. " 2>&1", function(out)
        -- Refresh after a moment to let the setting apply.
        sbar.exec("sleep 1", function()
            refresh_lowpower()
        end)
    end)
end)

battery:subscribe("mouse.clicked", function()
    popup_open = not popup_open
    if popup_open then
        refresh_popup()
    end
    ui.popup.toggle(battery)
end)
battery:subscribe("mouse.exited.global", function()
    popup_open = false
    ui.popup.close(battery)
end)

battery:subscribe({ "routine", "power_source_change", "system_woke", "forced" }, update)
update()
refresh_lowpower() -- Set initial icon color based on Low Power state.