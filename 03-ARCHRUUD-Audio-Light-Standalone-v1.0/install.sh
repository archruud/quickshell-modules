#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODULE="archruud-audio-light"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
TARGET="$CONF/$MODULE"
SOURCE="$ROOT/config/quickshell/$MODULE"
case "${1:---check}" in
  --check)
    echo "Module: $MODULE"
    echo "Source: $SOURCE"
    echo "Target: $TARGET"
    if [[ -f "$TARGET/shell.qml" ]]; then
      if cmp -s "$SOURCE/shell.qml" "$TARGET/shell.qml"; then echo "IDENTICAL to installed version"; else echo "DIFFERENT from installed version"; fi
    else echo "NOT INSTALLED"; fi
    echo 'No changes made.'
    ;;
  --install)
    [[ -f "$SOURCE/shell.qml" ]] || { echo 'ERROR: Missing source'; exit 2; }
    BACKUP="${XDG_STATE_HOME:-$HOME/.local/state}/archruud/module-backups/$MODULE/$(date +%Y%m%d-%H%M%S)-$$"
    mkdir -p "$BACKUP" "$CONF"
    if [[ -e "$TARGET" ]]; then cp -a "$TARGET" "$BACKUP/original"; echo 'Original directory saved.'; else echo 'not-installed' > "$BACKUP/was-absent"; fi
    STAGE="$(mktemp -d "$CONF/.${MODULE}.XXXXXX")"
    trap 'rm -rf -- "$STAGE"' EXIT
    cp -a "$SOURCE/." "$STAGE/"
    if [[ -e "$TARGET" ]]; then mv "$TARGET" "$BACKUP/replaced-original"; fi
    mv "$STAGE" "$TARGET"
    trap - EXIT
    echo "Installed: $TARGET"
    echo "Backup: $BACKUP"
    echo "Restore: bash rollback.sh '$BACKUP'"
    echo 'This installer does NOT change autostart, lua bindings, other modules or running processes.'
    ;;
  *) echo 'Usage: bash install.sh --check | --install' >&2; exit 2;;
esac
