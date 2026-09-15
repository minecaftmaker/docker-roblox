#!/usr/bin/env bash
set -uo pipefail

mkdir -p /run/user/1000 /home/roblox/.var/app /run/dbus
chown -R roblox:roblox /run/user/1000 /home/roblox/.var
chmod 700 /run/user/1000

# Flatpak needs a system D-Bus socket even when the Flatpak itself is a
# per-user installation. Minimal containers do not start dbus automatically.
if [ ! -S /run/dbus/system_bus_socket ]; then
  echo "[roblox-docker] Starting system D-Bus..."
  dbus-daemon --system --fork
fi

# Start the desktop/streaming stack immediately. Sober may take several
# minutes to download, so installation must never be allowed to kill PID 1.
/usr/bin/supervisord -c /etc/supervisor/conf.d/roblox.conf &
SUPERVISOR_PID=$!

# Configure Flathub. Keep going if the first attempt is temporarily unavailable.
gosu roblox env HOME=/home/roblox dbus-run-session -- \
  flatpak remote-add --user --if-not-exists flathub \
  https://dl.flathub.org/repo/flathub.flatpakrepo || true

# Retry Sober installation until it succeeds. This prevents Docker's
# restart: unless-stopped policy from turning transient Flatpak/D-Bus/network
# errors into a boot loop.
while ! gosu roblox env HOME=/home/roblox flatpak info org.vinegarhq.Sober >/dev/null 2>&1; do
  echo "[roblox-docker] Sober is not installed; attempting installation..."
  if gosu roblox env HOME=/home/roblox dbus-run-session -- \
      flatpak install --user -y flathub org.vinegarhq.Sober; then
    echo "[roblox-docker] Sober installation completed."
    break
  fi
  echo "[roblox-docker] Sober installation failed; retrying in 10 seconds..."
  sleep 10
done

# Keep supervisord as the lifecycle owner. The container stays up even while
# Sober is unavailable or being retried.
wait "$SUPERVISOR_PID"
