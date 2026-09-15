#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:0
export HOME=/home/roblox
export XDG_RUNTIME_DIR=/run/user/1000
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2

for _ in $(seq 1 30); do
  if xdpyinfo -display :0 >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

exec /opt/selkies.AppImage \
  --addr=0.0.0.0,:: \
  --port="${SELKIES_PORT:-6080}" \
  --basic-auth-user="${SELKIES_BASIC_AUTH_USER:-roblox}" \
  --basic-auth-password="${SELKIES_BASIC_AUTH_PASSWORD:-roblox}"
