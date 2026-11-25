#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")"
sha256sum -c SHA256SUMS
printf "\n%s\n" "Verified: included application files match the user-provided working source snapshot."
