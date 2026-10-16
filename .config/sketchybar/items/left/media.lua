local tokens = require("theme.tokens")
local metrics = require("theme.metrics")
local fonts = require("theme.fonts")
local icons = require("theme.icons")
local ui = require("ui")
local media = require("lib.media")

local state = ui.item("media.state", {
    icon = {
        string = icons.media.play,
        color = tokens.accent,
        padding_left = metrics.space.sm,
        padding_right = metrics.space.xs,
    },
    label = { drawing = false },
})

local track = ui.item("media.track", {
    icon = { drawing = false },
    label = {
        font = fonts.get("text", "Regular", "md"),
        max_chars = 36,
        padding_right = metrics.space.sm,
    },
})

local is_playing = false
local current_id

local function set_playing(playing)
    is_playing = playing
    state:set({ icon = { string = playing and icons.media.pause or icons.media.play } })
    track:set({ label = { color = playing and tokens.fg.primary or tokens.fg.muted } })
end

local function render(info)
    if not info then
        current_id = nil
        set_playing(false)
        track:set({ label = { string = "listening to the silence..." } })
        return
    end

    set_playing(info.playing)

    if info.id ~= current_id then
        current_id = info.id
        local line = info.artist ~= "" and (info.title .. "  " .. icons.dot .. "  " .. info.artist) or info.title
        track:set({ label = { string = line } })
    end
end

local function refresh()
    media.query(render)
end

-- Flip the glyph right away; the stream confirms a moment later
state:subscribe("mouse.clicked", function()
    set_playing(not is_playing)
    sbar.exec(media.cmd.toggle)
end)

media.start()
track:subscribe({ media.event, "forced", "system_woke" }, refresh)
refresh()
