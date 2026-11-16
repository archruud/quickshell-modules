#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '02b-verify-development-tools'
begin_log '03-install-or-verify-llama-vulkan'

printf '\n=== LLAMA.CPP / VULKAN ===\n'
if ! command -v llama-cli >/dev/null 2>&1; then
    printf 'llama-cli finnes ikke. Installerer offisielle llama-cpp og ggml-vulkan.\n'
    sudo pacman -Syu --needed llama-cpp ggml-vulkan
else
    printf 'Eksisterende llama-cli: %s\n' "$(command -v llama-cli)"
    pacman -Qo "$(command -v llama-cli)" || true
    if ! pacman -Q ggml-vulkan >/dev/null 2>&1; then
        if pacman -Qo "$(command -v llama-cli)" 2>/dev/null | grep -q 'owned by llama-cpp'; then
            printf 'Eksisterende pacman llama-cpp; legger til manglende Vulkan-backend.\n'
            sudo pacman -Syu --needed ggml-vulkan
        else
            warn 'Eksisterende llama-cli er ikke bekreftet som Arch-pakke. Installerer ikke over den.'
        fi
    fi
fi

command -v llama-cli >/dev/null 2>&1 || fail 'llama-cli mangler fortsatt.'
command -v llama-server >/dev/null 2>&1 || fail 'llama-server mangler. Ingen automatisk overskriving av custom build.'

printf '\n=== ENHETER SETT AV LLAMA.CPP ===\n'
if timeout 75s llama-cli --list-devices > "$STATE_DIR/03-llama-devices.txt" 2>&1; then
    cat "$STATE_DIR/03-llama-devices.txt"
else
    cat "$STATE_DIR/03-llama-devices.txt"
    fail 'llama-cli --list-devices feilet.'
fi

if ! grep -Eiq '(Vulkan[[:space:]]*[0-9]+|Vulkan.*Intel|Intel.*Vulkan)' "$STATE_DIR/03-llama-devices.txt"; then
    fail 'Ingen Vulkan-enhet funnet i llama.cpp. Ikke gå videre.'
fi

printf '\nLLAMA_VULKAN_PASS=1\n'
mark_step '03-install-or-verify-llama-vulkan'
show_next './scripts/04-check-selected-models.sh'
