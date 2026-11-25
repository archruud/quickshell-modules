#!/usr/bin/env bash
# ARCHRUUD Power Menu v1.0.1: use central system actions.
# Fixes Lua-based Hyprland logout and direct Hyprlock lock handling.
set -Eeuo pipefail
helper="$HOME/.config/hypr/scripts/archruud-power-action.sh"
if [[ ! -x "$helper" ]]; then
    printf 'ARCHRUUD Power Foundation missing: %s\n' "$helper" >&2
    exit 1
fi
exec "$helper" "${1:-}"
