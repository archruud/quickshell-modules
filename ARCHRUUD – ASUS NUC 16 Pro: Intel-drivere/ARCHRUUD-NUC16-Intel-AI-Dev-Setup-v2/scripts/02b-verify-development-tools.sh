#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"
require_user
require_step '02-install-development-tools'
begin_log '02b-verify-development-tools'

printf '\n=== BINÆRFILER ===\n'
commands=(git git-lfs zeditor python uv gcc g++ clang clang++ gdb cmake ninja meson rustc cargo rust-analyzer node npm shellcheck shfmt jq rg fd fzf)
missing=0
for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '[OK] %-16s %s\n' "$cmd" "$(command -v "$cmd")"
    else
        warn "Mangler $cmd"
        ((missing+=1))
    fi
done
(( missing == 0 )) || fail "$missing utviklingsverktøy mangler."

printf '\n=== VERSJONER ===\n'
python --version
uv --version
rustc --version
cargo --version
node --version
npm --version
git --version

TMP="$(mktemp -d "$STATE_DIR/dev-smoke.XXXXXXXX")"
trap 'rm -rf -- "$TMP"' EXIT

printf '\n=== PYTHON (VENV, UTEN NETT) ===\n'
python -m venv "$TMP/venv"
"$TMP/venv/bin/python" -c 'print("PYTHON_TEST_PASS=1")'

printf '\n=== C++20 ===\n'
cat > "$TMP/test.cpp" <<'CPP'
#include <iostream>
int main() { std::cout << "CPP_TEST_PASS=1\n"; }
CPP
g++ -std=c++20 -O2 "$TMP/test.cpp" -o "$TMP/test-cpp"
"$TMP/test-cpp"
clang++ -std=c++20 -O2 "$TMP/test.cpp" -o "$TMP/test-clang"
"$TMP/test-clang"

printf '\n=== RUST ===\n'
cat > "$TMP/test.rs" <<'RUST'
fn main() { println!("RUST_TEST_PASS=1"); }
RUST
rustc "$TMP/test.rs" -o "$TMP/test-rust"
"$TMP/test-rust"

printf '\n=== NODE ===\n'
node -e 'console.log("NODE_TEST_PASS=1")'

printf '\nDEVELOPMENT_VERIFY_PASS=1\n'
mark_step '02b-verify-development-tools'
show_next './scripts/03-install-or-verify-llama-vulkan.sh'
