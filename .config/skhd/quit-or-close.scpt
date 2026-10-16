-- mod+q: quit the frontmost app -- except Finder and muCommander, which close windows instead.
-- For those, closing the last window hides the app (stays warm in background).
tell application "System Events"
	set frontAppName to name of first application process whose frontmost is true
end tell

if frontAppName is "Finder" then
	tell application "Finder"
		if exists Finder window 1 then close Finder window 1
	end tell
else if frontAppName is "muCommander" then
	tell application "System Events"
		set muProc to first process whose name is "muCommander"
		set winCount to count every window of muProc
		-- Close the frontmost window
		keystroke "w" using command down
		delay 0.3
		-- If that was the last window, hide the app (Finder-like: warm, invisible)
		if winCount is 1 then
			set visible of muProc to false
		end if
	end tell
else
	tell application "System Events" to keystroke "q" using command down
end if
