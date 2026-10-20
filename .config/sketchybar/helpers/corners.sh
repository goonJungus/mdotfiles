#!/bin/bash
# Alternate square-corners theme for the Mac bar + kitty.
# Usage: corners.sh [square|round]  (no arg prints the current mode)
STATE="$HOME/.local/state/sketchybar-corners"
KITTY="$HOME/mdotfiles/.config/kitty/kitty.conf"
mkdir -p "$(dirname "$STATE")"
case "$1" in
  square)
    printf 'square' > "$STATE"
    sed -i '' 's/^hide_window_decorations.*/hide_window_decorations titlebar-and-corners/' "$KITTY"
    sketchybar --reload
    echo 'square corners ON (kitty follows on its next launch)' ;;
  round)
    printf 'round' > "$STATE"
    sed -i '' 's/^hide_window_decorations.*/hide_window_decorations titlebar-only/' "$KITTY"
    sketchybar --reload
    echo 'round corners restored (kitty follows on its next launch)' ;;
  *) cat "$STATE" 2>/dev/null || echo round ;;
esac
