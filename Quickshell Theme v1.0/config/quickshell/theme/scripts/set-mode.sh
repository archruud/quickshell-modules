#!/usr/bin/env bash
set -euo pipefail
MODE="${1:?Bruk: set-mode.sh auto|dark|darkblue|light|native}"
[[ "$MODE" =~ ^(auto|dark|darkblue|light|native)$ ]] || { echo "Ugyldig modus: $MODE" >&2; exit 2; }
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/theme"
mkdir -p "$STATE"
printf '%s\n' "$MODE" > "$STATE/mode"
exec "$HOME/.config/quickshell/theme/scripts/apply-theme.sh" "$MODE"
