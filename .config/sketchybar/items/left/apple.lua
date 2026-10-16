-- Apple logo with a full system menu (matches macOS Apple menu)
local metrics = require("theme.metrics")
local tokens = require("theme.tokens")
local icons = require("theme.icons")
local ui = require("ui")

local logo = ui.item("apple.logo", {
    icon = {
        string = "",
        color = tokens.accent,
    },
    label = { drawing = false },
    padding_left = metrics.space.md,
    padding_right = metrics.space.sm,
})

-- Thin horizontal divider inside the popup
local function divider(id)
    sbar.add("item", "apple.menu.div." .. id, {
        position = "popup." .. logo.name,
        icon = { drawing = false },
        label = { drawing = false },
        background = {
            drawing = true,
            color = tokens.border.divider,
            corner_radius = 0,
            height = 1,
        },
    })
end

-- { id, icon_key, label, command, badge? }
local entries = {
    { "sysinfo",  "sysinfo",  "System Information", "open -a 'System Information'" },
    { "settings", "settings", "System Settings...", "open -a 'System Settings'", badge = true },
    { "appstore", "appstore", "App Store...",       "open -a 'App Store'", badge = true },

    { "activity",  "activity",  "Activity Monitor", "open -a 'Activity Monitor'" },
    { "forcequit", "forcequit", "Force Quit Muse",  "pkill -9 -x Muse" },

    { "sleep",    "sleep",    "Sleep",     "pmset sleepnow" },
    { "restart",  "restart",  "Restart",   "osascript -e 'tell app \"System Events\" to restart'" },
    { "shutdown", "shutdown", "Shut Down", "osascript -e 'tell app \"System Events\" to shut down'" },

    { "lock",   "lock",   "Lock Screen",    "pmset displaysleepnow" },
    { "logout", "logout", "Log Out Jungus", "osascript -e 'tell app \"System Events\" to log out'" },
}

local badge_rows, badge_bases = {}, {}

for _, e in ipairs(entries) do
    if type(e) == "string" then
        divider(e)
    else
        local id, glyph, text, cmd = e[1], e[2], e[3], e[4]
        local row = ui.popup.row(logo, "apple.menu." .. id, {
            icon = { string = icons[glyph] or "" },
            label = { string = text },
        }, cmd)
        if e.badge then
            badge_rows[id] = row
            badge_bases[id] = text
        end
    end
end

-- Async update count -> "N update(s)" suffix on Settings + App Store
sbar.exec("softwareupdate -l 2>/dev/null | grep -c '^\\* Label:'", function(count)
    local n = tonumber(count) or 0
    if n > 0 then
        local suffix = n == 1 and "  (1 update)" or ("  (" .. n .. " updates)")
        for id, row in pairs(badge_rows) do
            row:set({ label = { string = badge_bases[id] .. suffix } })
        end
    end
end)

ui.popup.attach(logo)
