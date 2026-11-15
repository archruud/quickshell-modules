import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Dedicated, click-to-stop badge. Independent of shell.qml's chooser.
ShellRoot {
    PanelWindow {
        id: recBadge
        anchors {
            top: true
            right: true
        }
        margins {
            top: 14
            right: 18
        }
        implicitWidth: 104
        implicitHeight: 43
        color: "transparent"
        aboveWindows: true
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay

        Rectangle {
            anchors.fill: parent
            color: mouse.containsMouse ? "#991b1b" : "#b91c1c"
            radius: 10
            border.color: "#fecaca"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 9
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10
                    height: 10
                    radius: 5
                    color: "#ffffff"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.35; duration: 550 }
                        NumberAnimation { to: 1.0; duration: 550 }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "REC"
                    color: "white"
                    font.pixelSize: 17
                    font.bold: true
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Stop request is asynchronous so UI remains responsive.
                    Quickshell.execDetached(["bash", Quickshell.shellPath("recorder.sh"), "stop"]);
                }
            }
        }

        // Poll the recorder's authoritative PID state. Close this Quickshell
        // window after recording ends, even if stopped by the keyboard.
        Process {
            id: recordingStatus
            command: ["bash", Quickshell.shellPath("recorder.sh"), "status"]
            running: true
            onExited: (exitCode, exitStatus) => {
                if (exitCode !== 0) Qt.quit();
            }
        }
        Timer {
            interval: 700
            running: true
            repeat: true
            onTriggered: {
                if (!recordingStatus.running) recordingStatus.running = true;
            }
        }
    }
}
