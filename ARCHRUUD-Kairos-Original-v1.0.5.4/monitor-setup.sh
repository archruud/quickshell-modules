#!/usr/bin/env bash
# Explicit opt-in setup. No changes when called with no args / --check.
set -euo pipefail
mode=${1:---check}
case "$mode" in
  --check)
    if command -v ddcutil >/dev/null 2>&1; then
      printf 'DDCUTIL: installed (%s)\n' "$(command -v ddcutil)"
    else
      printf 'DDCUTIL: missing. Run: bash monitor-setup.sh --install\n'
    fi
    if [[ -d /sys/module/i2c_dev ]]; then
      echo 'I2C-DEV: loaded'
    else
      echo 'I2C-DEV: not reported as loaded'
    fi
    printf 'I2C DEVICES: '
    shopt -s nullglob
    devices=(/dev/i2c-*)
    if ((${#devices[@]})); then
      printf '%s ' "${devices[@]}"
      printf '\n'
    else
      echo 'none'
    fi
    if command -v ddcutil >/dev/null 2>&1; then
      echo 'DDCUTIL DETECT (read-only):'
      timeout 25 ddcutil detect --brief || true
    fi
    ;;
  --install)
    echo 'Installing Arch Linux ddcutil using pacman (may ask for sudo password).'
    sudo pacman -S --needed ddcutil
    if [[ ! -d /sys/module/i2c_dev ]]; then
      echo 'Loading i2c-dev for this boot.'
      sudo modprobe i2c-dev
    fi
    echo 'DDCUTIL installed. Checking monitor detection as your own user:'
    if ! ddcutil detect --brief; then
      echo 'No accessible DDC/CI display found yet. Run bash diagnose-monitor.sh.'
      echo 'Also check the monitor OSD menu for DDC/CI and device permissions.'
    fi
    ;;
  *)
    echo 'Usage: bash monitor-setup.sh [--check|--install]' >&2
    exit 2
    ;;
esac
