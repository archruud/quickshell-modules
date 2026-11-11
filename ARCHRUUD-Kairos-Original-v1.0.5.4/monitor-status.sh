#!/usr/bin/env bash
set -euo pipefail
SCRIPT="$HOME/.config/quickshell/archruud-kairos-original/scripts/archruud_brightness.py"
if [[ ! -f "$SCRIPT" ]]; then echo "Missing: $SCRIPT" >&2; exit 2; fi
python3 "$SCRIPT" status
