#!/usr/bin/env bash
set -Eeuo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONTROL="$HERE/config/quickshell/archruud-kairos-original/scripts/notifications_control.py"
exec python3 "$CONTROL" "${1:-status}"
