#!/usr/bin/env bash
set -euo pipefail
THEME="$HOME/.config/quickshell/theme"
KITTY="$HOME/.config/kitty/kitty.conf"
INCLUDE='include ~/.cache/archruud/theme/kitty.conf'

systemctl --user disable --now archruud-theme.path 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/archruud-theme.path" "$HOME/.config/systemd/user/archruud-theme.service"
systemctl --user daemon-reload
rm -rf "$THEME"
if [[ -f "$KITTY" ]]; then
    sed -i '\|^# ARCHRUUD dynamic theme$|d; \|^include ~/.cache/archruud/theme/kitty.conf$|d' "$KITTY"
fi
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/archruud/theme"
echo "ARCHRUUD Theme er fjernet. Wallpaper-modulen er ikke endret."
