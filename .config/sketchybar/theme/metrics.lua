-- Corners mode: the square alternate theme zeroes every radius.
-- State lives outside the repo; corners.sh writes it. Default = round.
local corners_square = false
do
    local f = io.open(os.getenv("HOME") .. "/.local/state/sketchybar-corners", "r")
    if f then
        local body = f:read("*a") or ""
        f:close()
        corners_square = body:match("square") ~= nil
    end
end

return {
    square = corners_square,
    space = { xs = 2, sm = 4, md = 8, lg = 12, xl = 16 },
    radius = { sm = corners_square and 0 or 6, md = corners_square and 0 or 9, pill = corners_square and 0 or 15 },
    height = { bar = 38, group = 30, pill = 24, divider = 14, track = 4 },

    bar = {
        margin = 10,
        y_offset = 0,
        padding = 0,
    },
    group = {
        blur = 20,
        border_width = 0,
        padding = 4, -- inner space between the pill edge and its first/last item
        gap = 4, -- space between neighbouring groups
    },
    meter = {
        width = 50, -- level track of volume / battery
    },
    popup = {
        blur = 20,
        border_width = 2,
    },
    motion = {
        curve = "tanh",
        fast = 8,
        slow = 20,
    },
}
