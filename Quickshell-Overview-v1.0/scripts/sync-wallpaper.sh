#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/wallpaper/current-wallpaper"
CONFIG="$HOME/.config/quickshell/overview/config.json"

[[ -f "$CONFIG" ]] || exit 0
[[ -s "$STATE_FILE" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

WALLPAPER="$(head -n1 "$STATE_FILE")"
[[ -f "$WALLPAPER" ]] || exit 0

CURRENT="$(jq -r '.overview.emptyWorkspaceWallpaper // ""' "$CONFIG")"
[[ "$CURRENT" == "$WALLPAPER" ]] && exit 0

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
jq --arg wp "$WALLPAPER" \
  '.overview.emptyWorkspaceWallpaper = $wp | .overview.specialEmptyWorkspaceWallpaper = $wp' \
  "$CONFIG" > "$TMP"
mv "$TMP" "$CONFIG"
trap - EXIT

# Overview leser wallpaper-stien ved oppstart. Restart bare denne Quickshell-configen.
if pgrep -af 'qs.*-c overview|quickshell.*overview' >/dev/null 2>&1; then
    qs ipc -c overview call overview close >/dev/null 2>&1 || true
    pkill -f 'qs.*-c overview' >/dev/null 2>&1 || true
    pkill -f 'quickshell.*overview' >/dev/null 2>&1 || true
    sleep 0.2
fi
nohup qs -c overview >/dev/null 2>&1 &
