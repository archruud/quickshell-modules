#!/usr/bin/env python3
"""Check external prerequisites and known source regressions (not runtime QML)."""
import shutil
import subprocess
from pathlib import Path
import sys

print("ARCHRUUD Kairos original-port prerequisites:")
for name in ("qs", "python3", "nmcli", "ip", "brightnessctl", "wpctl", "bluetoothctl"):
    print(f"  {name:<15} {'available' if shutil.which(name) else 'NOT FOUND (some features unavailable)'}")
if shutil.which("fc-match"):
    family = subprocess.run(
        ["fc-match", "-f", "%{family}\n", "Material Symbols Rounded"],
        check=False, capture_output=True, text=True,
    ).stdout.strip()
    if "Material Symbols Rounded" in family:
        print("Material Symbols Rounded: installed (OK)")
    else:
        print("WARNING: Material Symbols Rounded was not detected.")
        print("Install: sudo pacman -S ttf-material-symbols-variable && fc-cache -f")
else:
    print("WARNING: cannot check icon font (fontconfig / fc-match not found).")
icons = Path(__file__).resolve().parent.parent / "barkit" / "MaterialIcon.qml"
if 'font.family: "Material Symbols Rounded"' not in icons.read_text(encoding="utf-8"):
    sys.exit("ERROR: MaterialIcon.qml lacks the required Material Symbols font binding")
print("MaterialIcon.qml font binding: present (OK)")
network = Path(__file__).resolve().parent.parent / "services" / "Network.qml"
source = network.read_text(encoding="utf-8")
if "StdioCollector { id: result };" in source:
    sys.exit("ERROR: invalid QML semicolon after the Network StdioCollector object")
print("Known Network.qml semicolon regression: not found (OK)")
shell = Path(__file__).resolve().parent.parent / "shell.qml"
scene = Path(__file__).resolve().parent.parent / "Scene.qml"
shell_source = shell.read_text(encoding="utf-8")
scene_source = scene.read_text(encoding="utf-8")
if "delegate: Component" not in shell_source or "Scene { }" not in shell_source:
    sys.exit("ERROR: missing explicit per-screen Scene delegate in shell.qml")
if "Scope {\n    id: scene" not in scene_source:
    sys.exit("ERROR: Scene must be a non-visual Scope, not a zero-sized Item")
if "required property var modelData" not in scene_source:
    sys.exit("ERROR: Scene does not declare the screen modelData property")
print("Variants/Scene screen property wiring: expected source pattern present (OK)")
print("This is not a full QML compile test; start qs to check runtime loading.")

# Native notifications in v0.3.9 are optional and must not steal a live D-Bus name.
import subprocess as _subprocess
_probe = _subprocess.run([sys.executable, str(Path(__file__).parent / "notifications_control.py"), "probe"],
                         text=True, capture_output=True, check=False, timeout=8)
print("Native Quickshell notifications:", _probe.stdout.strip() if _probe.returncode == 0 else "probe failed")
print("See NOTIFICATIONS.md in the release package for safe enable/disable steps.")
