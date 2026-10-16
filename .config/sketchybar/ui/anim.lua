local motion = require("theme.metrics").motion

-- ui.anim("fast", function() item:set(...) end)
return function(speed, fn)
    sbar.animate(motion.curve, motion[speed] or speed, fn)
end
