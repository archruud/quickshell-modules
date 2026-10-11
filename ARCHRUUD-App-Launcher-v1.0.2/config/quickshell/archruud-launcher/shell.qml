import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    // User setting: 5000 = 5 seconds, 3000 = 3 seconds.
    property int autoCloseMs: 5000
    property var apps: []
    property bool panelOpen: false
    property int selectedIndex: 0
    property string statusText: "Loading applications"
    property string query: ""
    function shownApps() {
        const q = query.trim().toLowerCase()
        return q ? apps.filter(function(a) { return a.name.toLowerCase().includes(q) }) : apps
    }
    function refresh() { listProcess.exec(["python3", Quickshell.shellPath("scripts/list-apps.py")]) }
    function openPanel() {
        closeWallpaper.exec(["qs", "ipc", "-c", "archruud-wallpaper-bottom", "call", "wallpaperBottom", "close"])
        panelOpen = true
        selectedIndex = 0
        query = ""
        refresh()
        idle.restart()
    }
    function closePanel() { panelOpen = false; idle.stop() }
    function togglePanel() { if (panelOpen) closePanel(); else openPanel() }
    function move(delta) {
        const a = shownApps()
        if (!a.length) return
        selectedIndex = Math.max(0, Math.min(a.length - 1, selectedIndex + delta))
        idle.restart()
    }
    function launch(app) {
        if (!app || !app.path) return
        launchProcess.exec(["gio", "launch", app.path])
        closePanel()
    }
    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.apps = JSON.parse(text)
                    root.statusText = root.apps.length + " apps"
                } catch(e) { root.statusText = "Application list error" }
            }
        }
    }
    Process { id: launchProcess }
    Process { id: closeWallpaper }
    Component.onCompleted: refresh()
    IpcHandler {
        target: "appLauncher"
        function toggle(): void { root.togglePanel() }
        function open(): void { root.openPanel() }
        function close(): void { root.closePanel() }
    }
    Timer { id: idle; interval: root.autoCloseMs; repeat: false; onTriggered: root.closePanel() }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: root.panelOpen
            anchors { bottom: true }
            implicitWidth: Math.min(1260, Math.max(792, screen.width * 0.86))
            implicitHeight: 344
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-app-launcher"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            Canvas {
                id: notchShape
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    const w = width, h = height
                    // Straight sides, rounded upper corners and outward lower shoulders.
                    const shoulder = 38
                    const corner = 16
                    const left = shoulder
                    const right = w - shoulder
                    const bottomCurveStart = h - 22
                    function outline() {
                        ctx.beginPath()
                        ctx.moveTo(0, h)
                        ctx.quadraticCurveTo(left, h, left, bottomCurveStart)
                        ctx.lineTo(left, corner)
                        ctx.quadraticCurveTo(left, 0, left + corner, 0)
                        ctx.lineTo(right - corner, 0)
                        ctx.quadraticCurveTo(right, 0, right, corner)
                        ctx.lineTo(right, bottomCurveStart)
                        ctx.quadraticCurveTo(right, h, w, h)
                    }
                    outline()
                    ctx.closePath()
                    ctx.fillStyle = "#080D14"
                    ctx.fill()
                    outline()
                    ctx.strokeStyle = "#39A8F0"
                    ctx.lineWidth = 1.5
                    ctx.stroke()
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 54
                anchors.rightMargin: 54
                anchors.topMargin: 12
                anchors.bottomMargin: 5
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "ARCHRUUD APPS"; color: "#EAF6FF"; font.bold: true; font.pixelSize: 18 }
                    Item { Layout.fillWidth: true }
                    Text { text: root.statusText; color: "#8DBDE8"; font.pixelSize: 11 }
                    Button { text: "Refresh"; onClicked: { root.refresh(); idle.restart() } }
                    Button { text: "×"; onClicked: root.closePanel() }
                }
                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                    Layout.maximumHeight: 260
                    clip: true
                    flow: GridView.FlowTopToBottom
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.HorizontalFlick
                    cellWidth: Math.floor(width / 5)
                    cellHeight: 130
                    model: root.shownApps()
                    focus: root.panelOpen
                    keyNavigationEnabled: false
                    currentIndex: root.selectedIndex
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex !== root.selectedIndex)
                            root.selectedIndex = currentIndex
                    }
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Right) { root.move(2); event.accepted = true }
                        else if (event.key === Qt.Key_Left) { root.move(-2); event.accepted = true }
                        else if (event.key === Qt.Key_Down) { root.move(1); event.accepted = true }
                        else if (event.key === Qt.Key_Up) { root.move(-1); event.accepted = true }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launch(root.shownApps()[root.selectedIndex]); event.accepted = true
                        } else if (event.key === Qt.Key_Escape) { root.closePanel(); event.accepted = true }
                    }
                    onMovementStarted: idle.stop()
                    onMovementEnded: idle.restart()
                    WheelHandler {
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: function(event) {
                            const amount = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                            grid.contentX = Math.max(0, Math.min(grid.contentWidth - grid.width,
                                grid.contentX - amount / 120 * grid.cellWidth))
                            idle.restart()
                            event.accepted = true
                        }
                    }
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            color: "#0D1724"
                            border.color: root.selectedIndex === index ? "#39A8F0" : "#233A55"
                            border.width: root.selectedIndex === index ? 2 : 1
                            radius: 8
                            Column {
                                anchors.centerIn: parent
                                width: parent.width - 10
                                spacing: 7
                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 70; height: 70
                                    source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.name
                                    color: "#EAF6FF"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: idle.stop()
                                onExited: idle.restart()
                                onClicked: { root.selectedIndex = index; grid.forceActiveFocus(); idle.restart() }
                                onDoubleClicked: root.launch(modelData)
                            }
                        }
                    }
                }
                Text {
                    text: "SUPER+A / left-click bottom edge · wheel / arrows to browse · double-click / Enter to launch · Esc to close"
                    color: "#8DBDE8"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                onEntered: idle.stop()
                onExited: idle.restart()
            }
        }
    }
    // Bottom-center edge trigger: open only on a left mouse click.
    // Plain hover does not open the panel. SUPER+A remains unchanged.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { bottom: true }
            implicitWidth: Math.min(1260, Math.max(792, screen.width * 0.86))
            implicitHeight: 8
            visible: !root.panelOpen
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-launcher-edge"
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: false
                onClicked: root.openPanel()
            }
        }
    }
}
