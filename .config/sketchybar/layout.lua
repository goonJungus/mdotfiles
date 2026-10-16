-- Item order and groups for each side of the bar.
-- Right-side items render right-to-left, so they are listed outermost first.
local ui = require("ui")
local layout = ui.layout

layout("left", {
    { name = "workspaces", items = { "items.left.apple", ui.separator, "items.left.spaces" } },
    { name = "front_app", items = { "items.left.front_app" } },
    { name = "media", items = { "items.left.media" } },
})

layout("right", {
    { name = "bluetooth", items = { "items.right.bluetooth" } },
    { name = "clock", items = { "items.right.calendar" } },
    { name = "battery", items = { "items.right.battery" } },
    { name = "volume", items = { "items.right.volume" } },
    { name = "wifi", items = { "items.right.wifi" } },
})
