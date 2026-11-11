// Kairos: the island bar style. The clock is the centre island -- it rests as a
// small pill on the screen's centre line and expands there, symmetric, into the
// clock over the rolling date wheel. The music island is a bubble to its left
// that peeks open to the transport on hover and opens into the full now-playing
// panel on a click; the expanding clock pushes the bubble aside, and moving the
// pointer off the open panel closes it.

import QtQuick
import QtQuick.Effects
import "../services"
import "../barkit" as Pill
import "../settings" as S
import "../quicksettings" as Q
import "../IslandMetrics.js" as Island
import "." as C

Item {
    id: island

    // True while the launcher owns the island; both then rest, and the launcher's
    // own pill (which starts at the clock's exact size) covers the clock.
    property bool suspended: false
    // Quick settings is the island itself growing into the panel: one surface,
    // one pill, one animation. Open pins the clock out and the music aside.
    property bool quickOpen: false
    property real quickProgress: island.quickOpen ? 1 : 0
    readonly property real quickWidth: 512  // more room for tile text
    readonly property real quickHeight: 532 // more room for quick-settings content
    Behavior on quickProgress {
        enabled: !Motion.reduce
        NumberAnimation { duration: Motion.morph; easing.type: Motion.easeStandard }
    }

    signal settingsToggled()
    signal quickSettingsToggled()
    signal quickCloseRequested()

    S.IslandSettings { id: cfg }

    readonly property var player: Media.player
    readonly property bool hasTrack: Media.present
    readonly property real topGap: cfg.topGap
    readonly property real restHeight: Math.ceil(metrics.implicitHeight + cfg.padTop + cfg.padBottom)
    readonly property real restFontSize: cfg.restFontSize
    readonly property string hoverDateLabel: wheel.selected.toLocaleDateString(Config.formatLoc, "ddd d MMM yyyy").toUpperCase()
    readonly property real band: topGap + restHeight
    // Reserve the tallest state so the surface never resizes mid-morph: only the
    // pill grows.
    readonly property real reach: topGap
        + Math.max(island.expandedHeight + island.trayMaxExtra, Island.musicHeight, island.quickHeight)
        + Island.shadowBleed

    // ── the music island ─────────────────────────────────────────────────────
    // Rests as a bubble beside the clock. A hover peeks the transport open; a
    // click opens the full now-playing panel. Moving the pointer off the island
    // closes it again -- no click needed -- and a track never opens it by itself.
    property bool pinnedFull: false
    onHasTrackChanged: if (!island.hasTrack) island.pinnedFull = false
    // Leaving the island (hover lost through the grace timer) closes the panel,
    // unless a progress-bar scrub is in flight -- a drag may stray off the panel.
    readonly property bool musicScrubbing: music.scrubbing
    onMusicHoveredChanged: if (!island.musicHovered && !island.musicScrubbing) island.pinnedFull = false
    onMusicScrubbingChanged: if (!island.musicScrubbing && !island.musicHovered) island.pinnedFull = false

    function toggleFull() { island.pinnedFull = !island.pinnedFull; }

    readonly property bool full: island.pinnedFull && !island.suspended
    property real fullProgress: island.full ? 1 : 0
    property real peekProgress:
        (island.musicHovered && island.hasTrack && !island.full && !island.suspended) ? 1 : 0
    property real trackPresence: (island.hasTrack && cfg.music) ? 1 : 0

    Behavior on fullProgress {
        enabled: !Motion.reduce
        NumberAnimation { duration: Motion.morph; easing.type: Motion.easeStandard }
    }
    Behavior on peekProgress {
        enabled: !Motion.reduce
        NumberAnimation { duration: Motion.morph; easing.type: Motion.easeStandard }
    }
    Behavior on trackPresence {
        enabled: !Motion.reduce
        NumberAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
    }

    // ── the clock island ─────────────────────────────────────────────────────
    property real clockProgress: ((island.clockHovered || island.quickOpen) && !island.suspended) ? 1 : 0
    Behavior on clockProgress {
        enabled: !Motion.reduce && !island.suspended
        NumberAnimation { duration: Motion.morph; easing.type: Motion.easeStandard }
    }
    onQuickOpenChanged: {
        island.quickArmed = false;
        if (island.quickOpen) {
            armTimer.restart();
            Qt.callLater(function () { clockPill.forceActiveFocus(); });
        }
    }
    property bool quickArmed: false
    Timer {
        id: armTimer
        interval: 500
        onTriggered: island.quickArmed = true
    }
    // Leaving the island closes quick settings, so it never lingers after the
    // pointer walks away. Armed only after the open settles, so the click that
    // opened it can never immediately close it.
    onClockHoveredChanged: if (!island.clockHovered && island.quickOpen && island.quickArmed) island.quickCloseRequested();

    // Hover intent, one timer each: a pointer crossing the gap between the two
    // islands must not collapse the one it left mid-reach, and leaving one must
    // not cancel the other's hover.
    property bool musicHovered: false
    property bool clockHovered: false
    Timer {
        id: clockGrace
        interval: 320
        onTriggered: island.clockHovered = false
    }
    Timer {
        id: musicGrace
        interval: 320
        onTriggered: island.musicHovered = false
    }

    // ── geometry ─────────────────────────────────────────────────────────────
    // Measured at a fixed size, so the growing clock cannot feed back into the
    // width it is growing inside.
    readonly property real restWidth: Math.ceil(metrics.implicitWidth + cfg.padLeft + cfg.padRight)
    // Never shrink during hover, even at the maximum user padding.
    readonly property real expandedWidth: Math.max(cfg.hoverWidth, island.restWidth + 24)
    readonly property real hoverWidth: Math.round(island.restWidth
        + (island.expandedWidth - island.restWidth) * island.clockProgress)
    // The tray caret already lives in the sliver left under the date wheel at
    // rest; opening it (or an app's menu) grows the pill by exactly that much
    // more, so the tray reads as one more thing the island opens into.
    readonly property bool trayHostActive: island.clockHovered && !island.suspended && !island.quickOpen
    property real trayExtra: trayFlyout.extraHeight
    Behavior on trayExtra {
        enabled: !Motion.reduce
        NumberAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
    }
    // A fixed reserve for the window's own canvas (see Scene's `reach`-sized
    // PanelWindow): capped once at the flyout's own maximum, never live, so the
    // surface is created at its largest size and never resizes mid-morph.
    readonly property real trayMaxExtra: trayFlyout.maxExtra
    // Keep the entire date wheel + year visible when top/bottom padding grows.
    readonly property real timeHoverHeight: Math.ceil(cfg.hoverFontSize * 1.35)
    readonly property real wheelY: Math.max(cfg.wheelTop, cfg.padTop + island.timeHoverHeight + 8)
    readonly property real yearY: island.wheelY + cfg.wheelHeight - 2
    readonly property real yearHeight: 18
    readonly property real expandedHeight: cfg.dateWheel
        ? Math.max(cfg.hoverHeight, island.yearY + island.yearHeight + cfg.padBottom)
        : Math.max(cfg.hoverHeight, island.restHeight + 32)
    readonly property real hoverHeight: Math.round(island.restHeight
        + (island.expandedHeight + island.trayExtra - island.restHeight) * island.clockProgress)
    readonly property real baseRadius: island.restHeight / 2
        + (cfg.hoverRadius - island.restHeight / 2) * island.clockProgress
    readonly property real clockWidth: Math.round(island.hoverWidth
        + (island.quickWidth - island.hoverWidth) * island.quickProgress)
    readonly property real clockHeight: Math.round(island.hoverHeight
        + (island.quickHeight - island.hoverHeight) * island.quickProgress)
    readonly property real clockRadius: island.baseRadius
        + (40 - island.baseRadius) * island.quickProgress

    // How far to the left of the clock the music reaches (0 with no track).
    readonly property real musicExtent: (music.width + Island.bubbleGap) * island.trackPresence
    // The clock rests centred and expands symmetric, so it reaches this far left
    // of its resting edge; reserve that (or the music's extent) so it has room to
    // grow left without leaving the item.
    readonly property real clockGrowMax: (Math.max(island.expandedWidth, island.quickWidth) - island.restWidth) / 2
    readonly property real clockRestLeft: Math.max(island.clockGrowMax, island.musicExtent)
    // The clock's resting centre, fixed in item coordinates: the scene lands it on
    // the screen's centre line, so the clock never drifts as the music opens and
    // it always expands around that line.
    readonly property real clockRestCentre: island.clockRestLeft + island.restWidth / 2

    width: Math.round(island.clockRestCentre + island.clockWidth / 2)
    height: Math.round(Math.max(island.hasTrack ? music.height : 0, island.clockHeight))

    readonly property color fill: Theme.shadow
    readonly property color ink: Theme.ink(fill, 7)

    C.MusicSurface {
        id: music
        // Pinned just left of the clock's live left edge, so the expanding clock
        // pushes the bubble aside instead of covering it; grows leftward.
        x: island.clockRestCentre - island.clockWidth / 2 - Island.bubbleGap - width
        z: 0
        player: island.player
        peek: island.peekProgress
        peekHeight: cfg.musicPeek
        full: island.fullProgress
        ink: island.ink
        accent: Theme.primary
        opacity: island.trackPresence * (island.quickOpen ? 0 : 1)
        onActivated: island.toggleFull()

        HoverHandler {
            id: musicHover
            onHoveredChanged: {
                if (hovered) {
                    musicGrace.stop();
                    island.musicHovered = true;
                } else {
                    musicGrace.restart();
                }
            }
        }
    }

    // ARCHRUUD top-connected silhouette, from the tested clock-notch design:
    // concave outward shoulders join the screen edge, followed by a thin blue
    // contour. The centre and animation remain owned by the ORIGINAL island.
    // Drawing underneath the content avoids two overlapping opaque clock faces.
    Canvas {
        id: archruudTop
        x: clockPill.x - 30
        y: -island.topGap
        width: clockPill.width + 60
        height: clockPill.height + island.topGap
        z: 1.8
        property color backgroundColor: island.fill
        property color outlineColor: Theme.primary
        onBackgroundColorChanged: requestPaint()
        onOutlineColorChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const w = width, h = height
            const side = 30
            const shoulder = 24
            const drop = Math.max(18, Math.min(26, island.topGap + 14))
            const r = Math.max(12, Math.min(island.clockRadius, h / 2, (w - 2 * side) / 3))
            const left = side
            const right = w - side
            // Fill includes the screen-top attachment; border only follows the
            // visible hanging outline (no line across the top of the screen).
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(left - shoulder, 0)
            ctx.quadraticCurveTo(left - 8, 0, left, drop)
            ctx.lineTo(left, h - r)
            ctx.quadraticCurveTo(left, h, left + r, h)
            ctx.lineTo(right - r, h)
            ctx.quadraticCurveTo(right, h, right, h - r)
            ctx.lineTo(right, drop)
            ctx.quadraticCurveTo(right + 8, 0, right + shoulder, 0)
            ctx.lineTo(w, 0)
            ctx.closePath()
            ctx.fillStyle = archruudTop.backgroundColor.toString()
            ctx.fill()

            ctx.beginPath()
            ctx.moveTo(left - shoulder, 0)
            ctx.quadraticCurveTo(left - 8, 0, left, drop)
            ctx.lineTo(left, h - r)
            ctx.quadraticCurveTo(left, h, left + r, h)
            ctx.lineTo(right - r, h)
            ctx.quadraticCurveTo(right, h, right, h - r)
            ctx.lineTo(right, drop)
            ctx.quadraticCurveTo(right + 8, 0, right + shoulder, 0)
            ctx.strokeStyle = archruudTop.outlineColor.toString()
            ctx.lineWidth = 1.45
            ctx.stroke()
        }
    }

    Rectangle {
        id: clockPill
        // Grows symmetric around its fixed resting centre, over the music.
        x: island.clockRestCentre - island.clockWidth / 2
        y: 0
        z: 2
        width: island.clockWidth
        height: island.clockHeight
        radius: island.clockRadius
        // The custom Canvas underneath now draws the background and blue rim.
        // This transparent hit area keeps all original hover/quick-settings logic.
        color: "transparent"
        border.width: 0
        clip: true

        HoverHandler {
            id: clockHover
            onHoveredChanged: {
                if (hovered) {
                    clockGrace.stop();
                    island.clockHovered = true;
                } else {
                    clockGrace.restart();
                }
            }
        }

        focus: island.quickOpen
        Keys.onPressed: function (e) {
            if (!island.quickOpen) return;
            if (e.key !== Qt.Key_Escape) return;
            if (pane.page !== "home") pane.back();
            else island.quickCloseRequested();
            e.accepted = true;
        }

        C.Clock { id: clock }

        Text {
            id: metrics
            visible: false
            text: clock.time
            font.family: Theme.mono
            font.pixelSize: cfg.restFontSize
            font.weight: Font.ExtraBold
            font.letterSpacing: 0.4
        }

        // One Text at native size per step, never two copies crossfading: a
        // whole-pixel step keeps the growth crisp and cannot ghost.
        Text {
            id: timeLabel
            // The outer pill stays centred on screen; asymmetric padding may
            // move only the clock text within that pill.
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: Math.round((cfg.padLeft - cfg.padRight) / 2
                * (1 - island.clockProgress))
            // Keep the time in the dedicated top band, never vertically centred
            // in the whole expanded date-wheel or quick-settings panel.
            y: Math.round(cfg.padTop)
            text: clock.time
            color: island.ink
            font.family: Theme.mono
            font.pixelSize: Math.round(cfg.restFontSize
                + (cfg.hoverFontSize - cfg.restFontSize) * island.clockProgress)
            font.letterSpacing: 0.4 + 0.4 * island.clockProgress
            font.weight: Font.ExtraBold
            opacity: 1 - island.quickProgress
            renderType: Text.NativeRendering
        }

        C.DateWheel {
            id: wheel
            visible: cfg.dateWheel && island.clockProgress > 0.01
            anchors.horizontalCenter: parent.horizontalCenter
            y: island.wheelY
            width: parent.width
            height: cfg.wheelHeight
            ink: island.ink
            accent: Theme.primary
            locale: Config.formatLoc
            reveal: Math.max(0, Math.min(1, (island.clockProgress - 0.3) / 0.55))
            opacity: wheel.reveal * (1 - island.quickProgress)
        }

        Text {
            id: hoverDateLabel
            visible: cfg.dateWheel && island.clockProgress > 0.01 && !island.quickOpen
            anchors.horizontalCenter: parent.horizontalCenter
            y: island.yearY
            text: island.hoverDateLabel
            color: Qt.rgba(island.ink.r, island.ink.g, island.ink.b, 0.82)
            font.family: Theme.fontPrimary
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 1.0
            opacity: Math.max(0, Math.min(1, (island.clockProgress - 0.48) / 0.25)) * (1 - island.quickProgress)
            renderType: Text.NativeRendering
        }

        // The quick-settings face, drawn inside the same pill so the island reads
        // as one body opening.
        Q.QuickSettingsPane {
            id: pane
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 16
            visible: island.quickProgress > 0.01
            opacity: Math.max(0, Math.min(1, (island.quickProgress - 0.35) / 0.5))
            enabled: island.quickProgress > 0.95
            host: island
        }

        // The system tray folds into the sliver already left under the date
        // wheel; opening it (or an app's menu) is what grows the pill further.
        C.TrayFlyout {
            id: trayFlyout
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: parent.width
            ink: island.ink
            accent: Theme.primary
            hostActive: island.trayHostActive
            visible: cfg.tray && island.clockProgress > 0.5 && !island.quickOpen
            opacity: Math.max(0, Math.min(1, (island.clockProgress - 0.5) / 0.4))
            enabled: island.clockProgress > 0.95
        }

        // Quick settings sit just left of the gear; both ride the expansion.
        Item {
            id: quickButton
            anchors.top: parent.top
            anchors.right: settingsButton.left
            anchors.rightMargin: 6
            anchors.topMargin: 8
            width: 32
            height: 32
            visible: island.clockProgress > 0.01
            opacity: Math.max(0, Math.min(1, (island.clockProgress - 0.35) / 0.4))

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(island.ink.r, island.ink.g, island.ink.b,
                    quickHover.hovered ? 0.14 : 0)
                Behavior on color {
                    enabled: !Motion.reduce
                    ColorAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
                }
            }

            Pill.MaterialIcon {
                anchors.centerIn: parent
                text: "tune"
                color: island.ink
                opacity: 0.75
                font.pixelSize: 18
            }

            HoverHandler { id: quickHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: island.quickSettingsToggled()
            }
        }

        // The power readout sits in the top-left corner, opposite the gear: a
        // laptop shows its battery and charge, a desktop the all-inclusive
        // glyph. It fades in with the expansion, so the resting pill stays a
        // bare clock.
        C.BatteryIndicator {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 12
            anchors.leftMargin: 18
            ink: island.ink
            reveal: Math.max(0, Math.min(1, (island.clockProgress - 0.35) / 0.4))
        }

        // A gear in the top-right corner opens Ryoku Settings; it fades in as the
        // island expands, so the resting pill stays a bare clock.
        Item {
            id: settingsButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 10
            width: 32
            height: 32
            visible: island.clockProgress > 0.01
            opacity: Math.max(0, Math.min(1, (island.clockProgress - 0.35) / 0.4))

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(island.ink.r, island.ink.g, island.ink.b,
                    settingsHover.hovered ? 0.14 : 0)
                Behavior on color {
                    enabled: !Motion.reduce
                    ColorAnimation { duration: Motion.fast; easing.type: Motion.easeStandard }
                }
            }

            Pill.MaterialIcon {
                anchors.centerIn: parent
                text: "settings"
                color: island.ink
                opacity: 0.75
                font.pixelSize: 18
            }

            HoverHandler { id: settingsHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: island.settingsToggled()
            }
        }
    }

    // A battery at 20% or lower rings the island in error red, pulsing gently,
    // so the warning reads from across the room without touching the clock.
    Rectangle {
        anchors.fill: clockPill
        anchors.margins: -5
        radius: clockPill.radius + 5
        color: "transparent"
        border.width: 2
        border.color: Theme.error
        visible: Battery.present && Battery.low
        z: 1

        SequentialAnimation on opacity {
            running: Battery.present && Battery.low
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0.35; duration: 1100; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.35; to: 1; duration: 1100; easing.type: Easing.InOutSine }
        }
    }

    // One shadow per island: a single shadow around the root would smear the
    // empty space between them. The clock's rides above the music so the
    // expanding pill still reads as floating over it.
    RectangularShadow {
        anchors.fill: music
        radius: music.radius
        blur: 30
        spread: 2
        offset: Qt.vector2d(0, 6)
        color: Qt.rgba(0, 0, 0, 0.6)
        opacity: island.trackPresence * (island.quickOpen ? 0 : 1)
        z: -1
    }
    RectangularShadow {
        anchors.fill: clockPill
        radius: clockPill.radius
        blur: 24
        spread: 2
        offset: Qt.vector2d(0, 4)
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 1
    }
}
