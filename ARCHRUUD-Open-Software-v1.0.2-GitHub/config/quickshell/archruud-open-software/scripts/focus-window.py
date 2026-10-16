#!/usr/bin/env python3
"""Focus an existing Hyprland window using the verified Lua dispatcher."""
import json
import re
import subprocess
import sys


def hyprctl(*args):
    return subprocess.run(["hyprctl", *args], capture_output=True, text=True, timeout=5, check=True)


def main():
    if len(sys.argv) != 2 or not re.fullmatch(r"(?:0[xX])?[0-9a-fA-F]+", sys.argv[1]):
        sys.exit("Invalid window address")
    address = sys.argv[1].lower()
    if not address.startswith("0x"):
        address = "0x" + address
    clients = json.loads(hyprctl("-j", "clients").stdout)
    if not any(str(c.get("address", "")).lower() == address for c in clients):
        sys.exit("Window no longer exists")
    result = hyprctl("dispatch", f"hl.dsp.focus({{ window = 'address:{address}' }})")
    if result.stdout.strip().lower() != "ok":
        sys.exit(f"Focus not confirmed: {result.stdout.strip() or result.stderr.strip()}")


if __name__ == "__main__":
    try:
        main()
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, ValueError, OSError) as exc:
        sys.exit(f"Could not activate window: {exc}")
