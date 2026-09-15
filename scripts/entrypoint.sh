#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/user/1000 /home/roblox/.var/app
chown -R roblox:roblox /run/user/1000 /home/roblox/.var
chmod 700 /run/user/1000

# Start the desktop/noVNC stack immediately. Sober can take several minutes to
# download/install on the first boot, so port 6080 must not depend on that.
/usr/bin/supervisord -c /etc/supervisor/conf.d/roblox.conf &
SUPERVISOR_PID=$!

# Install Sober in the background of the desktop startup sequence.
gosu roblox env HOME=/home/roblox flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
gosu roblox env HOME=/home/roblox flatpak install --user -y flathub org.vinegarhq.Sober

# Keep the container alive with supervisord after the installation completes.
wait "$SUPERVISOR_PID"
