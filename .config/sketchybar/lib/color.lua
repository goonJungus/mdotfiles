local M = {}

-- Replace the alpha channel of a 0xAARRGGBB color; alpha is 0.0-1.0
function M.alpha(color, a)
    if a > 1.0 or a < 0.0 then
        return color
    end
    return (color & 0x00ffffff) | (math.floor(a * 255.0) << 24)
end

return M
