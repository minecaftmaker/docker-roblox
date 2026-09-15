#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:0
export HOME=/home/roblox
export XDG_RUNTIME_DIR=/run/user/1000
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2

sleep 8
exec dbus-run-session -- flatpak run org.vinegarhq.Sober
