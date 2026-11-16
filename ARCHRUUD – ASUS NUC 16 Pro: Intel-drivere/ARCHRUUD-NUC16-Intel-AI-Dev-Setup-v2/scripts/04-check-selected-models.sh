#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '03-install-or-verify-llama-vulkan'
begin_log '04-check-selected-models'

ROOTS=("$HOME/AI/models" "$HOME/Data/AI/models" "$HOME/Data/models")
if [[ -n "${MODEL_DIR:-}" ]]; then
    ROOTS=("$MODEL_DIR" "${ROOTS[@]}")
fi

printf '\n=== VALGTE MODELLER – KUN FILKONTROLL ===\n'
printf 'Ingen nedlasting, flytting, sletting eller endring av GGUF-filer.\n'
if /usr/bin/python "$ROOT/tools/check_models.py" "$STATE_DIR/model-paths.json" "${ROOTS[@]}"; then
    mark_step '04-check-selected-models'
    show_next './scripts/05-smoke-test-main-llm.sh'
else
    rm -f -- "$STATE_DIR/04-check-selected-models.ok"
    fail 'En eller flere modeller mangler. Send resultatet, så finner vi riktig modellkilde før videre test.'
fi
