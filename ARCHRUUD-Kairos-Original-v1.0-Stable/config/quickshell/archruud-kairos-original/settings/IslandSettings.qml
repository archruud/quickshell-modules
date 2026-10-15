pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../IslandMetrics.js" as M

// Kairos' own settings (shell.json "kairos"), read through Config and written
// back through the shell daemon, the one writer of shell.json. An absent key
// reads as the shipped metric, so the island is whole until a value changes it.
Scope {
    id: s

    readonly property var raw: (Config.kairos && typeof Config.kairos === "object")
        ? Config.kairos : ({})

    function num(key, fallback) {
        var v = s.raw[key];
        return (typeof v === "number" && isFinite(v)) ? v : fallback;
    }
    function bool(key, fallback) {
        var v = s.raw[key];
        return (typeof v === "boolean") ? v : fallback;
    }
    function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }

    // Four independent padding controls. Unlike the previous island scale and
    // top offset, these only affect breathing room around the clock contents.
    readonly property real padLeft: s.clamp(s.num("padLeft", 16), 0, 64)
    readonly property real padRight: s.clamp(s.num("padRight", 16), 0, 64)
    readonly property real padTop: s.clamp(s.num("padTop", 6), 0, 64)
    readonly property real padBottom: s.clamp(s.num("padBottom", 10), 0, 64)
    readonly property bool clock12h: s.bool("clock12h", false)
    readonly property bool clockSeconds: s.bool("clockSeconds", true)
    readonly property bool dateWheel: s.bool("dateWheel", true)
    readonly property bool music: s.bool("music", true)
    readonly property bool tray: s.bool("tray", true)
    readonly property real musicPeek: s.clamp(s.num("musicPeek", M.musicPeekHeight), 70, 140)
    readonly property bool showLocation: s.bool("showLocation", true)

    // ARCHRUUD shoulder drawing connects to the physical top edge. The top
    // padding controls clock-to-edge spacing, not a floating-window offset.
    readonly property real topGap: 0
    readonly property real restFontSize: M.restFontSize
    readonly property real hoverWidth: M.hoverWidth
    readonly property real hoverHeight: (s.dateWheel ? M.hoverHeight : M.hoverHeight * 0.7)
    readonly property real hoverRadius: M.hoverRadius
    readonly property real hoverFontSize: M.hoverFontSize
    readonly property real wheelTop: M.wheelTop
    readonly property real wheelHeight: M.wheelHeight

    function defaults() {
        return {
            padLeft: 16,
            padRight: 16,
            padTop: 6,
            padBottom: 10,
            clock12h: false,
            clockSeconds: true,
            dateWheel: true,
            music: true,
            tray: true,
            musicPeek: M.musicPeekHeight,
            showLocation: true
        };
    }

    function set(key, value) {
        s._queue("kairos." + key, value);
    }
    // A shell-wide key (not under "kairos"): the weather location lives in the
    // shared shell store, so it is patched straight.
    function setGlobal(path, value) {
        s._queue(path, value);
    }
    function reset() {
        s._queue("kairos", s.defaults());
    }
    function _queue(path, value) { Config.setPath(path,value); }
}
