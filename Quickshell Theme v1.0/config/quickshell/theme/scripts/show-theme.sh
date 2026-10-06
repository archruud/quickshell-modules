#!/usr/bin/env bash
set -euo pipefail
FILE="${XDG_CACHE_HOME:-$HOME/.cache}/archruud/theme/theme.json"
[[ -s "$FILE" ]] || { echo "Theme finnes ikke ennå: $FILE" >&2; exit 1; }
if command -v jq >/dev/null 2>&1; then jq . "$FILE"; else cat "$FILE"; fi
