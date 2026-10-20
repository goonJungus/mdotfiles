#!/bin/bash
# Battery-pill caffeine toggle: drives OmniWM's Keep Awake setting
# (preventSleepEnabled in [general] of ~/.config/omniwm/settings.toml).
# OmniWM live-reloads the file and holds/releases its own
# PreventUserIdleDisplaySleep assertion ("OmniWM prevents sleep").
SETTINGS="$HOME/.config/omniwm/settings.toml"
is_on() { grep -q '^preventSleepEnabled = true' "$SETTINGS"; }
case "$1" in
  toggle)
    if is_on; then
      sed -i '' 's/^preventSleepEnabled = true/preventSleepEnabled = false/' "$SETTINGS"
    else
      sed -i '' 's/^preventSleepEnabled = false/preventSleepEnabled = true/' "$SETTINGS"
    fi ;;
  state) is_on && echo on || echo off ;;
esac
