#!/usr/bin/env bash
set -euo pipefail
systemctl --user disable --now archruud-overview-wallpaper.path >/dev/null 2>&1 || true
rm -f "$HOME/.config/systemd/user/archruud-overview-wallpaper.path" \
      "$HOME/.config/systemd/user/archruud-overview-wallpaper.service"
systemctl --user daemon-reload
rm -f "$HOME/.config/hypr/module-config/quickshell-overview.lua"
echo "ARCHRUUD-integrasjonen er fjernet."
echo "Upstream ~/.config/quickshell/overview er beholdt for sikkerhets skyld."
