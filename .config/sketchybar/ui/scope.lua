-- Tracks the group currently being mounted by ui.layout, so items can
-- inherit its bar position and join its bracket without naming it.
local M = { position = nil, members = nil }

function M.open(position)
    M.position = position
    M.members = {}
end

function M.add(name)
    if M.members then
        M.members[#M.members + 1] = name
    end
end

function M.close()
    local members = M.members
    M.position, M.members = nil, nil
    return members
end

return M
