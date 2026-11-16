#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '00-preflight'
begin_log '01-install-intel-stack'

PACKAGES=(
    linux-firmware intel-ucode
    mesa vulkan-intel vulkan-icd-loader vulkan-tools
    libva libva-utils intel-media-driver
    intel-compute-runtime level-zero-loader ocl-icd clinfo
    intel-npu-driver intel-npu-compiler
    openvino openvino-intel-gpu-plugin openvino-intel-npu-plugin python-openvino
    python pciutils usbutils lm_sensors
)

printf '\n=== INTEL GPU / NPU / OPENVINO ===\n'
printf 'Offisielle Arch-pakker; ingen AUR. Full pacman -Syu (ingen delvis oppgradering).\n'
printf 'Ingen endring av EFI, GRUB, partisjoner, kernel-parametere eller Hyprland.\n'
printf 'Pacman viser endringene og ber om bekreftelse.\n\n'

sudo pacman -Syu --needed "${PACKAGES[@]}"

if getent group render >/dev/null 2>&1; then
    if ! id -nG "$USER" | tr ' ' '\n' | grep -qx render; then
        sudo usermod -aG render "$USER"
        warn "La til $USER i render-gruppen. Omstart/ny innlogging er nødvendig."
    else
        ok 'render-gruppen er allerede riktig.'
    fi
else
    warn 'render-gruppen finnes ikke; dette må vurderes i kontrolltrinnet.'
fi

cat /proc/sys/kernel/random/boot_id > "$STATE_DIR/01-install-boot-id"
mark_step '01-install-intel-stack'
printf '\nVIKTIG: START MASKINEN PÅ NYTT NÅ.\n'
printf 'Kjør deretter ./scripts/01b-verify-intel-stack.sh\n'
