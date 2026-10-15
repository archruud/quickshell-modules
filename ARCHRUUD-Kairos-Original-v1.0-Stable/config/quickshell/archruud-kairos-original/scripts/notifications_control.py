#!/usr/bin/env python3
"""Safe opt-in for the ARCHRUUD Kairos Quickshell notification server.

This never stops another user's daemon or attempts to take a live D-Bus name.
A QML startup probe calls `probe` and loads NotificationServer only if opted-in
and the D-Bus notification name has no owner. No notification data is written.
"""
from __future__ import annotations
import os
from pathlib import Path
import re
import subprocess
import sys

FLAG = (Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
        / "archruud" / "kairos-original" / "notifications.enabled")
NAME = "org.freedesktop.Notifications"


def dbus_owner():
    try:
        p = subprocess.run(
            ["gdbus", "call", "--session", "--dest", "org.freedesktop.DBus",
             "--object-path", "/org/freedesktop/DBus",
             "--method", "org.freedesktop.DBus.NameHasOwner", NAME],
            capture_output=True, text=True, timeout=5, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if p.returncode != 0:
        return None
    m = re.fullmatch(r"\(\s*(true|false)\s*,?\s*\)", p.stdout.strip(), re.I)
    return (m.group(1).lower() == "true") if m else None


def notification_owner_pid():
    """Return the process ID owning the notification bus name, if verifiable."""
    base = ["gdbus", "call", "--session", "--dest", "org.freedesktop.DBus",
            "--object-path", "/org/freedesktop/DBus", "--method"]
    try:
        who = subprocess.run(base + ["org.freedesktop.DBus.GetNameOwner", NAME],
                             capture_output=True, text=True, timeout=5, check=False)
        if who.returncode != 0:
            return None
        match = re.fullmatch(r"\(\s*'(:[0-9]+\.[0-9]+)'\s*,?\s*\)", who.stdout.strip())
        if not match:
            return None
        result = subprocess.run(
            base + ["org.freedesktop.DBus.GetConnectionUnixProcessID", match.group(1)],
            capture_output=True, text=True, timeout=5, check=False)
        if result.returncode != 0:
            return None
        pid_match = re.fullmatch(r"\(\s*(?:uint32\s+)?([0-9]+)\s*,?\s*\)",
                                 result.stdout.strip())
        return int(pid_match.group(1)) if pid_match else None
    except (OSError, subprocess.TimeoutExpired):
        return None


def owner_is_kairos():
    """Verify the actual D-Bus owner process, not just an unrelated qs instance."""
    pid = notification_owner_pid()
    if pid is None or pid <= 0:
        return False
    try:
        args = [part.decode("utf-8", "replace") for part in
                Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0") if part]
    except OSError:
        return False
    if not args or Path(args[0]).name not in ("qs", "quickshell"):
        return False
    for index, arg in enumerate(args[:-1]):
        if arg == "-c" and args[index + 1] == "archruud-kairos-original":
            return True
        if arg == "-p" and "archruud-kairos-original" in args[index + 1]:
            return True
    return False


def status_mode():
    """For humans only. Startup probe MUST still reject any existing bus owner."""
    current = mode()
    if current == "conflict" and owner_is_kairos():
        return "running"
    return current


def mode():
    if not FLAG.is_file():
        return "disabled"
    owner = dbus_owner()
    if owner is True:
        return "conflict"
    if owner is False:
        return "active"
    return "error"


def main(argv):
    cmd = argv[1] if len(argv) > 1 else "status"
    if cmd == "probe":
        print(mode())
        return 0
    if cmd == "status":
        state = status_mode()
        print("ARCHRUUD Kairos notifications:", state)
        if state == "running":
            print("OK: ARCHRUUD Kairos itself owns org.freedesktop.Notifications on session D-Bus.")
        elif state == "conflict":
            print("The notification D-Bus name is owned by a process that could not be verified as Kairos.")
            print("Inspect the owner before changing running notification services.")
            print("Try: pgrep -af 'dunst|mako|swaync|notification|qs'")
        elif state == "disabled":
            print("The existing desktop notification daemon has not been changed.")
        elif state == "active":
            print("No D-Bus owner was detected. Restart Kairos to claim notification ownership.")
        else:
            print("Cannot check session D-Bus. Server will stay disabled for safety.")
        return 0
    if cmd == "enable":
        owner = dbus_owner()
        if owner is not False:
            print("Cannot enable: notification name is owned, or D-Bus check failed.", file=sys.stderr)
            print("Nothing changed. Identify the existing daemon first.", file=sys.stderr)
            print("Try: pgrep -af 'dunst|mako|swaync|notification'", file=sys.stderr)
            return 2
        FLAG.parent.mkdir(parents=True, exist_ok=True)
        FLAG.write_text("ARCHRUUD Kairos notification server opt-in\n")
        FLAG.chmod(0o600)
        print("Opt-in enabled. Restart Kairos to start the Quickshell notification server.")
        print("NOTE: if a different daemon starts first, Kairos will refuse to activate.")
        return 0
    if cmd == "disable":
        FLAG.unlink(missing_ok=True)
        print("Opt-in disabled. Restart Kairos to release notification ownership.")
        print("Your previous daemon is NOT automatically reactivated.")
        return 0
    print("Usage: notifications.sh status|enable|disable", file=sys.stderr)
    return 2

if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
