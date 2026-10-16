local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local merge = require("lib.tbl").merge
local scope = require("ui.scope")

-- Thin knobless track that joins the current group, like ui.item
return function(name, width, props)
    props = merge({
        position = scope.position,
        padding_left = 0,
        padding_right = 0,
        icon = { drawing = false },
        label = { drawing = false },
        slider = {
            highlight_color = tokens.track.fill,
            knob = { drawing = false },
            background = {
                color = tokens.track.rest,
                height = metrics.height.track,
                corner_radius = metrics.height.track // 2,
            },
        },
    }, props)

    local slider = sbar.add("slider", name, width, props)
    scope.add(slider.name)
    return slider
end
