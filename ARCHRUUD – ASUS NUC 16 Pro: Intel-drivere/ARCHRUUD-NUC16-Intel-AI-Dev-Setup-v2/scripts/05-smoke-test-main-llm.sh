#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '04-check-selected-models'
begin_log '05-smoke-test-main-llm'

MODEL="$(/usr/bin/python "$ROOT/tools/get_main_model.py" "$STATE_DIR/model-paths.json")"
[[ -f "$MODEL" ]] || fail 'Hovedmodellfilen finnes ikke.'

if pgrep -x llama-server >/dev/null 2>&1; then
    pgrep -a -x llama-server || true
    fail 'En llama-server kjører allerede. Stopp den manuelt hvis det er trygt, og kjør denne testen på nytt.'
fi

avail_kb="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)"
(( avail_kb >= 20*1024*1024 )) || fail 'Mindre enn 20 GiB tilgjengelig RAM. Lukk andre tunge prosesser først.'

printf '\n=== QWEN3-30B-A3B / INTEL VULKAN – SMOKE TEST ===\n'
printf 'Modell: %s\n' "$MODEL"
printf 'Dette starter kun en kort lokal test, ingen bakgrunnstjeneste.\n'
printf 'Vent mens den store modellen lastes i minnet.\n\n'

timeout 300s llama-cli \
    -m "$MODEL" \
    -ngl 999 \
    -fa on \
    -c 4096 \
    -n 96 \
    --temp 0 \
    -p 'Svar kort på norsk: Hva er 2 pluss 2?'

printf '\nLLM_SMOKE_PASS=1\n'
mark_step '05-smoke-test-main-llm'
printf '\nHovedmodell og Vulkan-kjøring fullført. Ingen tjenester ble aktivert.\n'
