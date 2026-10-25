#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HYPR_SCRIPTS="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
BASH_LOCAL="${XDG_CONFIG_HOME:-$HOME/.config}/bash/archruud-local.bash"

mkdir -p "$HYPR_SCRIPTS" "$(dirname "$BASH_LOCAL")"
install -m 0755 "$SCRIPT_DIR/files/make-executable.sh" "$HYPR_SCRIPTS/make-executable.sh"
touch "$BASH_LOCAL"

grep -v '^alias run=' "$BASH_LOCAL" > "$BASH_LOCAL.tmp" || true
mv "$BASH_LOCAL.tmp" "$BASH_LOCAL"
cat >> "$BASH_LOCAL" <<'EOF'
alias run="$HOME/.config/hypr/scripts/make-executable.sh"
EOF

echo "run installert."
echo "Eksempler:"
echo "  run"
echo "  run install.sh"
echo "  run /sti/til/mappe"
echo
echo "Kjør: source ~/.bashrc"
