local scope = require("ui.scope")

-- sbar.add("item") wrapper.
-- Usage: ui.item("name", props) or ui.item(props) for an anonymous item.
return function(name, props)
    if type(name) == "table" then
        name, props = nil, name
    end
    props = props or {}
    props.position = props.position or scope.position

    local item = name and sbar.add("item", name, props) or sbar.add("item", props)
    if not props.position:find("^popup%.") then
        scope.add(item.name)
    end
    return item
end
