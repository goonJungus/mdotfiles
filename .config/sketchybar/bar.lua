local tokens = require("theme.tokens")
local metrics = require("theme.metrics")

-- So I decided to give invisible bar a try, hehe
sbar.bar({
    position = "top",
    topmost = "window",
    sticky = true,
    height = metrics.height.bar,
    margin = metrics.bar.margin,
    y_offset = metrics.bar.y_offset,
    padding_left = metrics.bar.padding,
    padding_right = metrics.bar.padding,
    color = tokens.surface.bar,
    border_width = 0,
    shadow = false,
})
