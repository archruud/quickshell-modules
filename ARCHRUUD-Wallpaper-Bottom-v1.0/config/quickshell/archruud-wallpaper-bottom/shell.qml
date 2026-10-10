import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property string wallpaperDir: Quickshell.env("HOME") + "/.config/hypr/wallpapers"
    property string selectedWallpaper: ""
    property var wallpapers: []
    property string filterMode: "all"
    property bool panelOpen: false
    property string statusText: "Ready"
    property int rows: 2
    property int selectedIndex: 0
    function displayName(path) { return path.split("/").pop().replace(/\.[^.]+$/, "") }
    function fileUrl(path) { return "file://" + encodeURI(path) }
    function isDark(path) { return displayName(path).toLowerCase().startsWith("dark-") }
    function isLight(path) { return displayName(path).toLowerCase().startsWith("light-") }
    function visibleWallpapers() {
        return wallpapers.filter(function(p) {
            return filterMode === "all" || (filterMode === "dark" && isDark(p)) || (filterMode === "light" && isLight(p))
        })
    }
    function refresh() { listProcess.exec(["bash", Quickshell.shellPath("scripts/list-wallpapers.sh"), wallpaperDir]) }
    function applyWallpaper(path) {
        if (!path) return
        applyProcess.exec(["bash", Quickshell.shellPath("scripts/set-wallpaper.sh"), path])
        idle.restart()
    }
    function openPanel() { panelOpen = true; selectedIndex = 0; refresh(); idle.restart() }
    function closePanel() { panelOpen = false; idle.stop() }
    function togglePanel() { if (panelOpen) closePanel(); else openPanel() }
    function selectRelative(delta) {
        const items = visibleWallpapers()
        if (items.length === 0) return
        selectedIndex = Math.max(0, Math.min(items.length - 1, selectedIndex + delta))
        idle.restart()
    }

    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = text.trim() ? text.trim().split("\n").filter(function(p) { return p.length > 0 }) : []
                root.statusText = root.wallpapers.length + " wallpapers"
            }
        }
    }
    Process {
        id: applyProcess
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) root.selectedWallpaper = text.trim()
                root.statusText = "Wallpaper applied"
            }
        }
    }
    Process {
        id: restoreProcess
        stdout: StdioCollector { onStreamFinished: { if (text.trim()) root.selectedWallpaper = text.trim() } }
    }
    Component.onCompleted: {
        refresh()
        restoreProcess.exec(["bash", Quickshell.shellPath("scripts/restore-wallpaper.sh"), wallpaperDir])
    }
    IpcHandler {
        target: "wallpaperBottom"
        function toggle(): void { root.togglePanel() }
        function open(): void { root.openPanel() }
        function close(): void { root.closePanel() }
    }
    Timer {
        id: idle
        interval: 5000
        repeat: false
        onTriggered: root.closePanel()
    }
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
            WlrLayershell.namespace: "archruud-wallpaper-bottom-test"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            // Bottom-attached notch: the shoulders flow into the screen edge.
            // Only the upper edge is outlined; the bottom has no rounded corners.
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
                        Text { text: "ARCHRUUD WALLPAPER"; color: "#EAF6FF"; font.bold: true; font.pixelSize: 18 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.statusText; color: "#8DBDE8"; font.pixelSize: 11 }
                        Button { text: "All"; onClicked: { root.filterMode = "all"; root.selectedIndex = 0; grid.contentX = 0; idle.restart() } }
                        Button { text: "Dark"; onClicked: { root.filterMode = "dark"; root.selectedIndex = 0; grid.contentX = 0; idle.restart() } }
                        Button { text: "Light"; onClicked: { root.filterMode = "light"; root.selectedIndex = 0; grid.contentX = 0; idle.restart() } }
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
                        model: root.visibleWallpapers()
                        focus: root.panelOpen
                        keyNavigationEnabled: false
                        currentIndex: root.selectedIndex
                        onCurrentIndexChanged: {
                            if (currentIndex >= 0 && currentIndex !== root.selectedIndex)
                                root.selectedIndex = currentIndex
                        }
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Right) { root.selectRelative(2); event.accepted = true }
                            else if (event.key === Qt.Key_Left) { root.selectRelative(-2); event.accepted = true }
                            else if (event.key === Qt.Key_Down) { root.selectRelative(1); event.accepted = true }
                            else if (event.key === Qt.Key_Up) { root.selectRelative(-1); event.accepted = true }
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.applyWallpaper(root.visibleWallpapers()[root.selectedIndex]); event.accepted = true
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
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 3
                                    Image {
                                        width: parent.width
                                        height: 94
                                        source: root.fileUrl(modelData)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                    }
                                    Text {
                                        width: parent.width
                                        text: root.displayName(modelData)
                                        color: "#EAF6FF"
                                        font.pixelSize: 12
                                        elide: Text.ElideMiddle
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: idle.stop()
                                    onExited: idle.restart()
                                    onClicked: {
                                        root.selectedIndex = index
                                        grid.forceActiveFocus()
                                        root.applyWallpaper(modelData)
                                    }
                                }
                            }
                        }
                    }
                    Text { text: "SUPER+W · mouse wheel / arrows to browse · Enter to apply · Esc to close"; color: "#8DBDE8"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
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
    }
