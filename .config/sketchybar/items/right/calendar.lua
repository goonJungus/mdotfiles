local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")
local icons = require("theme.icons")
local ui = require("ui")

local function part(name, weight, size, props)
    props.font = fonts.get("text", weight, size)
    return ui.item("calendar." .. name, {
        icon = { drawing = false },
        label = props,
    })
end

-- Right side renders right-to-left
local date = part("date", "Regular", "md", {
    padding_right = metrics.space.md,
})
part("dot", "Regular", "md", {
    string = icons.dot,
    padding_left = metrics.space.xs,
    padding_right = metrics.space.xs,
})

local time = part("time", "SemiBold", "xl", {
    color = tokens.accent,
    padding_left = metrics.space.md,
})

local function update()
    time:set({ label = { string = os.date("%I:%M %p") } })
    date:set({ label = { string = os.date("%m/%d/%y") } })
end

time:set({ update_freq = 10 })
time:subscribe({ "routine", "forced", "system_woke" }, update)
update()
