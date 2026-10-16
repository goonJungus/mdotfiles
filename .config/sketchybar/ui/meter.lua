local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local scope = require("ui.scope")
local item = require("ui.item")
local slider = require("ui.slider")

-- Icon followed by a level track (e.g. volume, battery).
local Meter = {}
Meter.__index = Meter

-- Update the glyph and/or level (0-100); nil leaves that part unchanged
function Meter:set(glyph, level)
    if glyph then
        self.icon:set({ icon = { string = glyph } })
    end
    if level then
        self.track:set({ slider = { percentage = level } })
    end
end

return function(name, glyph)
    local self = setmetatable({}, Meter)

    local function add_icon()
        self.icon = item(name .. ".icon", {
            icon = {
                color = tokens.accent,
                string = glyph,
                padding_left = metrics.space.sm,
                padding_right = metrics.space.sm,
            },
            label = { drawing = false },
        })
    end

    local function add_track()
        self.track = slider(name .. ".track", metrics.meter.width, {
            padding_right = metrics.space.md,
        })
    end

    -- i don't support left-side meter, do it yourself if you need to
    if scope.position == "right" then
        add_track()
        add_icon()
    end
    return self
end
