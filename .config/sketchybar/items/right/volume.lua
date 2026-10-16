-- Volume icon and level track
local icons = require("theme.icons")
local ui = require("ui")

local meter = ui.meter("volume", icons.volume.high)

local function glyph(v)
    if v == 0 then
        return icons.volume.off
    elseif v > 60 then
        return icons.volume.high
    elseif v > 30 then
        return icons.volume.medium
    end
    return icons.volume.low
end

local function apply(v)
    meter:set(glyph(v), v)
end

meter.track:subscribe("volume_change", function(env)
    local v = tonumber(env.INFO)
    if v then
        apply(v)
    end
end)

meter.track:subscribe("mouse.clicked", function(env)
    sbar.exec("osascript -e 'set volume output volume " .. env.PERCENTAGE .. "'")
end)

-- volume_change only fires on change; seed the current level
sbar.exec("osascript -e 'output volume of (get volume settings)'", function(out)
    local v = tonumber(out)
    if v then
        apply(v)
    end
end)
