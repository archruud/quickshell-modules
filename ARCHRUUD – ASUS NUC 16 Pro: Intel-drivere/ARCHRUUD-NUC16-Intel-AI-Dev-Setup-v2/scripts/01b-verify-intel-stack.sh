#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '01-install-intel-stack'
begin_log '01b-verify-intel-stack'

old_boot_id="$(cat "$STATE_DIR/01-install-boot-id")"
new_boot_id="$(cat /proc/sys/kernel/random/boot_id)"
[[ "$old_boot_id" != "$new_boot_id" ]] || fail 'Maskinen er ikke startet på nytt etter trinn 01. Ta omstart først.'

failures=0
printf '\n=== KERNEL / INTEL-DRIVERE ===\n'
uname -r
lsmod | grep -E '^(xe|i915|intel_vpu)[[:space:]]' || true
lspci -nnk | grep -A5 -Ei 'VGA|Display|3D controller|Processing accelerators|Neural' || true

printf '\n=== RENDER / NPU ===\n'
ls -l /dev/dri/renderD* /dev/accel/accel* 2>/dev/null || true
if ! compgen -G '/dev/dri/renderD*' >/dev/null; then
    warn 'Mangler /dev/dri/renderD*. '
    ((failures+=1))
fi
if ! compgen -G '/dev/accel/accel*' >/dev/null; then
    warn 'Mangler /dev/accel/accel*. '
    ((failures+=1))
fi
if ! id -nG | tr ' ' '\n' | grep -qx render; then
    warn 'Brukeren har ikke aktivt render-gruppemedlemskap.'
    ((failures+=1))
fi

printf '\n=== VULKAN ===\n'
if timeout 45s vulkaninfo --summary > "$STATE_DIR/01b-vulkan.txt" 2>&1; then
    cat "$STATE_DIR/01b-vulkan.txt"
    if grep -Eiq '(deviceName[[:space:]]*=.*Intel|Intel.*Graphics|Intel.*PTL|Panther)' "$STATE_DIR/01b-vulkan.txt"; then
        ok 'Intel Vulkan GPU funnet.'
    else
        warn 'Vulkan svarer, men ingen Intel GPU ble gjenkjent.'
        ((failures+=1))
    fi
else
    cat "$STATE_DIR/01b-vulkan.txt"
    warn 'vulkaninfo feilet.'
    ((failures+=1))
fi

printf '\n=== OPENVINO CPU / GPU / NPU ===\n'
if timeout 120s /usr/bin/python "$ROOT/tools/openvino_devices.py" > "$STATE_DIR/01b-openvino.txt" 2>&1; then
    cat "$STATE_DIR/01b-openvino.txt"
    for device in CPU GPU NPU; do
        if grep -Fqx "OPENVINO_${device}=1" "$STATE_DIR/01b-openvino.txt"; then
            ok "OpenVINO ${device} synlig."
        else
            warn "OpenVINO ${device} ikke synlig."
            ((failures+=1))
        fi
    done
else
    cat "$STATE_DIR/01b-openvino.txt"
    warn 'OpenVINO-enhetstesten feilet.'
    ((failures+=1))
fi

printf '\n=== VALGFRIE MEDIETESTER ===\n'
clinfo -l 2>&1 || warn 'clinfo ga advarsel; ikke kritisk for LLM.'
vainfo --display drm 2>&1 | head -n 50 || warn 'VA-API krever kanskje eksplisitt DRM-enhet; ikke kritisk for LLM.'

if (( failures > 0 )); then
    printf '\nDRIVER_VERIFY_PASS=0\n'
    fail "$failures kritiske kontroller feilet. Stopp her og send loggen før vi går videre."
fi
printf '\nDRIVER_VERIFY_PASS=1\n'
mark_step '01b-verify-intel-stack'
show_next './scripts/02-install-development-tools.sh'
