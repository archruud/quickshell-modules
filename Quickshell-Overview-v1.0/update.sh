#!/usr/bin/env bash
set -euo pipefail
DIR="$HOME/.config/quickshell/overview"
[[ -d "$DIR/.git" ]] || { echo "Overview er ikke installert som git clone." >&2; exit 1; }
git -C "$DIR" pull --ff-only
qs ipc -c overview call overview close >/dev/null 2>&1 || true
pkill -f 'qs.*-c overview' >/dev/null 2>&1 || true
pkill -f 'quickshell.*overview' >/dev/null 2>&1 || true
sleep 0.2
nohup qs -c overview >/dev/null 2>&1 &
echo "Overview oppdatert fra upstream."
