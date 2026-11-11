#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
python3 tests/test_github_release.py
python3 -m compileall -q config/quickshell/archruud-kairos-original/scripts scripts
bash -n install.sh rollback.sh install-autostart.sh rollback-autostart.sh dependencies.sh monitor-setup.sh diagnose-monitor.sh monitor-status.sh
if command -v sha256sum >/dev/null; then sha256sum -c SHA256SUMS; fi
printf "ARCHRUUD v1.0.5.4 release verification passed.\n"
