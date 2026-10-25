#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/kitty" "$HOME/.config/bash"

install -m 0644 "$SCRIPT_DIR/files/bashrc.archruud" "$HOME/.config/bash/archruud.bash"
install -m 0644 "$SCRIPT_DIR/files/kitty.conf" "$HOME/.config/kitty/kitty.conf"

touch "$HOME/.bashrc"
MARKER='# ARCHRUUD modular bash config'
if ! grep -Fq "$MARKER" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# ARCHRUUD modular bash config
[ -f "$HOME/.config/bash/archruud.bash" ] && source "$HOME/.config/bash/archruud.bash"
[ -f "$HOME/.config/bash/archruud-local.bash" ] && source "$HOME/.config/bash/archruud-local.bash"
EOF
fi

touch "$HOME/.config/bash/archruud-local.bash"

echo "Kitty + ARCHRUUD Bash installert."
echo "Kjør: source ~/.bashrc"
