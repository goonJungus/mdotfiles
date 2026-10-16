local metrics = require("theme.metrics")
local scope = require("ui.scope")
local spacer = require("ui.spacer")
local group = require("ui.group")

-- Mount one side of the bar. Each group is { name = "...", items = { ... } }.
return function(position, groups)
    for i, g in ipairs(groups) do
        if i > 1 then
            spacer(position, metrics.group.gap)
        end

        scope.open(position)
        spacer(position, metrics.group.padding, true)
        for _, entry in ipairs(g.items) do
            if type(entry) == "function" then
                entry()
            else
                require(entry)
            end
        end
        spacer(position, metrics.group.padding, true)
        group(g.name, scope.close(), g.style)
    end
end
