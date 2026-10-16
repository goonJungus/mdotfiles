local M = {}

-- Deep-merge `over` onto a copy of `base`. Keep inputs immutable.
function M.merge(base, over)
    local out = {}
    for k, v in pairs(base or {}) do
        out[k] = type(v) == "table" and M.merge(v) or v
    end
    for k, v in pairs(over or {}) do
        if type(v) == "table" and type(out[k]) == "table" then
            out[k] = M.merge(out[k], v)
        else
            out[k] = v
        end
    end
    return out
end

return M
