local tokens = require("theme.tokens")
local palette = require("theme.palette")
local metrics = require("theme.metrics")
local icons = require("theme.icons")
local ui = require("ui")

local SCRIPT = os.getenv("HOME") .. "/.config/sketchybar/helpers/caffeine.sh"

local item = ui.item("caffeine", {
    icon = {
        string = icons.coffee,
        color = tokens.fg.faint,
        padding_left = metrics.space.sm,
        padding_right = metrics.space.sm,
    },
    label = { drawing = false },
    update_freq = 30,
})

local function refresh()
    sbar.exec(SCRIPT .. " state", function(out)
        local on = tostring(out):match("on") ~= nil
        if on then
            item:set({
                background = { color = tokens.accent, corner_radius = metrics.radius.sm, height = metrics.height.pill },
                icon = { color = palette.base },
            })
        else
            item:set({
                background = { color = tokens.none },
                icon = { color = tokens.fg.faint },
            })
        end
    end)
end

item:subscribe("mouse.clicked", function()
    sbar.exec(SCRIPT .. " toggle", function()
        sbar.exec("sleep 0.3", refresh)
    end)
end)
item:subscribe({ "routine", "forced", "system_woke" }, refresh)
refresh()
