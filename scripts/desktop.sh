#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:0
export HOME=/home/roblox
export XDG_RUNTIME_DIR=/run/user/1000

for i in {1..60}; do
  if xdpyinfo >/dev/null 2>&1; then break; fi
  sleep 1
done

exec dbus-run-session -- startxfce4
