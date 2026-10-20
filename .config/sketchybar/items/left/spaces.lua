-- Ten fixed workspace slots: active is highlighted, occupied is dimly lit,
-- empty is plain text.
local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")
local ui = require("ui")
local wm = require("lib.wm.omniwm")

local COUNT = 5

local STYLE = {
    active = { bg = tokens.surface.item_active, fg = tokens.fg.primary },
    occupied = { bg = tokens.none, fg = tokens.fg.primary },
    empty = { bg = tokens.none, fg = tokens.fg.faint },
}

-- slots[i] = { item = <sbar item>, state = "active" | "occupied" | "empty" }
local slots = {}

for i = 1, COUNT do
    local name = tostring(i)
    slots[i] = {
        state = "empty",
        item = ui.item("space." .. name, {
            padding_left = metrics.space.xs,
            padding_right = metrics.space.xs,
            icon = {
                string = name,
                font = fonts.get("numeric", "Bold", "md"),
                color = STYLE.empty.fg,
                width = metrics.height.pill,
                align = "center",
                padding_left = 0,
                padding_right = 0,
            },
            label = { drawing = false },
            background = {
                color = STYLE.empty.bg,
                height = metrics.height.pill,
                corner_radius = metrics.square and 0 or metrics.height.pill // 2,
            },
            click_script = wm.focus_cmd(name),
        }),
    }
end

local function apply(state)
    -- An empty result means the WM is unreachable; keep what we have
    if next(state) == nil then
        return
    end

    local changed = {}
    for i, slot in ipairs(slots) do
        local ws = state[tostring(i)]
        local key = ws and (ws.focused and "active" or (ws.occupied and "occupied" or "empty")) or "empty"
        if key ~= slot.state then
            slot.state = key
            changed[#changed + 1] = slot
        end
    end

    if #changed > 0 then
        ui.anim("fast", function()
            for _, slot in ipairs(changed) do
                local style = STYLE[slot.state]
                slot.item:set({ icon = { color = style.fg }, background = { color = style.bg } })
            end
        end)
    end
end

-- Queries are async; coalesce events that arrive mid-query into one rerun
local in_flight, pending = false, false

local function refresh()
    if in_flight then
        pending = true
        return
    end
    in_flight = true
    wm.query(function(state)
        apply(state)
        in_flight = false
        if pending then
            pending = false
            refresh()
        end
    end)
end

wm.start()
slots[1].item:subscribe({ wm.event, "system_woke", "forced" }, refresh)
refresh()
