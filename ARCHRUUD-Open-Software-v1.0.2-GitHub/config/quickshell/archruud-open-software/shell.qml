import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    // 5000 = 5 seconds; change to 3000 for 3 seconds.
    property int autoCloseMs: 5000
    property bool panelOpen: false
    property var windows: []
    property int selectedIndex: 0
    property string statusText: "Loading windows"
    // Match the Power Menu's 142px-wide edge shell and 73px tiles.
    // 47px is reserved at both ends for the two outward shoulders.
    property int rowHeight: 73
    property int rowSpacing: 5
    function panelHeight(screenHeight) {
        const count = Math.max(1, windows.length)
        const natural = 94 + count * rowHeight + (count - 1) * rowSpacing
        return Math.min(natural, 744, Math.max(120, screenHeight - 32))
    }
    function displayName(value) {
        const raw = String(value || "Application")
        const last = raw.split(".").pop().replace(/[-_]/g, " ")
        return last.charAt(0).toUpperCase() + last.slice(1)
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.exec(["python3", Quickshell.shellPath("scripts/list-windows.py")])
    }
    function openPanel() {
        panelOpen = true
        selectedIndex = 0
        refresh()
        idle.restart()
    }
    function closePanel() { panelOpen = false; idle.stop() }
    function togglePanel() { if (panelOpen) closePanel(); else openPanel() }
    function move(delta) {
        if (!windows.length) return
        selectedIndex = Math.max(0, Math.min(windows.length - 1, selectedIndex + delta))
        idle.restart()
    }
    function activate(win) {
        if (!win || !win.address) return
        focusProcess.exec(["python3", Quickshell.shellPath("scripts/focus-window.py"), win.address])
        closePanel()
    }
    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.windows = JSON.parse(text)
                    root.statusText = root.windows.length + " open windows"
                    if (root.selectedIndex >= root.windows.length) root.selectedIndex = 0
                } catch (e) { root.statusText = "Window list error" }
            }
        }
    }
    Process { id: focusProcess }
    IpcHandler {
        target: "openSoftware"
        function toggle(): void { root.togglePanel() }
        function open(): void { root.openPanel() }
        function close(): void { root.closePanel() }
        function refresh(): void { root.refresh() }
    }
    Timer { id: idle; interval: root.autoCloseMs; repeat: false; onTriggered: root.closePanel() }
    Timer { interval: 1700; running: root.panelOpen; repeat: true; onTriggered: root.refresh() }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: root.panelOpen
            anchors { left: true }
            implicitWidth: 142
            implicitHeight: root.panelHeight(screen.height)
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-open-software"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            // Exact mirrored silhouette of ARCHRUUD Power Menu: dark shell,
            // thin cyan outline, open toward the left screen edge.
            Canvas {
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const c = getContext("2d")
                    c.reset()
                    const w = width, h = height
                    const edge = 0.5
                    const bodyRight = w - 18.5
                    const top = 44.5
                    const bottom = h - 44.5
                    function silhouette() {
                        c.beginPath()
                        c.moveTo(0, edge)
                        c.bezierCurveTo(4, 27, 13, top, 40, top)
                        c.lineTo(bodyRight - 26, top)
                        c.bezierCurveTo(bodyRight - 9, top, bodyRight, top + 10, bodyRight, top + 28)
                        c.lineTo(bodyRight, bottom - 28)
                        c.bezierCurveTo(bodyRight, bottom - 10, bodyRight - 9, bottom, bodyRight - 26, bottom)
                        c.lineTo(40, bottom)
                        c.bezierCurveTo(13, bottom, 4, h - 27, 0, h - edge)
                    }
                    silhouette()
                    c.closePath()
                    c.fillStyle = "#080F1B"
                    c.fill()
                    silhouette()
                    c.strokeStyle = "#38B7FF"
                    c.lineWidth = 1.4
                    c.stroke()
                }
            }
            ListView {
                id: list
                anchors.fill: parent
                anchors.leftMargin: 7
                anchors.rightMargin: 28
                anchors.topMargin: 47
                anchors.bottomMargin: 47
                clip: true
                spacing: root.rowSpacing
                boundsBehavior: Flickable.StopAtBounds
                model: root.windows
                focus: root.panelOpen
                keyNavigationEnabled: false
                currentIndex: root.selectedIndex
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
                        root.move(1); list.positionViewAtIndex(root.selectedIndex, ListView.Contain); event.accepted = true
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                        root.move(-1); list.positionViewAtIndex(root.selectedIndex, ListView.Contain); event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.activate(root.windows[root.selectedIndex]); event.accepted = true
                    } else if (event.key === Qt.Key_Escape) { root.closePanel(); event.accepted = true }
                }
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: function(event) {
                        const amount = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                        list.contentY = Math.max(0, Math.min(Math.max(0, list.contentHeight - list.height),
                            list.contentY - amount / 120 * (root.rowHeight + root.rowSpacing)))
                        idle.restart()
                        event.accepted = true
                    }
                }
                delegate: Rectangle {
                    id: tile
                    required property var modelData
                    required property int index
                    width: list.width
                    height: root.rowHeight
                    radius: 13
                    color: tileMouse.containsMouse ? "#18334B" : "#0D1B2C"
                    border.color: tileMouse.containsMouse || root.selectedIndex === index ? "#55C8FF" : "#254B6B"
                    border.width: 1
                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        spacing: 2
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 32; height: 32; radius: 16
                            color: "#102E46"
                            border.color: "#43B9FF"
                            border.width: 1
                            Image {
                                anchors.centerIn: parent
                                width: 23; height: 23
                                source: Quickshell.iconPath(modelData.icon || "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: root.displayName(modelData.name)
                            color: "#EAF6FF"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: "WS " + modelData.workspaceName
                            color: "#8DBDE8"
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: idle.stop()
                        onExited: idle.restart()
                        // Preserve the fully working single-click Lua focus logic.
                        onClicked: {
                            root.selectedIndex = index
                            root.activate(modelData)
                        }
                    }
                    // Compact tiles remain distinct even when one application
                    // has multiple windows; the full title is available on hover.
                    ToolTip.visible: tileMouse.containsMouse && root.panelOpen
                    ToolTip.delay: 600
                    ToolTip.text: String(modelData.name) + "\n" + String(modelData.title) + "\nWorkspace " + String(modelData.workspaceName)
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.windows.length === 0
                    text: "No windows"
                    color: "#8DBDE8"
                    font.pixelSize: 10
                }
            }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.NoButton
                hoverEnabled: true
                onEntered: idle.stop()
                onExited: idle.restart()
            }
        }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { left: true }
            implicitWidth: 2
            implicitHeight: root.panelHeight(screen.height)
            visible: !root.panelOpen
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-open-software-edge"
            MouseArea {
                anchors.fill: parent; hoverEnabled: true
                onEntered: root.openPanel()
            }
        }
    }
}
