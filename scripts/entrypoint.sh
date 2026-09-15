#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/user/1000 /home/roblox/.var/app
chown -R roblox:roblox /run/user/1000 /home/roblox/.var
chmod 700 /run/user/1000

gosu roblox env HOME=/home/roblox flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

gosu roblox env HOME=/home/roblox flatpak install --user -y flathub org.vinegarhq.Sober

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/roblox.conf
