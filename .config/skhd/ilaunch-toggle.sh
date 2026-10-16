#!/bin/bash
if pgrep -x "iLaunch" > /dev/null; then
    VISIBLE=$(osascript -e "tell application \"System Events\" to get visible of process \"iLaunch\"" 2>/dev/null)
    if [ "$VISIBLE" = "true" ]; then
        osascript -e "tell application \"System Events\" to set visible of process \"iLaunch\" to false"
    else
        open -a iLaunch.app
    fi
else
    open -a iLaunch.app
fi
