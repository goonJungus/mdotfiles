local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local merge = require("lib.tbl").merge

-- Translucent, blurred pill drawn behind a set of items
return function(name, members, overrides)
    return sbar.add("bracket", "group." .. name, members, merge({
        blur_radius = metrics.group.blur,
        background = {
            color = tokens.surface.group,
            corner_radius = metrics.radius.md,
            height = metrics.height.group,
            border_width = metrics.group.border_width,
            border_color = tokens.border.group,
        },
    }, overrides))
end
