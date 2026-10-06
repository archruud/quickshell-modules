#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-$HOME/.config/hypr/wallpapers}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/wallpaper"
STATE_FILE="$STATE_DIR/current-wallpaper"

command -v awww >/dev/null 2>&1 || exit 0

if ! awww query >/dev/null 2>&1; then
    nohup awww-daemon >/dev/null 2>&1 &
    for _ in {1..40}; do
        awww query >/dev/null 2>&1 && break
        sleep 0.05
    done
fi

WALLPAPER=""
if [[ -s "$STATE_FILE" ]]; then
    WALLPAPER="$(cat "$STATE_FILE")"
fi

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER="$(
        find "$DIR" -maxdepth 1 -type f \
          \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
          -print 2>/dev/null | sort | head -n 1
    )"
fi

[[ -n "$WALLPAPER" && -f "$WALLPAPER" ]] || exit 0

awww img "$WALLPAPER"
mkdir -p "$STATE_DIR"
printf '%s\n' "$WALLPAPER" > "$STATE_FILE"
printf '%s\n' "$WALLPAPER"
