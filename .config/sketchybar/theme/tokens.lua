-- Semantic color roles.
local p = require("theme.palette")
local alpha = require("lib.color").alpha

return {
    surface = {
        bar = p.transparent,
        group = p.black,
        item_active = p.accent,
        hover = alpha(p.text, 0.08),
        popup = alpha(p.base, 0.88),
    },
    border = {
        group = p.hl_high,
        popup = p.accent,
        divider = alpha(p.text, 0.2),
    },
    track = {
        fill = p.text,
        rest = alpha(p.text, 0.2),
    },
    fg = {
        primary = p.text,
        muted = p.subtle,
        faint = p.muted,
    },
    status = {
        ok = p.green,
        warn = p.gold,
        alert = p.orange,
        crit = p.love,
        info = p.pine,
    },
    accent = p.accent,
    none = p.transparent,
}
