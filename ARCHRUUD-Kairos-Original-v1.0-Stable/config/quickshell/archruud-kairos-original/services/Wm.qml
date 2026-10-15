pragma Singleton
import QtQuick
import Quickshell

Singleton {
  readonly property var caps: ({outputMirror: false})
  readonly property string focusedOutput: ""
}
