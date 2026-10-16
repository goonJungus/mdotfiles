-- Invisible fixed-width item. Not part of any bracket unless `join` is set.
local scope = require("ui.scope")

return function(position, width, join)
    local item = sbar.add("item", {
        position = position,
        width = width,
        padding_left = 0,
        padding_right = 0,
        icon = { drawing = false },
        label = { drawing = false },
        background = { drawing = false },
    })
    if join then
        scope.add(item.name)
    end
    return item
end
