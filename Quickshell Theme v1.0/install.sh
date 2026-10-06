#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
THEME="$HOME/.config/quickshell/theme"
KITTY="$HOME/.config/kitty/kitty.conf"
INCLUDE='include ~/.cache/archruud/theme/kitty.conf'

echo "ARCHRUUD Quickshell Theme v1.0"
echo "================================"

sudo pacman -S --needed jq
if ! command -v wallust >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1; then
        yay -S --needed wallust
    else
        echo "wallust mangler, og yay er ikke installert." >&2
        exit 1
    fi
fi

mkdir -p "$HOME/.config/quickshell" "$HOME/.config/systemd/user" "$HOME/.config/kitty"
if [[ -d "$THEME" ]]; then
    mv "$THEME" "$THEME.backup-$STAMP"
    echo "Backup: $THEME.backup-$STAMP"
fi
cp -a "$HERE/config/quickshell/theme" "$THEME"
cp "$HERE/systemd/user/archruud-theme.service" "$HOME/.config/systemd/user/"
cp "$HERE/systemd/user/archruud-theme.path" "$HOME/.config/systemd/user/"
chmod +x "$THEME/scripts/"*.sh

mkdir -p "$HOME/.local/state/archruud/theme" "$HOME/.cache/archruud/theme"
# ARCHRUUD default: darkblue. Existing explicit choice is preserved.
[[ -s "$HOME/.local/state/archruud/theme/mode" ]] || printf 'darkblue\n' > "$HOME/.local/state/archruud/theme/mode"

if [[ -f "$KITTY" ]]; then
    cp "$KITTY" "$KITTY.backup-theme-$STAMP"
else
    touch "$KITTY"
fi
if ! grep -Fqx "$INCLUDE" "$KITTY"; then
    printf '\n# ARCHRUUD dynamic theme\n%s\n' "$INCLUDE" >> "$KITTY"
fi

systemctl --user daemon-reload
systemctl --user enable --now archruud-theme.path

if [[ -s "$HOME/.local/state/archruud/wallpaper/current-wallpaper" ]]; then
    "$THEME/scripts/apply-theme.sh" auto
else
    echo "Ingen current-wallpaper ennå. Theme genereres automatisk ved første wallpaper-valg."
fi

echo ""
echo "Installert."
echo "Theme API: ~/.cache/archruud/theme/theme.json"
echo "Standard:  darkblue"
echo "Watcher:   archruud-theme.path"
echo ""
echo "Vis theme:"
echo "  ~/.config/quickshell/theme/scripts/show-theme.sh"
echo ""
echo "Bytt modus:"
echo "  ~/.config/quickshell/theme/scripts/set-mode.sh darkblue"
