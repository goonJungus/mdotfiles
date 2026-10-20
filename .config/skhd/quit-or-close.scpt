-- mod+q: quit the frontmost app -- except Finder, which closes windows instead.
tell application "System Events"
	set frontAppName to name of first application process whose frontmost is true
end tell

if frontAppName is "Finder" then
	tell application "Finder"
		if exists Finder window 1 then close Finder window 1
	end tell
else
	tell application "System Events" to keystroke "q" using command down
end if
