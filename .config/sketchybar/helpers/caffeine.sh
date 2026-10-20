#!/bin/bash
# Battery-pill caffeine toggle: pidfile-managed caffeinate instance.
PIDFILE="$HOME/.local/state/caffeine.pid"
mkdir -p "$(dirname "$PIDFILE")"
running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }
case "$1" in
  toggle)
    if running; then kill "$(cat "$PIDFILE")" 2>/dev/null; rm -f "$PIDFILE";
    else nohup caffeinate -dims >/dev/null 2>&1 & echo $! > "$PIDFILE"; fi ;;
  state) running && echo on || echo off ;;
esac
