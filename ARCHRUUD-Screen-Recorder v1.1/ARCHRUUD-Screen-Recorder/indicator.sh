#!/usr/bin/env bash
# Launch at most one REC badge while a recording is running.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
STATE_DIR="${ARCHRUUD_RECORDER_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/archruud-screen-recorder}"
mkdir -p -- "$STATE_DIR"
exec {indicator_fd}> "$STATE_DIR/indicator.lock"
flock -n "$indicator_fd" || exit 0
bash "$SCRIPT_DIR/recorder.sh" status >/dev/null 2>&1 || exit 0
exec quickshell -p "$SCRIPT_DIR/indicator.qml"
