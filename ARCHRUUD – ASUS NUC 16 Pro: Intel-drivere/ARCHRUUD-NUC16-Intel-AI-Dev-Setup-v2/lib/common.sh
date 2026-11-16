#!/usr/bin/env bash
# Shared helpers. This file is sourced, not executed.
set -Eeuo pipefail
umask 077

STATE_DIR="${HOME}/AI/nuc16-setup/state"
LOG_DIR="${HOME}/AI/nuc16-setup/logs"
mkdir -p "$STATE_DIR" "$LOG_DIR"

fail() { printf '\n[STOPP] %s\n' "$*" >&2; exit 1; }
warn() { printf '[MERK] %s\n' "$*"; }
ok() { printf '[OK] %s\n' "$*"; }

require_user() {
    [[ $EUID -ne 0 ]] || fail 'Kjør som vanlig bruker, IKKE med sudo bash.'
    [[ "$(uname -m)" == 'x86_64' ]] || fail 'Forventet x86_64.'
    [[ -r /etc/os-release ]] || fail 'Mangler /etc/os-release.'
    # shellcheck disable=SC1091
    source /etc/os-release
    [[ "${ID:-}" == 'arch' ]] || fail "Forventet Arch Linux, fant ${ID:-ukjent}."
}

begin_log() {
    local name="$1"
    LOG_FILE="$LOG_DIR/${name}-$(date +%Y%m%d-%H%M%S).log"
    exec > >(tee -a "$LOG_FILE") 2>&1
    trap 'on_error "$?" "$LINENO"' ERR
    printf '\n=======================================================\n'
    printf 'ARCHRUUD NUC16 | %s\n' "$name"
    printf 'Dato: %s\nKernel: %s\nBruker: %s\nLogg: %s\n' "$(date --iso-8601=seconds)" "$(uname -r)" "${USER:-$(id -un)}" "$LOG_FILE"
    printf '=======================================================\n'
}

on_error() {
    local rc="$1" line="$2"
    printf '\n[FEIL] Kommando feilet på linje %s (kode %s).\nLogg: %s\n' "$line" "$rc" "$LOG_FILE" >&2
    exit "$rc"
}

require_step() {
    local step="$1"
    [[ -f "$STATE_DIR/$step.ok" ]] || fail "Mangler godkjent kontroll: $step. Kjør foregående trinn først."
}

mark_step() {
    local step="$1"
    printf 'date=%s\nboot_id=%s\n' "$(date --iso-8601=seconds)" "$(cat /proc/sys/kernel/random/boot_id)" > "$STATE_DIR/$step.ok"
    ok "${step}: GODKJENT"
}

show_next() { printf '\nNESTE TRINN: %s\n' "$*"; }
