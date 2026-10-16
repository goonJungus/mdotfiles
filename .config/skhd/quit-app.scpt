tell application "System Events" to set frontApp to name of first application process whose frontmost is true
tell application frontApp to quit
