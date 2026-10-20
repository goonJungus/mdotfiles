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

-- Calendar popup: month grid anchored on the time item. Left-click toggles,
-- right-click opens Calendar.app. Today is bracketed to keep the grid aligned.
time:set({ popup = { align = "right" } })

local MONO = "SpaceMono Nerd Font:Regular:12.0"
local function grid_row(name, color)
    return ui.popup.row(time, name, {
        icon = { drawing = false },
        label = { font = MONO, color = color, padding_left = metrics.space.md, padding_right = metrics.space.md },
    })
end

local cal_title = ui.popup.row(time, "calendar.popup.title", {
    icon = { drawing = false },
    label = { color = tokens.accent, padding_left = metrics.space.md },
})
local cal_head = grid_row("calendar.popup.head", tokens.fg.muted)
local cal_rows = {}
for i = 1, 6 do cal_rows[i] = grid_row("calendar.popup.week." .. i) end
ui.popup.row(time, "calendar.popup.open", {
    icon = { drawing = false },
    label = { string = "Open Calendar", padding_left = metrics.space.md },
}, "open -a Calendar")

local function refresh_cal()
    local now = os.date("*t")
    local first = os.date("*t", os.time({ year = now.year, month = now.month, day = 1 }))
    local dim = os.date("*t", os.time({ year = now.year, month = now.month + 1, day = 0 })).day
    local cells = {}
    for _ = 1, first.wday - 1 do cells[#cells + 1] = "    " end
    for d = 1, dim do
        if d == now.day then cells[#cells + 1] = string.format("[%2d]", d)
        else cells[#cells + 1] = string.format("%3d ", d) end
    end
    while #cells % 7 ~= 0 do cells[#cells + 1] = "    " end
    if cells[1] == "    " then cells[1] = "   ·" end
    cal_title:set({ label = { string = os.date("%B %Y") } })
    local head = ""
    for _, d in ipairs({ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }) do
        head = head .. string.format("%3s ", d)
    end
    cal_head:set({ label = { string = head } })
    for i, row in ipairs(cal_rows) do
        local s = ""
        for c = (i - 1) * 7 + 1, i * 7 do s = s .. (cells[c] or "    ") end
        s = s .. "  "
        row:set({ label = { string = s } })
    end
end

local cal_open_state = false
local function on_click(env)
    if env.BUTTON == "right" then
        sbar.exec("open -a Calendar")
        return
    end
    cal_open_state = not cal_open_state
    if cal_open_state then refresh_cal() end
    ui.popup.toggle(time)
end
time:subscribe("mouse.clicked", on_click)
date:subscribe("mouse.clicked", on_click)
time:subscribe("mouse.exited.global", function()
    cal_open_state = false
    ui.popup.close(time)
end)
refresh_cal()
