#!/usr/bin/env python3
"""Check Quickshell Music/MPRIS wiring without pretending to run QML."""
from pathlib import Path
base = Path(__file__).resolve().parents[1] / "config/quickshell/archruud-kairos-original"
media = (base / "services/Media.qml").read_text()
music = (base / "components/MusicSurface.qml").read_text()
island = (base / "components/Island.qml").read_text()
assert "import Quickshell.Services.Mpris" in media
assert "Mpris.players.values" in media
assert "function choose()" in media
assert "function cyclePlayer()" in media
assert "selectedDbusName" in media
assert "trackTitle" in media
assert "Media.cyclePlayer()" in music
assert "surface.player.canTogglePlaying" in music
assert "surface.player.canGoPrevious" in music
assert "surface.player.canGoNext" in music
assert "surface.player.positionSupported" in music
assert "surface.player.lengthSupported" in music
assert "trackArtists" not in music
assert "C.MusicSurface" in island
print("MPRIS source wiring static checks: PASS")
