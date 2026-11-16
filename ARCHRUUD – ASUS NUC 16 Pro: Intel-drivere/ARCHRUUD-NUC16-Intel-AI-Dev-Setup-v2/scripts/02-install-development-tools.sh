#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '01b-verify-intel-stack'
begin_log '02-install-development-tools'

PACKAGES=(
    base-devel git git-lfs
    zed python uv
    gcc clang lld gdb cmake ninja meson pkgconf ccache
    rust rust-analyzer nodejs npm
    shellcheck shfmt jq ripgrep fd fzf tree btop
)

printf '\n=== PROGRAMMERING / ZED / PYTHON / C++ / RUST / JS ===\n'
printf 'Kun offisielle Arch-pakker. Python-prosjekter får egne uv-miljøer.\n'
printf 'Ingen global pip-installasjon og ingen endring av Hyprland.\n\n'

sudo pacman -Syu --needed "${PACKAGES[@]}"
if command -v git-lfs >/dev/null 2>&1; then
    git lfs install
fi
mark_step '02-install-development-tools'
show_next './scripts/02b-verify-development-tools.sh'
