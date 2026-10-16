local watcher = require("lib.watcher")

local M = {}

M.event = "media_changed"

local STATE = "/tmp/sketchybar_media_state.json"
local STREAM = [[sh -c 'while :; do ]]
    .. [[media-control stream --no-artwork --no-diff --debounce=150 ]]
    .. [[| while IFS= read -r line; do ]]
    .. [[printf "%s\n" "$line" > ]] .. STATE .. [[.tmp && mv ]] .. STATE .. [[.tmp ]] .. STATE .. [[; ]]
    .. [[sketchybar --trigger ]] .. M.event .. [[; ]]
    .. [[done; sleep 2; done']]

M.cmd = {
    toggle = "media-control toggle-play-pause",
}

function M.start()
    sbar.add("event", M.event)
    os.remove(STATE) -- the stream writes a fresh snapshot right away
    watcher.start("/tmp/sketchybar_media_stream.pid", STREAM, "media-control stream")
end

-- cb(info) with info = { id, title, artist, playing }, or nil when nothing is loaded
function M.query(cb)
    sbar.exec("cat " .. STATE .. " 2>/dev/null", function(out)
        local now = type(out) == "table" and out.payload
        if type(now) ~= "table" or not now.title then
            return cb(nil)
        end
        cb({
            id = tostring(now.contentItemIdentifier or now.title),
            title = now.title,
            artist = now.artist or "",
            playing = now.playing == true,
        })
    end)
end

return M
