// ARCHRUUD Kairos ORIGINAL standalone test port v0.3.9, based on Ryoku/Kairos.
// Screens are instantiated by Quickshell Variants; modelData is injected into
// the Scene Scope delegate before its PanelWindow children are constructed.
import QtQuick
import Quickshell
import Quickshell.Io
import "services" as S

ShellRoot {
    id: root
    // A single IPC receiver handles the standalone Power Menu process.
    // Do not launch another Kairos instance: this endpoint is in the running one.
    property bool powerCompanionOpen: false
    IpcHandler {
        target: "kairosPowerCompanion"
        function open(): void { root.powerCompanionOpen = true }
        function close(): void { root.powerCompanionOpen = false }
    }
    // Force creation of the notifications singleton at startup even if the
    // Quick Settings Home page has not been opened yet.
    readonly property string notificationMode: S.Notifs.status
    Variants {
        model: Quickshell.screens
        delegate: Component {
            Scene { powerCompanionOpen: root.powerCompanionOpen }
        }
    }
}
