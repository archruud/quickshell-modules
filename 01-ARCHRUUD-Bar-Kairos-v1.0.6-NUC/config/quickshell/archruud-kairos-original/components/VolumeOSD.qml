pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../services"
import "../barkit" as Pill

// ARCHRUUD Kairos: interactive right-side OSD for Volume + Monitor Light.
// Shown as two stacked vertical cards to the LEFT of the right-edge Power Menu.
PanelWindow {
    id: osd

    required property var targetScreen
    property bool enabled: true
    property bool opened: false
    property bool powerCompanionOpen: false // Set by the single Power Menu IPC trigger.
    property bool armed: false
    property bool dragging: false
    property real dragValue: 0
    property real previousVolume: -1
    property bool previousMuted: false

    property bool brightnessAvailable: false
    property int brightnessPercent: 50
    property string brightnessBackend: ""
    property string brightnessStatus: "Checking monitor..."
    property bool brightnessDragging: false
    property real brightnessDragValue: 0.5
    readonly property real shownBrightness: brightnessDragging
        ? brightnessDragValue : brightnessPercent / 100

    readonly property var audio: Audio.sink ? Audio.sink.audio : null
    readonly property real currentVolume: audio ? Audio.normalized(audio.volume) : 0
    readonly property bool currentMuted: audio ? Boolean(audio.muted) : false
    readonly property real shownVolume: dragging ? dragValue : currentVolume
    readonly property int shownPercent: Math.round(shownVolume * 100)

    screen: osd.targetScreen
    visible: osd.enabled && (osd.opened || osd.powerCompanionOpen) && osd.audio !== null
    color: "transparent"
    anchors { right: true }
    margins { right: 144 }
    implicitWidth: 82
    implicitHeight: 562
    // All measurements are matched to the running Power Menu's six 73px tiles,
    // five 5px gaps, and 47px top inset. This layout contains no freehand offset.
    readonly property int powerActions: 6
    readonly property int powerTileHeight: 73
    readonly property int powerTileGap: 5
    readonly property int powerTopInset: 47
    readonly property int powerContentHeight: powerActions * powerTileHeight
        + (powerActions - 1) * powerTileGap
    readonly property int sideCardHeight: (powerContentHeight - powerTileGap) / 2
    // Alignment measured from the user's 2026-11-11 recording: both companion
    // cards were about 20 logical pixels ABOVE the Power Menu action tiles.
    // Do not change their 229px heights or 5px gap; move the pair as a unit.
    readonly property int powerCompanionYOffset: 20

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "archruud-kairos-volume-osd"

    onAudioChanged: {
        osd.armed = false;
        osd.opened = false;
        osd.previousVolume = -1;
        armTimer.restart();
    }
    Timer {
        id: armTimer
        interval: 500
        onTriggered: {
            osd.previousVolume = osd.currentVolume;
            osd.previousMuted = osd.currentMuted;
            osd.armed = osd.audio !== null;
        }
    }
    Component.onCompleted: armTimer.restart()

    function showForChange() {
        if (!osd.enabled || !osd.audio || !osd.armed) return;
        var vol = osd.currentVolume;
        var muted = osd.currentMuted;
        if (Math.abs(vol - osd.previousVolume) < 0.001 && muted === osd.previousMuted)
            return;
        osd.previousVolume = vol;
        osd.previousMuted = muted;
        osd.keepVisible();
    }
    function keepVisible() {
        osd.opened = true;
        hideTimer.restart();
    }
    function sliderValueFromY(y) {
        var usable = Math.max(1, volumeTrack.height);
        return Math.max(0, Math.min(1, 1 - (y / usable)));
    }
    function brightnessValueFromY(y) {
        var usable = Math.max(1, brightnessTrack.height);
        return Math.max(0.1, Math.min(1, 1 - (y / usable)));
    }
    function setBrightness(v) {
        if (!osd.brightnessAvailable || brightnessSet.running) return;
        var pct = Math.max(10, Math.min(100, Math.round(v * 100)));
        osd.brightnessPercent = pct;
        brightnessSet.exec(["python3", Quickshell.shellPath("scripts/archruud_brightness.py"),
                            "set", String(pct)]);
        osd.keepVisible();
    }

    Process {
        id: brightnessRead
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var value = JSON.parse(text);
                    osd.brightnessAvailable = !!value.available;
                    osd.brightnessBackend = value.backend || "";
                    osd.brightnessStatus = value.detail || "";
                    if (value.available && !osd.brightnessDragging)
                        osd.brightnessPercent = Math.max(10, Math.min(100, Number(value.percent)));
                } catch (e) {
                    osd.brightnessAvailable = false;
                    osd.brightnessStatus = "Brightness backend error";
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                osd.brightnessAvailable = false;
                osd.brightnessStatus = "Brightness unavailable";
            }
        }
    }
    Process {
        id: brightnessSet
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) osd.brightnessStatus = "Could not change brightness";
            refreshBrightness.restart();
        }
    }
    function readBrightness() {
        if (!brightnessRead.running && !brightnessSet.running && !osd.brightnessDragging)
            brightnessRead.exec(["python3", Quickshell.shellPath("scripts/archruud_brightness.py"), "status"]);
    }
    Timer {
        id: refreshBrightness
        interval: 650
        onTriggered: osd.readBrightness()
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: osd.readBrightness()
    }

    Connections {
        target: osd.audio
        function onVolumesChanged() { osd.showForChange(); }
        function onMutedChanged() { osd.showForChange(); }
    }
    Timer {
        id: hideTimer
        interval: 7000
        onTriggered: {
            if (osd.dragging || osd.brightnessDragging || columnHover.hovered) {
                hideTimer.restart();
                return;
            }
            osd.opened = false;
        }
    }

    // Closing Power Menu closes its companion cards as one panel.
    // Ordinary volume-key OSD behavior is unchanged when Power is closed.
    onPowerCompanionOpenChanged: {
        if (!osd.powerCompanionOpen && !osd.dragging && !osd.brightnessDragging) {
            osd.opened = false;
            hideTimer.stop();
        }
        if (osd.powerCompanionOpen) osd.readBrightness();
    }

    component CardFrame: Rectangle {
        radius: 16
        color: "#081522"
        border.width: 1
        border.color: "#39A8F0"
    }

    Item {
        anchors.fill: parent
        HoverHandler { id: columnHover }

        Column {
            anchors.fill: parent
            // Cards occupy the same 463px span as the Power Menu action tiles.
            // The independent layer-shell surface needs a +20px calibrated
            // alignment relative to the actual Power Menu compositor position.
            anchors.topMargin: osd.powerTopInset + osd.powerCompanionYOffset
            anchors.bottomMargin: osd.height - osd.powerTopInset
                - osd.powerContentHeight - osd.powerCompanionYOffset
            spacing: osd.powerTileGap

            CardFrame {
                id: volumeCard
                width: parent.width
                height: osd.sideCardHeight

                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 10
                    text: "Volume"
                    color: "#D8EFFF"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 30
                    text: osd.currentMuted ? "Muted" : osd.shownPercent + "%"
                    color: osd.currentMuted ? "#FFB0B0" : "#79C9FF"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }

                Item {
                    id: volumeTrack
                    width: 20
                    anchors.top: parent.top
                    anchors.bottom: muteButton.top
                    anchors.topMargin: 52
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.fill: parent
                        radius: 10
                        color: "#0F1F2E"
                    }
                    Rectangle {
                        width: 6
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 3
                        color: "#294152"
                    }
                    Rectangle {
                        width: 6
                        height: Math.max(0, parent.height * osd.shownVolume)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        radius: 3
                        color: osd.currentMuted ? "#60758A" : "#39A8F0"
                    }
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        x: (parent.width - width) / 2
                        y: Math.max(0, Math.min(parent.height - height,
                            parent.height * (1 - osd.shownVolume) - height / 2))
                        color: osd.currentMuted ? "#A7BCCB" : "#D8F2FF"
                        border.width: 1
                        border.color: "#39A8F0"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        preventStealing: true
                        onPressed: (mouse) => {
                            osd.dragging = true;
                            osd.dragValue = osd.sliderValueFromY(mouse.y);
                            Audio.setOutputVolume(osd.dragValue);
                            osd.keepVisible();
                        }
                        onPositionChanged: (mouse) => {
                            if (!osd.dragging) return;
                            osd.dragValue = osd.sliderValueFromY(mouse.y);
                            Audio.setOutputVolume(osd.dragValue);
                            osd.keepVisible();
                        }
                        onReleased: (mouse) => {
                            var v = osd.sliderValueFromY(mouse.y);
                            osd.dragValue = v;
                            Audio.commitOutputVolume(v);
                            osd.dragging = false;
                            osd.keepVisible();
                        }
                        onCanceled: osd.dragging = false
                    }
                }

                Rectangle {
                    id: muteButton
                    width: 38
                    height: 38
                    radius: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: osd.currentMuted ? "#183B51" : (muteHover.hovered ? "#173047" : "#101E2E")
                    border.width: 1
                    border.color: osd.currentMuted ? "#39A8F0" : "#29455D"
                    Pill.MaterialIcon {
                        anchors.centerIn: parent
                        text: osd.currentMuted || osd.shownPercent === 0 ? "volume_off" : "volume_up"
                        color: osd.currentMuted ? "#79C9FF" : "#E5F5FF"
                        font.pixelSize: 22
                    }
                    HoverHandler { id: muteHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Audio.toggleOutputMute();
                            osd.keepVisible();
                        }
                    }
                }
            }

            CardFrame {
                id: brightnessCard
                width: parent.width
                height: osd.sideCardHeight
                opacity: osd.brightnessAvailable ? 1.0 : 0.82

                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 10
                    text: "Monitor"
                    color: "#D8EFFF"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 24
                    text: "Light"
                    color: "#D8EFFF"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Text {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 42
                    text: osd.brightnessAvailable ? Math.round(osd.shownBrightness * 100) + "%" : "N/A"
                    color: osd.brightnessAvailable ? "#79C9FF" : "#8398A7"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }

                Item {
                    id: brightnessTrack
                    width: 20
                    anchors.top: parent.top
                    anchors.bottom: brightnessButton.top
                    anchors.topMargin: 62
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.fill: parent
                        radius: 10
                        color: "#0F1F2E"
                    }
                    Rectangle {
                        width: 6
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 3
                        color: "#294152"
                    }
                    Rectangle {
                        width: 6
                        height: Math.max(0, parent.height * osd.shownBrightness)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        radius: 3
                        color: "#39A8F0"
                    }
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        x: (parent.width - width) / 2
                        y: Math.max(0, Math.min(parent.height - height,
                            parent.height * (1 - osd.shownBrightness) - height / 2))
                        color: "#D8F2FF"
                        border.width: 1
                        border.color: "#39A8F0"
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: osd.brightnessAvailable
                        cursorShape: Qt.PointingHandCursor
                        preventStealing: true
                        onPressed: (mouse) => {
                            osd.brightnessDragging = true;
                            osd.brightnessDragValue = osd.brightnessValueFromY(mouse.y);
                            osd.keepVisible();
                        }
                        onPositionChanged: (mouse) => {
                            if (!osd.brightnessDragging) return;
                            osd.brightnessDragValue = osd.brightnessValueFromY(mouse.y);
                            osd.keepVisible();
                        }
                        onReleased: (mouse) => {
                            var next = osd.brightnessValueFromY(mouse.y);
                            osd.brightnessDragging = false;
                            osd.setBrightness(next);
                        }
                        onCanceled: osd.brightnessDragging = false
                    }
                }

                Rectangle {
                    id: brightnessButton
                    width: 38
                    height: 38
                    radius: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#101E2E"
                    border.width: 1
                    border.color: osd.brightnessAvailable ? "#29455D" : "#293444"
                    Pill.MaterialIcon {
                        anchors.centerIn: parent
                        text: "light_mode"
                        color: osd.brightnessAvailable ? "#E5F5FF" : "#788696"
                        font.pixelSize: 22
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: osd.brightnessAvailable
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            osd.setBrightness(osd.brightnessPercent / 100 + 0.1);
                        }
                    }
                }
            }
        }
    }
}
