import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Standalone Quickshell picker: does not require other ARCHRUUD modules.
ShellRoot {
    PanelWindow {
        id: picker
        width: 564
        height: 580
        color: "transparent"
        aboveWindows: true
        focusable: true
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        property color backgroundColor: "#0f172a"
        property color cardColor: "#1e293b"
        property color accentColor: "#60a5fa"
        property string script: Quickshell.shellPath("recorder.sh")

        property var choices: [
            { title: "Lav kvalitet", detail: "15 FPS · CRF 30", profile: "low", sound: "on", audio: "Med lyd" },
            { title: "Lav kvalitet", detail: "15 FPS · CRF 30", profile: "low", sound: "off", audio: "Uten lyd" },
            { title: "Middels kvalitet", detail: "30 FPS · CRF 23", profile: "medium", sound: "on", audio: "Med lyd" },
            { title: "Middels kvalitet", detail: "30 FPS · CRF 23", profile: "medium", sound: "off", audio: "Uten lyd" },
            { title: "Full kvalitet", detail: "60 FPS · CRF 16", profile: "full", sound: "on", audio: "Med lyd" },
            { title: "Full kvalitet", detail: "60 FPS · CRF 16", profile: "full", sound: "off", audio: "Uten lyd" }
        ]

        function startRecording(profile, sound) {
            Quickshell.execDetached(["bash", picker.script, "start", profile, sound, nameField.text]);
            Qt.quit();
        }

        function stopRecording() {
            Quickshell.execDetached(["bash", picker.script, "stop"]);
            Qt.quit();
        }

        HyprlandFocusGrab {
            id: focusGrab
            windows: [picker]
            active: true
            onCleared: Qt.quit()
        }

        Rectangle {
            anchors.fill: parent
            color: picker.backgroundColor
            radius: 18
            border.color: "#334155"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 15

                Text {
                    text: "ARCHRUUD  /  SCREEN RECORDER"
                    color: picker.accentColor
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Text {
                    text: "Velg navn og opptakskvalitet"
                    color: "#f8fafc"
                    font.pixelSize: 21
                    font.bold: true
                }

                TextField {
                    id: nameField
                    width: parent.width
                    height: 47
                    placeholderText: "Filnavn (uten .mp4) – tomt = automatisk navn"
                    font.pixelSize: 14
                    color: "#f8fafc"
                    placeholderTextColor: "#94a3b8"
                    selectByMouse: true
                    focus: true
                    background: Rectangle {
                        color: picker.cardColor
                        radius: 9
                        border.color: nameField.activeFocus ? picker.accentColor : "#334155"
                        border.width: 1
                    }
                    Keys.onEscapePressed: Qt.quit()
                }

                Text {
                    text: "Velg ett av seks opptakstyper:"
                    color: "#cbd5e1"
                    font.pixelSize: 14
                }

                Grid {
                    columns: 2
                    spacing: 10
                    Repeater {
                        model: picker.choices
                        Rectangle {
                            width: 253
                            height: 81
                            radius: 10
                            color: mouse.containsMouse ? "#2b4262" : picker.cardColor
                            border.color: mouse.containsMouse ? picker.accentColor : "#334155"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: modelData.title + "  ·  " + modelData.audio
                                    color: "#f8fafc"
                                    font.bold: true
                                    font.pixelSize: 13
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: modelData.detail
                                    color: "#94a3b8"
                                    font.pixelSize: 12
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: picker.startRecording(modelData.profile, modelData.sound)
                            }
                        }
                    }
                }

                Row {
                    spacing: 12
                    Rectangle {
                        width: 170
                        height: 41
                        radius: 8
                        color: "#7f1d1d"
                        Text {
                            anchors.centerIn: parent
                            text: "Stopp opptak"
                            color: "white"
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: picker.stopRecording()
                        }
                    }
                    Rectangle {
                        width: 112
                        height: 41
                        radius: 8
                        color: "#334155"
                        Text {
                            anchors.centerIn: parent
                            text: "Avbryt  Esc"
                            color: "#f8fafc"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.quit()
                        }
                    }
                }
                Text {
                    text: "Lagring: ~/Bilder/Skjermopptak  ·  Velg område med musen etterpå"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }
            }
        }
    }
}
