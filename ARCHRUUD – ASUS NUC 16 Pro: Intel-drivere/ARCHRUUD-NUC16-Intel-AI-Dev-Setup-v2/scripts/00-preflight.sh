#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
begin_log '00-preflight'

[[ -d /sys/firmware/efi ]] || fail 'Maskinen er ikke startet i UEFI-modus. Ingen installasjon utført.'
[[ ! -e /var/lib/pacman/db.lck ]] || fail 'Pacman er låst. Kontroller annen pakkebehandling; ikke slett låsen ukritisk.'

if ! grep -qim1 'GenuineIntel' /proc/cpuinfo; then
    fail 'Fant ikke Intel-prosessor. Stopp for å unngå feil maskin.'
fi

printf '\n=== CPU / KERNEL ===\n'
lscpu | grep -E 'Architecture:|Model name:|CPU\(s\):|Vendor ID:' || true
uname -a

printf '\n=== DISKER / PARTISJONER (KUN LESING) ===\n'
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MODEL,MOUNTPOINTS
printf '\n=== MONTERINGER ===\n'
findmnt -T / -o TARGET,SOURCE,FSTYPE,OPTIONS
findmnt -T /boot -o TARGET,SOURCE,FSTYPE,OPTIONS || true
if [[ -e "$HOME/Data" ]]; then
    findmnt -T "$HOME/Data" -o TARGET,SOURCE,FSTYPE,OPTIONS || true
fi

printf '\n=== LEDIG PLASS / RAM ===\n'
df -h / "$HOME" 2>/dev/null || true
free -h
avail_kb="$(df -Pk / | awk 'NR==2 {print $4}')"
[[ "$avail_kb" =~ ^[0-9]+$ ]] || fail 'Kunne ikke lese ledig diskplass.'
(( avail_kb >= 5*1024*1024 )) || fail 'Under 5 GiB ledig på rotfilsystemet.'

printf '\n=== PCI / INTEL ===\n'
if command -v lspci >/dev/null 2>&1; then
    lspci -nnk | grep -A4 -Ei 'VGA|Display|3D controller|Processing accelerators|Neural' || true
else
    warn 'lspci er ikke installert ennå; dette er ikke en feil.'
fi

printf '\n=== ENHETER / GRUPPER ===\n'
ls -ld /dev/dri /dev/accel 2>/dev/null || true
ls -l /dev/dri/renderD* /dev/accel/accel* 2>/dev/null || true
id

printf '\n=== INSTALLERTE RELEVANTE PAKKER ===\n'
for pkg in intel-ucode mesa vulkan-intel intel-npu-driver intel-npu-compiler openvino python-openvino llama-cpp ggml-vulkan zed uv; do
    pacman -Q "$pkg" 2>/dev/null || true
done

printf '\nPRECHECK_PASS=1\n'
mark_step '00-preflight'
show_next './scripts/01-install-intel-stack.sh'
