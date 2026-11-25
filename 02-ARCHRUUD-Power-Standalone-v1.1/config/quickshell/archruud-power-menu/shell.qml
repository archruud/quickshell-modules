// ARCHRUUD Right Edge Controls v1.0.6 TEST
// ONE Quickshell PanelWindow and ONE pointer/close timer for Power, Volume and Light.
// Derived from the user's tested Power Menu v1.0 and Kairos v1.0.5.4 sources.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    // Independent power menu timer.
    property int autoCloseMs: 3000
    property bool panelOpen: false
    property bool hovered: false
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

    function openPanel() {
        panelOpen = true;
        pendingAction = "";
        // If opened via SUPER+P or a volume-key, close after 3s unless hovered.
        if (!hovered) closeDelay.restart();
    }
    function closePanel() {
        panelOpen = false;
        pendingAction = "";
        closeDelay.stop();
    }
    function togglePanel() { if (panelOpen) closePanel(); else openPanel(); }
    function armClose() {
        if (!hovered && panelOpen)
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
            if (!root.hovered)
                root.closePanel();
        }
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

    // Standalone 142px Power Menu (original power-area geometry preserved).
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: root.panelOpen
            anchors { right: true }
            implicitWidth: 142
            implicitHeight: 562
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "archruud-power-menu"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // The parent hover region covers the power menu.
            // Leaving the panel starts the close timer.
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
