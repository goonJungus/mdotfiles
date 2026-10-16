sbar = require("sketchybar")

-- Bundle the entire configs into a single message to sketchybar
sbar.begin_config()
require("bar")
require("defaults")
require("layout")
sbar.end_config()

sbar.event_loop()
