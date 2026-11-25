// ARCHRUUD Right Edge Controls v1.0.6 TEST
// ONE Quickshell PanelWindow and ONE pointer/close timer for Power, Volume and Light.
// Derived from the user's tested Power Menu v1.0 and Kairos v1.0.5.4 sources.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services" as S

ShellRoot {
    id: root
    // THE ONLY timer controlling the entire right edge panel.
    property int autoCloseMs: 3000
    property bool panelOpen: false
    property bool hovered: false
    property bool volumeDragging: false
    property real volumeDragValue: 0
    property bool brightnessDragging: false
    property real brightnessDragValue: 0.5
    property string pendingAction: ""
    property string pendingLabel: ""
    property var actions: [
        { label: "Lock", action: "lock", icon: "lock" },
        { label: "Logout", action: "logout", icon: "logout" },
        { label: "Suspend", action: "suspend", icon: "suspend" },
        { label: "Reboot", action: "reboot", icon: "reboot" },
        { label: "Shutdown", action: "shutdown", icon: "shutdown" },
        { label: "Hibernate", action: "hibernate", icon: "hibernate" }
    ]

    readonly property var audio: S.Audio.sink ? S.Audio.sink.audio : null
    readonly property real currentVolume: audio ? S.Audio.normalized(audio.volume) : 0
    readonly property bool currentMuted: audio ? Boolean(audio.muted) : false
    readonly property real shownVolume: volumeDragging ? volumeDragValue : currentVolume
    readonly property int volumePercent: Math.round(shownVolume * 100)
    property bool audioArmed: false
    property real lastVolume: -1
    property bool lastMuted: false
    onAudioChanged: {
        audioArmed = false;
        armAudio.restart();
    }
    Timer {
        id: armAudio
        interval: 700
        onTriggered: {
            root.lastVolume = root.currentVolume;
            root.lastMuted = root.currentMuted;
            root.audioArmed = root.audio !== null;
        }
    }
    Component.onCompleted: armAudio.restart()
    Connections {
        target: root.audio
        function onVolumesChanged() { root.volumeUpdated(); }
        function onMutedChanged() { root.volumeUpdated(); }
    }
    function volumeUpdated() {
        if (!audioArmed || !audio) return;
        if (Math.abs(lastVolume - currentVolume) < 0.001 && lastMuted === currentMuted) return;
        lastVolume = currentVolume;
        lastMuted = currentMuted;
        // Show the SAME unified panel for physical volume keys as for edge hover.
        // No notification daemon, second OSD or competing popup required.
        if (!panelOpen) openPanel();
    }

    property bool brightnessAvailable: false
    property int brightnessPercent: 50
    property string brightnessBackend: ""
    property string brightnessStatus: "Checking monitor..."
    readonly property real shownBrightness: brightnessDragging ? brightnessDragValue : brightnessPercent / 100
    property real queuedBrightness: -1
    property real committingBrightness: -1

    function openPanel() {
        panelOpen = true;
        pendingAction = "";
        // If opened via SUPER+P or a volume-key, close after 3s unless hovered.
        if (!hovered) closeDelay.restart();
        readBrightness();
    }
    function closePanel() {
        panelOpen = false;
        pendingAction = "";
        closeDelay.stop();
    }
    function togglePanel() { if (panelOpen) closePanel(); else openPanel(); }
    function armClose() {
        if (!hovered && !volumeDragging && !brightnessDragging && panelOpen)
            closeDelay.restart();
        else closeDelay.stop();
    }
    function interact() { if (panelOpen) closeDelay.stop(); }
    function choose(action, label) {
        interact();
        if (action === "lock") {
            runAction.exec([Quickshell.shellPath("scripts/power-action.sh"), action]);
            closePanel();
            return;
        }
        pendingAction = action;
        pendingLabel = label;
    }
    function confirm() {
        if (!pendingAction) return;
        runAction.exec([Quickshell.shellPath("scripts/power-action.sh"), pendingAction]);
        closePanel();
    }
    Process { id: runAction }
    IpcHandler {
        target: "powerMenu"
        function toggle(): void { root.togglePanel(); }
        function open(): void { root.openPanel(); }
        function close(): void { root.closePanel(); }
    }
    Timer {
        id: closeDelay
        interval: root.autoCloseMs
        repeat: false
        onTriggered: {
            if (!root.hovered && !root.volumeDragging && !root.brightnessDragging)
                root.closePanel();
        }
    }

    function volumeFromY(y, height) { return Math.max(0, Math.min(1, 1 - y / Math.max(1, height))); }
    function brightnessFromY(y, height) { return Math.max(0.1, Math.min(1, 1 - y / Math.max(1, height))); }
    function setVolumeWhileDragging(value) {
        volumeDragValue = value;
        S.Audio.setOutputVolume(value);
    }
    function commitVolume(value) {
        volumeDragValue = value;
        S.Audio.commitOutputVolume(value);
        volumeDragging = false;
        armClose();
    }
    function toggleMute() { S.Audio.toggleOutputMute(); interact(); }

    function readBrightness() {
        if (!brightnessRead.running && !brightnessSet.running && !brightnessDragging)
            brightnessRead.exec(["python3", Quickshell.shellPath("scripts/archruud_brightness.py"), "status"]);
    }
    function setBrightness(value) {
        if (!brightnessAvailable) return;
        const pct = Math.max(10, Math.min(100, Math.round(value * 100)));
        brightnessPercent = pct;
        // Serialize DDC/CI calls; never silently discard a final slider release.
        if (brightnessSet.running) {
            queuedBrightness = pct;
            return;
        }
        committingBrightness = pct;
        brightnessSet.exec(["python3", Quickshell.shellPath("scripts/archruud_brightness.py"), "set", String(pct)]);
    }
    Process {
        id: brightnessRead
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const val = JSON.parse(text);
                    root.brightnessAvailable = !!val.available;
                    root.brightnessBackend = val.backend || "";
                    root.brightnessStatus = val.detail || "";
                    if (val.available && !root.brightnessDragging)
                        root.brightnessPercent = Math.max(10, Math.min(100, Number(val.percent)));
                } catch (e) {
                    root.brightnessAvailable = false;
                    root.brightnessStatus = "Brightness backend error";
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) {
                root.brightnessAvailable = false;
                root.brightnessStatus = "Brightness unavailable";
            }
        }
    }
    Process {
        id: brightnessSet
        onExited: (code, status) => {
            if (code !== 0) root.brightnessStatus = "Could not change brightness";
            if (root.queuedBrightness >= 0) {
                const next = root.queuedBrightness;
                root.queuedBrightness = -1;
                root.setBrightness(next / 100);
            } else {
                refreshBrightness.restart();
            }
        }
    }
    Timer { id: refreshBrightness; interval: 800; onTriggered: root.readBrightness(); }
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.readBrightness()
    }

    // Crisp vector glyphs: no emoji fonts or external icon packages required.
    component PowerGlyph: Item {
        property string kind: "lock"
        property color accent: "#48B9FF"
        width: 26; height: 26
        Canvas {
            anchors.fill: parent
            onPaint: {
                const c = getContext("2d")
                c.reset(); c.strokeStyle = accent; c.fillStyle = accent
                c.lineWidth = 2.5; c.lineCap = "round"; c.lineJoin = "round"
                const x = width / 2, y = height / 2
                if (kind === "lock") {
                    c.beginPath(); c.arc(x,y-4,6,Math.PI,0); c.stroke()
                    c.fillRect(x-9,y-3,18,13); c.clearRect(x-6,y,12,7)
                    c.beginPath(); c.arc(x,y+3,1.5,0,Math.PI*2); c.fill()
                } else if (kind === "logout") {
                    c.beginPath(); c.moveTo(11,5); c.lineTo(5,5); c.lineTo(5,21); c.lineTo(11,21); c.stroke()
                    c.beginPath(); c.moveTo(10,13); c.lineTo(23,13); c.moveTo(18,8); c.lineTo(23,13); c.lineTo(18,18); c.stroke()
                } else if (kind === "suspend") {
                    c.beginPath(); c.arc(13,13,9,0,Math.PI*2); c.fill()
                    c.globalCompositeOperation = "destination-out"
                    c.beginPath(); c.arc(18,8,9,0,Math.PI*2); c.fill()
                    c.globalCompositeOperation = "source-over"
                } else if (kind === "reboot") {
                    c.beginPath(); c.arc(13,14,9,-Math.PI*0.6,Math.PI*1.15); c.stroke()
                    c.beginPath(); c.moveTo(9,3); c.lineTo(16,3); c.lineTo(15,10); c.stroke()
                } else if (kind === "shutdown") {
                    c.beginPath(); c.arc(13,14,9,-Math.PI*0.7,Math.PI*0.7); c.stroke()
                    c.beginPath(); c.moveTo(13,2); c.lineTo(13,14); c.stroke()
                } else if (kind === "hibernate") {
                    for (let i=0;i<3;i++) {
                        c.save(); c.translate(13,13); c.rotate(i*Math.PI/3)
                        c.beginPath(); c.moveTo(-10,0); c.lineTo(10,0)
                        c.moveTo(7,-3); c.lineTo(10,0); c.lineTo(7,3)
                        c.moveTo(-7,-3); c.lineTo(-10,0); c.lineTo(-7,3)
                        c.stroke(); c.restore()
                    }
                }
            }
        }
    }

    // One overlay: 82px controls left + 2px seam + original 142px Power Menu.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: root.panelOpen
            anchors { right: true }
            implicitWidth: 226
            implicitHeight: 562
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-unified-right-edge"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // The parent hover region covers BOTH cards and ALL six Power tiles.
            // A single leave event starts the timer, preventing the old race.
            HoverHandler {
                id: panelHover
                onHoveredChanged: {
                    root.hovered = hovered;
                    root.armClose();
                }
            }

            Item {
                id: powerArea
                width: 142
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                Canvas {
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d"); c.reset();
                        const w = width, h = height;
                        const edge = 0.5, bodyX = 18.5, top = 44.5, bottom = h - 44.5;
                        c.beginPath();
                        c.moveTo(w, edge);
                        c.bezierCurveTo(w - 4, 27, w - 13, top, w - 40, top);
                        c.lineTo(bodyX + 26, top);
                        c.bezierCurveTo(bodyX + 9, top, bodyX, top + 10, bodyX, top + 28);
                        c.lineTo(bodyX, bottom - 28);
                        c.bezierCurveTo(bodyX, bottom - 10, bodyX + 9, bottom, bodyX + 26, bottom);
                        c.lineTo(w - 40, bottom);
                        c.bezierCurveTo(w - 13, bottom, w - 4, h - 27, w, h - edge);
                        c.closePath();
                        c.fillStyle = "#080F1B"; c.fill();
                        c.beginPath();
                        c.moveTo(w, edge);
                        c.bezierCurveTo(w - 4, 27, w - 13, top, w - 40, top);
                        c.lineTo(bodyX + 26, top);
                        c.bezierCurveTo(bodyX + 9, top, bodyX, top + 10, bodyX, top + 28);
                        c.lineTo(bodyX, bottom - 28);
                        c.bezierCurveTo(bodyX, bottom - 10, bodyX + 9, bottom, bodyX + 26, bottom);
                        c.lineTo(w - 40, bottom);
                        c.bezierCurveTo(w - 13, bottom, w - 4, h - 27, w, h - edge);
                        c.strokeStyle = "#38B7FF"; c.lineWidth = 1.4; c.stroke();
                    }
                }
                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 28
                    anchors.rightMargin: 7
                    anchors.topMargin: 47
                    anchors.bottomMargin: 47
                    spacing: 5
                    Repeater {
                        model: root.actions
                        delegate: Rectangle {
                            id: tile
                            required property var modelData
                            width: parent.width
                            height: 73
                            radius: 13
                            color: tileMouse.containsMouse ? "#18334B" : "#0D1B2C"
                            border.width: 1
                            border.color: tileMouse.containsMouse ? "#55C8FF" : "#254B6B"
                            property color tint: modelData.action === "logout" ? "#34D9AC"
                                : modelData.action === "suspend" ? "#FFB74D"
                                : modelData.action === "shutdown" ? "#FF596C"
                                : modelData.action === "hibernate" ? "#9BD8FF" : "#43B9FF"
                            Column {
                                anchors.centerIn: parent
                                spacing: 3
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 37; height: 37; radius: 19
                                    color: "#102E46"; border.color: tile.tint; border.width: 1
                                    PowerGlyph {
                                        anchors.centerIn: parent
                                        kind: modelData.icon
                                        accent: tile.tint
                                    }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.pixelSize: 12
                                    color: "#EAF6FF"
                                }
                            }
                            MouseArea {
                                id: tileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.choose(modelData.action, modelData.label)
                            }
                        }
                    }
                }
                // Preserve the original two-step confirmation for dangerous actions.
                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
                    anchors.leftMargin: 23; anchors.rightMargin: 4
                    anchors.topMargin: 41; anchors.bottomMargin: 41
                    radius: 12
                    color: "#0B192A"; border.color: "#38B7FF"
                    visible: root.pendingAction !== ""
                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        spacing: 16
                        Text {
                            width: parent.width
                            text: "Confirm\n" + root.pendingLabel + "?"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: 15; font.bold: true; color: "#EAF6FF"
                        }
                        Rectangle {
                            width: parent.width; height: 38; radius: 8
                            color: "#1B344B"; border.color: "#426C8A"
                            Text { anchors.centerIn: parent; text: "Cancel"; color: "white" }
                            MouseArea { anchors.fill: parent; onClicked: { root.pendingAction = ""; root.interact(); } }
                        }
                        Rectangle {
                            width: parent.width; height: 38; radius: 8
                            color: "#532232"; border.color: "#F25A6D"
                            Text { anchors.centerIn: parent; text: "Confirm"; color: "white" }
                            MouseArea { anchors.fill: parent; onClicked: root.confirm() }
                        }
                    }
                }
            }
            // Volume above Monitor Light, inside SAME PanelWindow.
            Column {
                id: controls
                x: 0
                y: 47
                width: 82
                spacing: 5
                Rectangle {
                    radius: 13
                    color: "#081522"
                    border.width: 1
                    border.color: "#39A8F0"
                    id: volumeCard
                    width: 82
                    height: 229
                    Text {
                        anchors.top: parent.top; anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Volume"; color: "#D8EFFF"; font.pixelSize: 12; font.weight: Font.DemiBold
                    }
                    Text {
                        anchors.top: parent.top; anchors.topMargin: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.currentMuted ? "Muted" : root.volumePercent + "%"
                        color: root.currentMuted ? "#FFB0B0" : "#79C9FF"
                        font.pixelSize: 11; font.weight: Font.Bold
                    }
                    Item {
                        id: volumeTrack
                        width: 22
                        anchors.top: parent.top
                        anchors.topMargin: 52
                        anchors.bottom: muteButton.top
                        anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        Rectangle {
                            anchors.fill: parent
                            radius: 11
                            color: "#0F1F2E"
                        }
                        Rectangle {
                            width: 6; height: parent.height
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 3; color: "#294152"
                        }
                        Rectangle {
                            width: 6; height: Math.max(0, parent.height * root.shownVolume)
                            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                            radius: 3; color: root.currentMuted ? "#60758A" : "#39A8F0"
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            x: (parent.width - width) / 2
                            y: Math.max(0, Math.min(parent.height - height, parent.height * (1 - root.shownVolume) - height / 2))
                            color: root.currentMuted ? "#A7BCCB" : "#D8F2FF"
                            border.width: 1; border.color: "#39A8F0"
                        }
                        MouseArea {
                            anchors.fill: parent
                            preventStealing: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: (mouse) => {
                                root.volumeDragging = true;
                                root.interact();
                                root.setVolumeWhileDragging(root.volumeFromY(mouse.y, height));
                            }
                            onPositionChanged: (mouse) => {
                                if (root.volumeDragging)
                                    root.setVolumeWhileDragging(root.volumeFromY(mouse.y, height));
                            }
                            onReleased: (mouse) => root.commitVolume(root.volumeFromY(mouse.y, height))
                            onCanceled: { root.volumeDragging = false; root.armClose(); }
                        }
                    }
                    Rectangle {
                        id: muteButton
                        width: 38; height: 38; radius: 12
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.currentMuted ? "#183B51" : "#101E2E"
                        border.width: 1; border.color: root.currentMuted ? "#39A8F0" : "#29455D"
                        Text {
                            anchors.centerIn: parent
                            text: root.currentMuted || root.volumePercent === 0 ? "volume_off" : "volume_up"
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 22; color: "#E5F5FF"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleMute()
                        }
                    }
                }
                Rectangle {
                    radius: 13
                    color: "#081522"
                    border.width: 1
                    border.color: "#39A8F0"
                    id: brightnessCard
                    width: 82
                    height: 229
                    opacity: root.brightnessAvailable ? 1 : 0.82
                    Text {
                        anchors.top: parent.top; anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Monitor"; color: "#D8EFFF"; font.pixelSize: 12; font.weight: Font.DemiBold
                    }
                    Text {
                        anchors.top: parent.top; anchors.topMargin: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Light"; color: "#D8EFFF"; font.pixelSize: 12; font.weight: Font.DemiBold
                    }
                    Text {
                        anchors.top: parent.top; anchors.topMargin: 42
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.brightnessAvailable ? Math.round(root.shownBrightness * 100) + "%" : "N/A"
                        color: root.brightnessAvailable ? "#79C9FF" : "#8398A7"
                        font.pixelSize: 11; font.weight: Font.Bold
                    }
                    Item {
                        id: brightnessTrack
                        width: 22
                        anchors.top: parent.top; anchors.topMargin: 62
                        anchors.bottom: lightButton.top; anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        Rectangle { anchors.fill: parent; radius: 11; color: "#0F1F2E" }
                        Rectangle { width: 6; height: parent.height; anchors.horizontalCenter: parent.horizontalCenter; radius: 3; color: "#294152" }
                        Rectangle {
                            width: 6; height: Math.max(0, parent.height * root.shownBrightness)
                            anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                            radius: 3; color: "#39A8F0"
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            x: (parent.width - width) / 2
                            y: Math.max(0, Math.min(parent.height - height, parent.height * (1 - root.shownBrightness) - height / 2))
                            color: "#D8F2FF"; border.width: 1; border.color: "#39A8F0"
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.brightnessAvailable
                            preventStealing: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: (mouse) => {
                                root.brightnessDragging = true;
                                root.interact();
                                root.brightnessDragValue = root.brightnessFromY(mouse.y, height);
                            }
                            onPositionChanged: (mouse) => {
                                if (root.brightnessDragging)
                                    root.brightnessDragValue = root.brightnessFromY(mouse.y, height);
                            }
                            onReleased: (mouse) => {
                                const val = root.brightnessFromY(mouse.y, height);
                                root.brightnessDragValue = val;
                                root.brightnessDragging = false;
                                root.setBrightness(val);
                                root.armClose();
                            }
                            onCanceled: { root.brightnessDragging = false; root.armClose(); }
                        }
                    }
                    Rectangle {
                        id: lightButton
                        width: 38; height: 38; radius: 12
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#101E2E"; border.width: 1
                        border.color: root.brightnessAvailable ? "#29455D" : "#293444"
                        Text {
                            anchors.centerIn: parent
                            text: "light_mode"; font.family: "Material Symbols Rounded"
                            font.pixelSize: 22
                            color: root.brightnessAvailable ? "#E5F5FF" : "#788696"
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.brightnessAvailable
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.setBrightness((root.brightnessPercent + 10) / 100); root.interact(); }
                        }
                    }
                }
            }
            Shortcut { sequence: "Escape"; enabled: root.panelOpen; onActivated: root.closePanel(); }
        }
    }
    // Unchanged 2px screen-edge hover trigger. No additional trigger process.
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { right: true }
            implicitWidth: 2
            implicitHeight: 180
            visible: !root.panelOpen
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-power-edge"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.openPanel()
            }
        }
    }
}
