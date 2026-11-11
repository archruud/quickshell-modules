pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// ARCHRUUD Music: use the local MPRIS D-Bus players directly.
// No Ryoku daemon, no external music service and no periodic shell command.
Singleton {
    id: root

    // Mpris.players is a Quickshell ObjectModel. .values exposes its live
    // MprisPlayer objects in QML. A paused but controllable player is kept
    // available for resuming playback.
    readonly property var playerSet: Mpris.players ? Mpris.players.values : []
    property var player: null
    property string selectedDbusName: ""
    readonly property int playerCount: root._eligible().length
    readonly property bool present: root.player !== null
        && String(root.player.trackTitle || "").length > 0
    readonly property bool playing: root.player !== null && root.player.isPlaying

    function _eligible() {
        var out = [];
        var list = root.playerSet || [];
        for (var i = 0; i < list.length; ++i) {
            var p = list[i];
            // Only advertise titled tracks; cycling through empty players
            // would make the music bubble disappear.
            if (p && String(p.dbusName || "").length > 0
                  && String(p.trackTitle || "").length > 0) out.push(p);
        }
        return out;
    }

    function choose() {
        var list = root._eligible();
        var chosen = null;

        // Respect an explicit choice while that player still exists.
        if (root.selectedDbusName.length > 0) {
            for (var i = 0; i < list.length; ++i) {
                if (list[i].dbusName === root.selectedDbusName) {
                    chosen = list[i];
                    break;
                }
            }
            if (!chosen) root.selectedDbusName = "";
        }

        if (!chosen) {
            // Prefer the currently playing player, even when another
            // paused browser tab remains registered over D-Bus.
            for (var j = 0; j < list.length; ++j) {
                if (list[j].isPlaying && String(list[j].trackTitle || "").length > 0) {
                    chosen = list[j];
                    break;
                }
            }
        }
        if (!chosen && root.player !== null) {
            // Avoid jumping between paused players unnecessarily.
            for (var k = 0; k < list.length; ++k) {
                if (list[k].dbusName === root.player.dbusName) {
                    chosen = list[k];
                    break;
                }
            }
        }
        if (!chosen) {
            for (var m = 0; m < list.length; ++m) {
                if (String(list[m].trackTitle || "").length > 0) {
                    chosen = list[m];
                    break;
                }
            }
        }
        if (!chosen && list.length > 0) chosen = list[0];
        if (root.player !== chosen) root.player = chosen;
    }

    // Called by the source label in the expanded music panel.
    function cyclePlayer() {
        var list = root._eligible();
        if (list.length < 2) return;
        var index = -1;
        for (var i = 0; i < list.length; ++i) {
            if (root.player && list[i].dbusName === root.player.dbusName) {
                index = i;
                break;
            }
        }
        root.selectedDbusName = list[(index + 1) % list.length].dbusName;
        root.choose();
    }

    onPlayerSetChanged: root.choose()
    Component.onCompleted: root.choose()
    // Playing/track metadata changes need a fresh ranking too; this does
    // not poll the media player via subprocess or modify playback state.
    Timer {
        interval: 1200
        repeat: true
        running: true
        onTriggered: root.choose()
    }
}
