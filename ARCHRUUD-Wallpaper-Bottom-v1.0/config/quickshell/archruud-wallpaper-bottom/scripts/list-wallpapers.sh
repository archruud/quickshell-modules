#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-$HOME/.config/hypr/wallpapers}"

[[ -d "$DIR" ]] || exit 0

find "$DIR" -maxdepth 1 -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
  -print | sort
