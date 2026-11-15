#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/videos" "$TMP/state"
cat > "$TMP/bin/slurp" <<'MOCK'
#!/usr/bin/env bash
printf '10,20 640x480\n'
MOCK
cat > "$TMP/bin/wf-recorder" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$WF_TEST_ARGS"
while (( $# )); do
  if [[ $1 == '-f' ]]; then
    shift; printf 'mock video\n' > "$1"; break
  fi
  shift
done
sleep "${WF_TEST_DELAY:-0.03}"
MOCK
cat > "$TMP/bin/notify-send" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$TMP/bin"/*
export PATH="$TMP/bin:$PATH"
export ARCHRUUD_RECORDER_OUTPUT_DIR="$TMP/videos"
export ARCHRUUD_RECORDER_STATE_DIR="$TMP/state"
export WF_TEST_ARGS="$TMP/args.log"

bash "$ROOT/recorder.sh" start low on 'kairos-test'
bash "$ROOT/recorder.sh" start low on 'kairos-test'
[[ -f "$TMP/videos/kairos-test.mp4" ]]
[[ -f "$TMP/videos/kairos-test_2.mp4" ]]
[[ $(grep -c -- '-a -C aac' "$TMP/args.log") == 2 ]]
bash "$ROOT/recorder.sh" start full off 'Full skjerm'
[[ -f "$TMP/videos/Full skjerm.mp4" ]]
grep -q -- '-r 60' "$TMP/args.log"
grep -q -- 'crf=16' "$TMP/args.log"
[[ $(grep -c -- ' -a ' "$TMP/args.log") == 2 ]]

# Run all 6 profiles, verify returned files and audio modes.
for level in low medium full; do
  for sound in on off; do
    bash "$ROOT/recorder.sh" start "$level" "$sound" "profile_${level}_${sound}"
    [[ -s "$TMP/videos/profile_${level}_${sound}.mp4" ]]
  done
done

echo 'PASS: 6 profiles, correct sound options, output files, auto-unique names.'
