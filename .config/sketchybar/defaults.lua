local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")

local pad = metrics.space.xs + 1

sbar.default({
    updates = "when_shown",
    icon = {
        font = fonts.get("icon", "Bold", "lg"),
        color = tokens.fg.primary,
        padding_left = pad,
        padding_right = pad,
    },
    label = {
        font = fonts.get("text", "Semibold", "md"),
        color = tokens.fg.primary,
        padding_left = pad,
        padding_right = pad,
    },
    background = {
        height = metrics.height.group,
        corner_radius = metrics.radius.md,
        color = tokens.none,
    },
    popup = {
        background = {
            color = tokens.surface.popup,
            border_color = tokens.border.popup,
            border_width = metrics.popup.border_width,
            corner_radius = metrics.radius.md,
            shadow = { drawing = true },
        },
        blur_radius = metrics.popup.blur,
    },
    padding_left = pad,
    padding_right = pad,
    scroll_texts = true,
})
