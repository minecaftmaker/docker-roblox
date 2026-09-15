#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:0
export HOME=/home/roblox
export XDG_RUNTIME_DIR=/run/user/1000
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2

# The first container start may still be installing Sober. Keep the launcher
# alive and wait for the Flatpak app to become available instead of exiting.
until gosu roblox env HOME=/home/roblox flatpak info org.vinegarhq.Sober >/dev/null 2>&1; do
    sleep 5
done

sleep 3
exec gosu roblox dbus-run-session -- flatpak run org.vinegarhq.Sober
