-- Bluetooth: icon in the bar; click opens a dropdown with toggle + devices.
local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local icons = require("theme.icons")
local ui = require("ui")

local dim = tokens.muted or tokens.subtext or tokens.text
local MAX_DEVICES = 8

local bt = ui.item("bluetooth", {
    popup = { align = "right" },
    icon = {
        color = tokens.accent,
        string = icons.bluetooth,
        padding_left = metrics.space.sm,
        padding_right = metrics.space.md,
    },
    label = { drawing = false },
})

local function hoverable(row)
    row:subscribe("mouse.entered", function()
        row:set({ background = { color = tokens.surface.hover } })
    end)
    row:subscribe("mouse.exited", function()
        row:set({ background = { color = tokens.none } })
    end)
end

local status_row = ui.popup.info(bt, "bluetooth.popup.status")

local toggle_row = ui.popup.row(bt, "bluetooth.popup.toggle", {
    icon = { string = icons.bluetooth },
    label = { string = "Turn Bluetooth Off" },
})
hoverable(toggle_row)

local dev_rows = {}
for i = 1, MAX_DEVICES do
    local r = ui.popup.row(bt, "bluetooth.popup.dev." .. i, {
        icon = { string = icons.bluetooth },
        label = { string = "" },
        drawing = false,
    })
    hoverable(r)
    dev_rows[i] = r
end

local popup_open = false
local blueutil = nil
local devices = {}

local function find_blueutil(cb)
    sbar.exec([[for b in $(command -v blueutil 2>/dev/null) /opt/homebrew/bin/blueutil /usr/local/bin/blueutil; do if [ -x "$b" ]; then echo "$b"; break; fi; done]], function(out)
        out = tostring(out):gsub("%s+$", "")
        cb(out ~= "" and out or nil)
    end)
end

local function alert(msg)
    msg = tostring(msg):gsub("[\r\n]+", " | "):gsub('"', "'")
    if #msg > 200 then msg = msg:sub(1, 200) .. "…" end
    sbar.exec("osascript -e 'display dialog \"" .. msg .. "\" buttons {\"OK\"} default button \"OK\"' 2>/dev/null")
end

local function update()
    if not blueutil then
        bt:set({ icon = { color = dim } })
        return
    end
    sbar.exec(blueutil .. " --power 2>/dev/null", function(out)
        local on = tostring(out):gsub("%s+$", "") == "1"
        bt:set({ icon = { color = on and tokens.accent or dim } })
    end)
end

local function paint_devices()
    for i, r in ipairs(dev_rows) do
        local d = devices[i]
        if d then
            r:set({
                drawing = true,
                label = { string = d.name .. (d.connected and " · connected" or "") },
            })
        else
            r:set({ drawing = false })
        end
    end
end

local function refresh_popup()
    if not blueutil then
        status_row:set({ label = { string = "blueutil not found — brew install blueutil" } })
        toggle_row:set({ label = { string = "Turn Bluetooth On" } })
        devices = {}
        paint_devices()
        return
    end
    sbar.exec(blueutil .. " --power 2>/dev/null", function(out)
        local on = tostring(out):gsub("%s+$", "") == "1"
        toggle_row:set({ label = { string = on and "Turn Bluetooth Off" or "Turn Bluetooth On" } })
        update()
        if not on then
            status_row:set({ label = { string = "Bluetooth is off" } })
            devices = {}
            paint_devices()
            return
        end
        sbar.exec(blueutil .. " --paired 2>/dev/null", function(o2)
            sbar.exec(blueutil .. " --connected 2>/dev/null", function(o3)
                local conn = {}
                for line in tostring(o3):gmatch("[^\n]+") do
                    local addr = line:match("^([^,]+)")
                    if addr then
                        addr = addr:gsub("%s+$", ""):lower()
                        conn[addr] = true
                    end
                end
                devices = {}
                local n = 0
                for line in tostring(o2):gmatch("[^\n]+") do
                    local addr, name = line:match("^([^,]+),%s*(.-)%s*$")
                    -- blueutil sometimes prints verbose info; prefer the quoted name.
                    local qname = line:match('name:%s*"([^"]+)"')
                    if qname then name = qname end
                    if addr and name then
                        name = name:gsub('^%s*"', ""):gsub('"%s*$', ""):gsub("^%s+", ""):gsub("%s+$", "")
                    end
                    if addr and name and name ~= "" then
                        addr = addr:gsub("%s+$", "")
                        n = n + 1
                        devices[n] = { addr = addr, name = name, connected = conn[addr:lower()] or false }
                    end
                    if n >= MAX_DEVICES then break end
                end
                local ccount = 0
                for _, d in ipairs(devices) do
                    if d.connected then ccount = ccount + 1 end
                end
                status_row:set({ label = { string = #devices == 0 and "No paired devices"
                    or (ccount .. " of " .. #devices .. " connected") } })
                paint_devices()
            end)
        end)
    end)
end

toggle_row:subscribe("mouse.clicked", function()
    if not blueutil then
        alert("Bluetooth toggle needs blueutil. Install it with: brew install blueutil")
        return
    end
    sbar.exec(blueutil .. " --power 2>/dev/null", function(out)
        local on = tostring(out):gsub("%s+$", "") == "1"
        sbar.exec(blueutil .. " --power " .. (on and "0" or "1") .. " 2>&1", function(o2)
            o2 = tostring(o2):gsub("^%s+", ""):gsub("%s+$", "")
            if o2 ~= "" and o2 ~= "0" and o2 ~= "1" then
                alert("blueutil: " .. o2)
            end
            refresh_popup()
        end)
    end)
end)

local function toggle_device(i)
    local d = devices[i]
    if not d or not blueutil then return end
    sbar.exec(blueutil .. (d.connected and " --disconnect " or " --connect ") .. d.addr .. " 2>&1", function()
        sbar.exec("sleep 1", function()
            refresh_popup()
        end)
    end)
end

for i, r in ipairs(dev_rows) do
    r:subscribe("mouse.clicked", function() toggle_device(i) end)
end

bt:subscribe("mouse.clicked", function()
    popup_open = not popup_open
    if popup_open then
        find_blueutil(function(path)
            blueutil = path
            refresh_popup()
        end)
    end
    ui.popup.toggle(bt)
end)
bt:subscribe("mouse.exited.global", function()
    popup_open = false
    ui.popup.close(bt)
end)

bt:subscribe("forced", update)
find_blueutil(function(path)
    blueutil = path
    update()
end)
