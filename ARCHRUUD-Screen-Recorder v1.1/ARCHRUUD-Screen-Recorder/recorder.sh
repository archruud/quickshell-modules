#!/usr/bin/env bash
# ARCHRUUD Screen Recorder v1.1 - six quality/audio profiles + REC badge
# Safe output naming; self-contained for Arch + Hyprland.
set -u -o pipefail

OUTPUT_DIR="${ARCHRUUD_RECORDER_OUTPUT_DIR:-$HOME/Bilder/Skjermopptak}"
STATE_DIR="${ARCHRUUD_RECORDER_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/archruud-screen-recorder}"
PID_FILE="$STATE_DIR/recorder.pid"
LOCK_FILE="$STATE_DIR/recorder.lock"
LOG_FILE="$STATE_DIR/last.log"
STOP_REQUEST="$STATE_DIR/stop-requested"
mkdir -p -- "$STATE_DIR" || exit 1

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a 'ARCHRUUD Screen Recorder' "$1" "${2:-}" >/dev/null 2>&1 || true
  fi
}
fail() {
  printf 'FEIL: %s\n' "$*" >&2
  notify 'Opptak - feil' "$*"
  exit 1
}
recorder_running() {
  [[ -r "$PID_FILE" ]] || return 1
  local pid comm
  pid=$(cat -- "$PID_FILE" 2>/dev/null) || return 1
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  comm=$(cat "/proc/$pid/comm" 2>/dev/null) || return 1
  [[ "$comm" == wf-recorder ]]
}

action="${1:-}"
case "$action" in
  busy)
    # Busy also covers the short slurp-area-selection period before a PID exists.
    if recorder_running; then exit 0; fi
    exec {test_fd}> "$LOCK_FILE" || exit 1
    if flock -n "$test_fd"; then
      flock -u "$test_fd"
      exit 1
    else
      exit 0
    fi
    ;;
  status)
    if recorder_running; then
      printf 'Opptak pågår (PID %s)\n' "$(cat "$PID_FILE")"
      exit 0
    else
      echo 'Ingen aktivt opptak'
      exit 1
    fi
    ;;
  stop)
    if ! recorder_running; then
      notify 'Skjermopptak' 'Ingen aktivt opptak å stoppe.'
      echo 'Ingen aktivt opptak.'
      exit 0
    fi
    pid=$(cat -- "$PID_FILE")
    : > "$STOP_REQUEST"
    kill -INT "$pid" || fail 'Kunne ikke stoppe opptaket.'
    notify 'Skjermopptak' 'Stopper og ferdigstiller MP4-filen ...'
    echo 'Stoppsignal sendt. Videoen ferdigstilles.'
    exit 0
    ;;
  start) ;;
  *)
    cat <<USAGE
Bruk:
  $0 start low|medium|full on|off [filnavn uten .mp4]
  $0 stop
  $0 status
  $0 busy
USAGE
    exit 2
    ;;
esac

quality="${2:-}"
sound="${3:-}"
name="${4:-}"
[[ "$sound" == on || "$sound" == off ]] || fail 'Lyd må være on eller off.'

case "$quality" in
  low)
    fps=15
    crf=30
    preset=veryfast
    audio_bitrate=128k
    ;;
  medium)
    fps=30
    crf=23
    preset=fast
    audio_bitrate=192k
    ;;
  full)
    fps=60
    crf=16
    preset=medium
    audio_bitrate=320k
    ;;
  *) fail 'Ukjent kvalitet. Bruk low, medium eller full.' ;;
esac

for cmd in wf-recorder slurp flock; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Mangler programmet: $cmd"
done

# Hold lock for the entire recording session (also while choosing area).
exec {lock_fd}> "$LOCK_FILE" || fail 'Kan ikke opprette låsefil.'
flock -n "$lock_fd" || fail 'Et opptak eller områdevalg er allerede i gang.'
if recorder_running; then
  fail 'Det pågår allerede et opptak. Stopp det først.'
fi
rm -f -- "$PID_FILE" "$STOP_REQUEST"
mkdir -p -- "$OUTPUT_DIR" || fail 'Kan ikke opprette opptaksmappen.'

# The picker has just closed; avoid including it in the slurp selection.
sleep 0.45
geometry=$(slurp) || { echo 'Områdevalg avbrutt.'; exit 0; }
[[ -n "$geometry" ]] || { echo 'Områdevalg avbrutt.'; exit 0; }

# User provides *only* the basename. Prevent paths and strip .mp4 if typed.
name="${name%.[mM][pP]4}"
name="${name//\//_}"
name="${name//\\/_}"
name="${name//$'\n'/_}"
name="${name//$'\r'/_}"
name="$(printf '%s' "$name" | sed -E 's/^[[:space:].]+//; s/[[:space:]]+$//')"
if [[ -z "$name" ]]; then
  name="Opptak_$(date '+%Y-%m-%d_%H-%M-%S')"
fi

# Atomically reserve a new output filename to avoid overwrites, even
# when two attempts use the same name. -y below overwrites ONLY our
# newly reserved empty file, never an existing user file.
filename="$OUTPUT_DIR/$name.mp4"
index=2
while ! ( set -C; : > "$filename" ) 2>/dev/null; do
  filename="$OUTPUT_DIR/${name}_${index}.mp4"
  (( index++ ))
  if (( index > 99999 )); then
    fail 'Klarte ikke å finne et ledig filnavn.'
  fi
done

cmd=(wf-recorder -g "$geometry" -c libx264 -x yuv420p
     -p "crf=$crf" -p "preset=$preset" -r "$fps")
if [[ "$sound" == on ]]; then
  cmd+=(-a -C aac -P "b=$audio_bitrate" -R 48000)
fi
cmd+=(-y -f "$filename")

printf 'Starter: %s\n' "${cmd[*]}" > "$LOG_FILE"
"${cmd[@]}" >> "$LOG_FILE" 2>&1 &
rec_pid=$!
printf '%s\n' "$rec_pid" > "$PID_FILE"

# The indicator is a separate Quickshell instance so closing the chooser
# cannot close REC. Explicitly close the flock FD in the spawned process.
if [[ "${ARCHRUUD_RECORDER_NO_INDICATOR:-0}" != "1" ]]; then
  (
    exec {lock_fd}>&-
    nohup bash "$(dirname -- "${BASH_SOURCE[0]}")/indicator.sh" \
      </dev/null >> "$STATE_DIR/indicator.log" 2>&1 &
  )
fi

cleanup() {
  if [[ -r "$PID_FILE" && $(cat "$PID_FILE" 2>/dev/null) == "$rec_pid" ]]; then
    rm -f -- "$PID_FILE"
  fi
}
trap cleanup EXIT
# A TERM/INT to the supervisor should also allow the recorder to finalize.
trap 'kill -INT "$rec_pid" 2>/dev/null || true' TERM INT

notify 'Opptak startet' "$(basename "$filename") – ${fps} FPS, lyd ${sound}"
wait "$rec_pid"
result=$?

if [[ -f "$STOP_REQUEST" || "$result" -eq 0 ]]; then
  rm -f -- "$STOP_REQUEST"
  notify 'Opptak lagret' "$filename"
  printf 'Lagret: %s\n' "$filename"
  exit 0
fi

# On encoder errors, keep substantial partial files for potential recovery.
if [[ -f "$filename" && ! -s "$filename" ]]; then
  rm -f -- "$filename"
fi
notify 'Opptak mislyktes' "Se logg: $LOG_FILE"
printf 'Opptak mislyktes (kode %s). Logg: %s\n' "$result" "$LOG_FILE" >&2
exit "$result"
