// ARCHRUUD Kairos ORIGINAL standalone test port v0.3.9, based on Ryoku/Kairos.
// Screens are instantiated by Quickshell Variants; modelData is injected into
// the Scene Scope delegate before its PanelWindow children are constructed.
import QtQuick
import Quickshell
import "services" as S

ShellRoot {
    // Force creation of the notifications singleton at startup even if the
    // Quick Settings Home page has not been opened yet.
    readonly property string notificationMode: S.Notifs.status
    Variants {
        model: Quickshell.screens
        delegate: Component {
            Scene { }
        }
    }
}
