local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local merge = require("lib.tbl").merge
local item = require("ui.item")

-- Thin vertical divider between items inside a group. The line is the
-- background of a 1pt-wide blank icon: an item's own background is not
-- drawn without content, and a fixed item width clips it.
return function(props)
    return item(merge({
        padding_left = metrics.space.sm,
        padding_right = metrics.space.sm,
        icon = {
            string = " ",
            width = 1,
            padding_left = 0,
            padding_right = 0,
            background = {
                drawing = true,
                color = tokens.border.divider,
                height = metrics.height.divider,
                corner_radius = 0,
            },
        },
        label = { drawing = false },
    }, props))
end
