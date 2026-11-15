#!/usr/bin/env bash
exec bash "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/recorder.sh" start medium off "${1:-}"
