#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="${1:?Mangler wallpaper-fil}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/wallpaper"
STATE_FILE="$STATE_DIR/current-wallpaper"

[[ -f "$WALLPAPER" ]] || {
    echo "Filen finnes ikke: $WALLPAPER" >&2
    exit 1
}

command -v awww >/dev/null 2>&1 || {
    echo "awww er ikke installert" >&2
    exit 1
}

mkdir -p "$STATE_DIR"

if ! awww query >/dev/null 2>&1; then
    nohup awww-daemon >/dev/null 2>&1 &
    for _ in {1..40}; do
        awww query >/dev/null 2>&1 && break
        sleep 0.05
    done
fi

awww img "$WALLPAPER"
printf '%s\n' "$WALLPAPER" > "$STATE_FILE"
printf '%s\n' "$WALLPAPER"
