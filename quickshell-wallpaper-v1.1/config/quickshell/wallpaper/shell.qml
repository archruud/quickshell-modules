//@ pragma StateDir $BASE/archruud/wallpaper
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/.config/hypr/wallpapers"
    property string selectedWallpaper: ""
    property var wallpapers: []
    property string filterMode: "all"
    property bool pickerVisible: false
    property string statusText: "Klar"

    function fileUrl(path) {
        return "file://" + encodeURI(path)
    }

    function displayName(path) {
        var name = path.split("/").pop()
        return name.replace(/\.[^.]+$/, "")
    }

    function isDark(path) {
        return displayName(path).toLowerCase().startsWith("dark-")
    }

    function isLight(path) {
        return displayName(path).toLowerCase().startsWith("light-")
    }

    function visibleWallpapers() {
        if (filterMode === "dark")
            return wallpapers.filter(function(p) { return isDark(p) })
        if (filterMode === "light")
            return wallpapers.filter(function(p) { return isLight(p) })
        return wallpapers
    }

    function refresh() {
        listProcess.exec(["bash", Quickshell.shellPath("scripts/list-wallpapers.sh"), wallpaperDir])
    }

    function applyWallpaper(path) {
        if (!path || path.length === 0)
            return
        statusText = "Setter " + displayName(path) + " …"
        applyProcess.exec(["bash", Quickshell.shellPath("scripts/set-wallpaper.sh"), path])
    }

    function restoreWallpaper() {
        restoreProcess.exec(["bash", Quickshell.shellPath("scripts/restore-wallpaper.sh"), wallpaperDir])
    }

    function togglePicker() {
        pickerVisible = !pickerVisible
        picker.visible = pickerVisible
        if (pickerVisible) {
            picker.requestActivate()
            refresh()
        }
    }

    function closePicker() {
        pickerVisible = false
        picker.visible = false
    }

    Component.onCompleted: {
        restoreWallpaper()
        refresh()
    }

    Process {
        id: listProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().length ? text.trim().split("\n") : []
                root.wallpapers = lines.filter(function(p) { return p.length > 0 })
                root.statusText = root.wallpapers.length + " bakgrunner funnet"
            }
        }
    }

    Process {
        id: applyProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var result = text.trim()
                if (result.length > 0)
                    root.selectedWallpaper = result
                root.statusText = root.selectedWallpaper.length
                    ? "Aktiv: " + root.displayName(root.selectedWallpaper)
                    : "Bakgrunn satt"
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length)
                    root.statusText = "Feil: " + text.trim()
            }
        }
    }

    Process {
        id: restoreProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var result = text.trim()
                if (result.length > 0) {
                    root.selectedWallpaper = result
                    root.statusText = "Aktiv: " + root.displayName(result)
                }
            }
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void { root.togglePicker() }
        function open(): void {
            root.pickerVisible = true
            picker.visible = true
            picker.requestActivate()
            root.refresh()
        }
        function close(): void { root.closePicker() }
        function refresh(): void { root.refresh() }
        function current(): string { return root.selectedWallpaper }
    }

    FloatingWindow {
        id: picker
        visible: false
        title: "ARCHRUUD Wallpaper"
        width: 944
        height: 608
        minimumSize: Qt.size(656, 432)
        maximumSize: Qt.size(1440, 960)

        onClosed: {
            root.pickerVisible = false
            visible = false
        }

        color: "#0b1018"

        Rectangle {
            anchors.fill: parent
            color: "#0b1018"
            border.color: "#00b7ff"
            border.width: 1
            radius: 11

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 13

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "ARCHRUUD WALLPAPER"
                            color: "#f3f7ff"
                            font.pixelSize: 21
                            font.bold: true
                        }

                        Text {
                            text: root.wallpaperDir
                            color: "#8190a8"
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        text: "Oppdater"
                        onClicked: root.refresh()
                    }

                    Button {
                        text: "Lukk"
                        onClicked: root.closePicker()
                    }
                }

                RowLayout {
                    spacing: 10

                    Button {
                        text: "Alle"
                        checked: root.filterMode === "all"
                        checkable: true
                        autoExclusive: true
                        onClicked: root.filterMode = "all"
                    }
                    Button {
                        text: "Dark"
                        checked: root.filterMode === "dark"
                        checkable: true
                        autoExclusive: true
                        onClicked: root.filterMode = "dark"
                    }
                    Button {
                        text: "Light"
                        checked: root.filterMode === "light"
                        checkable: true
                        autoExclusive: true
                        onClicked: root.filterMode = "light"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.statusText
                        color: "#8fdcff"
                        font.pixelSize: 8
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#111823"
                    radius: 11
                    border.color: "#26374b"

                    GridView {
                        id: grid
                        anchors.fill: parent
                        anchors.margins: 11
                        clip: true
                        cellWidth: 216
                        cellHeight: 152
                        model: root.visibleWallpapers()

                        delegate: Item {
                            required property var modelData
                            width: grid.cellWidth
                            height: grid.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 6
                                radius: 10
                                color: mouse.containsMouse ? "#1a2938" : "#151e2a"
                                border.width: root.selectedWallpaper === modelData ? 2 : 1
                                border.color: root.selectedWallpaper === modelData ? "#00c8ff" : "#2b3d52"

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 6

                                    Rectangle {
                                        width: parent.width
                                        height: 104
                                        radius: 7
                                        clip: true
                                        color: "#080c12"

                                        Image {
                                            anchors.fill: parent
                                            source: root.fileUrl(modelData)
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true
                                        }

                                        Rectangle {
                                            visible: root.selectedWallpaper === modelData
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 6
                                            width: 50
                                            height: 19
                                            radius: 10
                                            color: "#001c2a"
                                            border.color: "#00c8ff"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "AKTIV"
                                                color: "#9cecff"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: root.displayName(modelData)
                                        color: "#eaf3ff"
                                        font.pixelSize: 12
                                        elide: Text.ElideMiddle
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                MouseArea {
                                    id: mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.applyWallpaper(modelData)
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: root.visibleWallpapers().length === 0
                        text: "Ingen bakgrunner i denne kategorien"
                        color: "#8190a8"
                        font.pixelSize: 14
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Klikk på et bilde for å bruke det. Valget lagres automatisk og gjenopprettes ved neste Hyprland-start."
                    color: "#708198"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
