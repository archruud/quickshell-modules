pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"

// Small, non-reserving popups; Kairos itself remains untouched.
// Only visible when our Quickshell server is explicitly enabled.
PanelWindow {
    id: popups
    required property var targetScreen
    screen: popups.targetScreen
    visible: Notifs.status === "active" && Notifs.toasts.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: 66; right: 16 }
    implicitWidth: 364
    implicitHeight: Math.max(1, stack.implicitHeight)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "archruud-kairos-notifications"

    Column {
        id: stack
        width: popups.width
        spacing: 8

        Repeater {
            model: Notifs.toasts
            delegate: Rectangle {
                id: alert
                required property var modelData
                width: stack.width
                height: 94
                radius: 16
                color: "#081522"
                border.width: 1
                border.color: "#39A8F0"

                Rectangle {
                    id: accentLine
                    anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 13; bottom: parent.bottom; bottomMargin: 13 }
                    width: 3
                    radius: 2
                    color: "#39A8F0"
                }
                Column {
                    anchors {
                        left: accentLine.right; leftMargin: 12
                        right: closeButton.left; rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 4
                    Text {
                        width: parent.width
                        text: String(alert.modelData.appName || "Application")
                        color: "#79C9FF"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                    Text {
                        width: parent.width
                        text: String(alert.modelData.summary || "Notification")
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: String(alert.modelData.body || "")
                        color: "#AAB9C7"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }
                Rectangle {
                    id: closeButton
                    anchors { right: parent.right; top: parent.top; margins: 8 }
                    width: 25
                    height: 25
                    radius: 8
                    color: closeHover.hovered ? "#173047" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: "#B4DFFF"
                        font.pixelSize: 18
                    }
                    HoverHandler { id: closeHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.closeToast(alert.modelData.key)
                    }
                }
            }
        }
    }
}
