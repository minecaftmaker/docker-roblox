#!/usr/bin/env bash
set -euo pipefail

echo '== display =='
xdpyinfo -display :0 >/dev/null && echo 'Xorg: OK' || echo 'Xorg: NOT READY'

echo
echo '== OpenGL =='
glxinfo -B 2>/dev/null || true

echo
echo '== Sober =='
flatpak info org.vinegarhq.Sober 2>/dev/null || echo 'Sober not installed'
