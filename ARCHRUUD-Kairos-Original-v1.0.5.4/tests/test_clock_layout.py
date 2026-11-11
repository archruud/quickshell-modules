#!/usr/bin/env python3
"""Static regression checks for the approved v0.3.7 clock layout (no Qt required)."""
from pathlib import Path
base = Path(__file__).resolve().parents[1] / "config/quickshell/archruud-kairos-original"
island = (base / "components/Island.qml").read_text()
start = island.index("id: timeLabel")
end = island.index("C.DateWheel {", start)
block = island[start:end]
assert "anchors.verticalCenter: parent.verticalCenter" not in block
assert "y: Math.round(cfg.padTop)" in block
assert "anchors.horizontalCenterOffset" in block
assert "cfg.padLeft" in block and "cfg.padRight" in block
assert "readonly property real clockWidth" in island
assert "readonly property string hoverDateLabel" in island
assert "C.DateWheel" in island
assert "quickSettingsToggled" in island
print("Approved clock layout regression checks: PASS")
