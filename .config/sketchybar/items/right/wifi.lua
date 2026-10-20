-- Wi-Fi: SSID in the bar; click opens a dropdown with toggle + nearby networks.
local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")
local icons = require("theme.icons")
local ui = require("ui")

local IFACE = "en0"
local SCAN = os.getenv("HOME") .. "/.config/sketchybar/helpers/WifiScan.app/Contents/MacOS/wifiscan"
local MAX_NETWORKS = 8

local wifi = ui.item("wifi", {
    popup = { align = "right" },
    icon = {
        color = tokens.accent,
        string = icons.wifi.off,
        padding_left = metrics.space.sm,
        padding_right = metrics.space.sm,
    },
    label = {
        font = fonts.get("numeric", "Regular", "md"),
        padding_right = metrics.space.sm,
    },
})

local function hoverable(row)
    row:subscribe("mouse.entered", function()
        row:set({ background = { color = tokens.surface.hover } })
    end)
    row:subscribe("mouse.exited", function()
        row:set({ background = { color = tokens.none } })
    end)
end

local status_row = ui.popup.info(wifi, "wifi.popup.status")

local toggle_row = ui.popup.row(wifi, "wifi.popup.toggle", {
    icon = { string = icons.wifi.off },
    label = { string = "Turn Wi-Fi On" },
})
hoverable(toggle_row)

local net_rows = {}
for i = 1, MAX_NETWORKS do
    local r = ui.popup.row(wifi, "wifi.popup.net." .. i, {
        icon = { string = icons.lock },
        label = { string = "" },
        drawing = false,
    })
    hoverable(r)
    net_rows[i] = r
end

local popup_open = false
local networks = {}

local function sh_quote(s)
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- Single source of truth for wifi state (bar item and popup share it).
local SSID_HELPER = os.getenv("HOME") .. "/.config/sketchybar/helpers/wifi-ssid"

local function get_status(cb)
    local cmd = "ifconfig " .. IFACE .. " | awk '/status:/{print $2}'; ipconfig getifaddr " .. IFACE .. "; " .. SSID_HELPER .. " 2>/dev/null"
    sbar.exec(cmd, function(out)
        local lines = {}
        for line in tostring(out):gmatch("[^\n]+") do
            lines[#lines + 1] = line
        end
        local connected = lines[1] == "active" and lines[2] ~= nil and lines[2] ~= ""
        local ssid = (lines[3] or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if ssid == "<redacted>" then ssid = "" end
        cb(connected, ssid)
    end)
end

local function update()
    get_status(function(connected, ssid)
        wifi:set({
            icon = { string = connected and icons.wifi.on or icons.wifi.off },
            label = { string = ssid, drawing = connected and ssid ~= "" },
        })
    end)
end

local function paint_networks()
    for i, r in ipairs(net_rows) do
        local n = networks[i]
        if n then
            r:set({
                drawing = true,
                icon = { string = n.secured and icons.lock or icons.dot, drawing = true },
                label = { string = n.ssid },
            })
        else
            r:set({ drawing = false })
        end
    end
end

local function scan()
    sbar.exec(SCAN .. " 2>/dev/null", function(out)
        networks = {}
        local seen = {}
        for line in tostring(out):gmatch("[^\n]+") do
            local ssid = line:match("^(.-)%s+%x%x:%x%x:%x%x:%x%x:%x%x:%x%x%s+-%d+")
            local sec = line:match("%x%x:%x%x:%x%x:%x%x:%x%x:%x%x%s+-%d+%s+%S+%s+%S+%s+%S+%s*(.*)$")
            if ssid and not seen[ssid] then
                seen[ssid] = true
                sec = (sec or ""):gsub("%s+$", "")
                networks[#networks + 1] = {
                    ssid = ssid,
                    secured = sec ~= "" and sec:upper() ~= "NONE",
                }
            end
            if #networks >= MAX_NETWORKS then break end
        end
        if #networks == 0 then
            sbar.exec("networksetup -listpreferredwirelessnetworks " .. IFACE .. " 2>/dev/null", function(o2)
                local first = true
                for line in tostring(o2):gmatch("[^\n]+") do
                    if first then first = false
                    else
                        local ssid = line:gsub("^%s+", ""):gsub("%s+$", "")
                        if ssid ~= "" and not seen[ssid] then
                            seen[ssid] = true
                            networks[#networks + 1] = { ssid = ssid, secured = true }
                        end
                    end
                    if #networks >= MAX_NETWORKS then break end
                end
                paint_networks()
            end)
        else
            paint_networks()
        end
    end)
end

local function refresh_popup()
    sbar.exec("networksetup -getairportpower " .. IFACE .. " 2>/dev/null", function(out)
        local on = tostring(out):match(":%s*On") ~= nil
        toggle_row:set({
            icon = { string = on and icons.wifi.on or icons.wifi.off },
            label = { string = on and "Turn Wi-Fi Off" or "Turn Wi-Fi On" },
        })
        if not on then
            status_row:set({ label = { string = "Wi-Fi is off" } })
            networks = {}
            paint_networks()
            return
        end
        get_status(function(connected, ssid)
            status_row:set({ label = { string = connected and (ssid ~= "" and ("Connected to " .. ssid) or "Connected") or "Not connected" } })
        end)
        scan()
    end)
end

toggle_row:subscribe("mouse.clicked", function()
    sbar.exec("networksetup -getairportpower " .. IFACE .. " 2>/dev/null", function(out)
        local on = tostring(out):match(":%s*On") ~= nil
        sbar.exec("networksetup -setairportpower " .. IFACE .. " " .. (on and "off" or "on"), function()
            update()
            refresh_popup()
        end)
    end)
end)

local function join(i)
    local n = networks[i]
    if not n then return end
    local function do_join(pw)
        local cmd = "networksetup -setairportnetwork " .. IFACE .. " " .. sh_quote(n.ssid)
        if pw then cmd = cmd .. " " .. sh_quote(pw) end
        sbar.exec(cmd, function()
            popup_open = false
            ui.popup.close(wifi)
            update()
        end)
    end
    if n.secured then
        local safe = n.ssid:gsub('"', '')
        local dlg = "osascript -e 'display dialog \"Password for \\\"" .. safe .. "\\\":\" default answer \"\" with hidden answer buttons {\"Cancel\", \"Join\"} default button \"Join\"' -e 'text returned of result' 2>/dev/null"
        sbar.exec(dlg, function(pw)
            pw = tostring(pw):gsub("[\r\n]+$", "")
            if pw ~= "" then do_join(pw) end
        end)
    else
        do_join(nil)
    end
end

for i, r in ipairs(net_rows) do
    r:subscribe("mouse.clicked", function() join(i) end)
end

wifi:subscribe("mouse.clicked", function()
    popup_open = not popup_open
    if popup_open then refresh_popup() end
    ui.popup.toggle(wifi)
end)
wifi:subscribe("mouse.exited.global", function()
    popup_open = false
    ui.popup.close(wifi)
end)

wifi:subscribe({ "wifi_change", "system_woke", "forced" }, update)
update()
