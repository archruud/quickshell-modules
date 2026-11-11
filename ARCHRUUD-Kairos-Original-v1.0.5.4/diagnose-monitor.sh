#!/usr/bin/env bash
set -euo pipefail
script="$HOME/.config/quickshell/archruud-kairos-original/scripts/archruud_brightness.py"
if [[ ! -f "$script" ]]; then
  printf 'Not found: %s\nInstall the patch first.\n' "$script" >&2
  exit 1
fi
python3 "$script" diagnose
