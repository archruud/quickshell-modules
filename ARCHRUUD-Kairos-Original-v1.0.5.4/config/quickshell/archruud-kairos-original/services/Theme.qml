pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root
  readonly property color shadow: "#080D14"
  readonly property color primary: "#39A8F0"
  readonly property color error: "#ed7777"
  readonly property string mono: "JetBrainsMono Nerd Font"
  readonly property string fontPrimary: "Sans"
  function ink(fill, n) { return Qt.rgba(0.92,0.97,1.0,1.0); }
  function joinArtists(artists, fallback) {
    return artists && artists.length ? artists.join(", ") : String(fallback || "");
  }
}
