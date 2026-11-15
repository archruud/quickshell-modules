#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST=$(mktemp -d)
trap 'rm -rf "$TEST"' EXIT
mkdir -p "$TEST/bin" "$TEST/state" "$TEST/video"
cat > "$TEST/fake-wf.c" <<'EOF'
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
volatile sig_atomic_t stopping=0;
void stop_handler(int sig) { (void)sig; stopping=1; }
int main(int argc, char **argv) {
  const char *out = NULL;
  for (int i=1;i<argc-1;i++) if(strcmp(argv[i],"-f")==0) out = argv[i+1];
  if (!out) return 2;
  FILE *f = fopen(out,"w");
  if (!f) return 3;
  fprintf(f, "video test\\n"); fflush(f);
  signal(SIGINT, stop_handler);
  for (int t=0;t<300 && !stopping;t++) usleep(10000);
  fprintf(f, "video finalized\\n"); fclose(f);
  return stopping ? 0 : 3;
}
EOF
gcc -O2 -o "$TEST/bin/wf-recorder" "$TEST/fake-wf.c"
cat > "$TEST/bin/slurp" <<'EOF'
#!/bin/bash
printf '10,10 1280x720\n'
EOF
cat > "$TEST/bin/notify-send" <<'EOF'
#!/bin/bash
exit 0
EOF
cat > "$TEST/bin/quickshell" <<'EOF'
#!/bin/bash
echo "$*" >> "$QS_TEST_LOG"
sleep .15
EOF
chmod +x "$TEST/bin/"*
export PATH="$TEST/bin:$PATH"
export ARCHRUUD_RECORDER_OUTPUT_DIR="$TEST/video"
export ARCHRUUD_RECORDER_STATE_DIR="$TEST/state"
export QS_TEST_LOG="$TEST/qs.log"
# MENU open on idle
bash "$ROOT/toggle.sh"
grep -q -- 'shell.qml' "$QS_TEST_LOG"
# Start in background, use real ELF stub with comm=wf-recorder.
bash "$ROOT/recorder.sh" start low on first &
startpid=$!
for _ in {1..60}; do
  if bash "$ROOT/recorder.sh" status >/dev/null; then break; fi
  sleep .05
done
bash "$ROOT/recorder.sh" status
bash "$ROOT/recorder.sh" busy
# Toggle sends INT to running recorder, must not reopen menu.
bash "$ROOT/toggle.sh"
wait "$startpid"
grep -q 'video finalized' "$TEST/video/first.mp4"
# On stop, no hung indicator process should retain the recording lock.
for _ in {1..60}; do
  if [[ ! -e "$TEST/state/recorder.pid" ]]; then break; fi
  sleep .05
done
bash "$ROOT/recorder.sh" start medium off second &
startpid=$!
for _ in {1..60}; do
  if bash "$ROOT/recorder.sh" status >/dev/null; then break; fi
  sleep .05
done
bash "$ROOT/toggle.sh"
wait "$startpid"
[[ -s "$TEST/video/second.mp4" ]]
# Verify indicator spawned at least once.
sleep .25
grep -q 'indicator.qml' "$QS_TEST_LOG"
# No new menu call during recording; exactly one picker from first toggle.
[[ $(grep -c 'shell.qml' "$QS_TEST_LOG") == 1 ]]
[[ $(grep -c 'indicator.qml' "$QS_TEST_LOG") -ge 1 ]]
echo 'PASS: idle toggle opens picker, active toggle stops recorder, REC indicator launches, file finalized, lock released, repeated recordings work.'
