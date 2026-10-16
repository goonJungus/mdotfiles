#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

omniwmctl command preselect right >/dev/null 2>&1
open -n -a Kitty.app

getw() {
  omniwmctl query focused-window --format json 2>/dev/null | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    w=d['result']['payload']['window']
    if w['app']['name']=='kitty':
        print(int(w['frame']['width']))
except: pass
"
}

for i in $(seq 1 40); do
  W=$(getw)
  if [ -n "$W" ] && [ "$W" -ge 800 ] && [ "$W" -le 850 ]; then break; fi
  sleep 0.1
done

for s in 1 2 3 4 5 6; do
  W=$(getw)
  [ -z "$W" ] && break
  [ "$W" -le 580 ] && break
  omniwmctl command resize horizontal shrink >/dev/null 2>&1
  for j in $(seq 1 10); do
    sleep 0.1
    W2=$(getw)
    [ -n "$W2" ] && [ "$W2" != "$W" ] && break
  done
done
