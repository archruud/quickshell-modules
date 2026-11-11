pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// ARCHRUUD Kairos v1.0.1: track the actual default output/input explicitly.
// PwNode.audio.volume and .muted cannot be read or written reliably until
// the corresponding node has been bound using PwObjectTracker.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var all: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var outputs: all.filter(function(n) {
        return n && PwNodeType.toString(n.type) === "AudioSink";
    })
    readonly property var inputs: all.filter(function(n) {
        return n && PwNodeType.toString(n.type) === "AudioSource";
    })

    // Keep the device list tracking used by the existing Sound page.
    PwObjectTracker { objects: root.all }
    // Most important: follow default changes, including USB / Bluetooth swaps.
    PwObjectTracker { objects: [root.sink, root.source] }

    function normalized(v) { return Math.max(0, Math.min(1, Number(v) || 0)); }
    function setOutput(n) { if (n) Pipewire.preferredDefaultAudioSink = n; }
    function setInput(n) { if (n) Pipewire.preferredDefaultAudioSource = n; }
    function nodeLabel(n) { return n ? (n.description || n.name || "Audio device") : ""; }
    function nodeIcon(n) { return "speaker"; }

    // Smooth updates during a slider drag via the tracked PipeWire node.
    function setOutputVolume(v) {
        var a = root.sink && root.sink.audio;
        if (!a) return;
        if (a.muted && v > 0) a.muted = false;
        a.volume = root.normalized(v);
    }
    function setInputVolume(v) {
        var a = root.source && root.source.audio;
        if (!a) return;
        if (a.muted && v > 0) a.muted = false;
        a.volume = root.normalized(v);
    }

    // Commit via the same wpctl backend as standard Hyprland volume keys.
    // This provides a fallback if a transient/default PipeWire node was null
    // while dragging; it never changes a different configured device explicitly.
    function commitOutputVolume(v) {
        Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.0",
                                 "@DEFAULT_AUDIO_SINK@", Math.round(root.normalized(v) * 100) + "%"]);
    }
    function commitInputVolume(v) {
        Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.0",
                                 "@DEFAULT_AUDIO_SOURCE@", Math.round(root.normalized(v) * 100) + "%"]);
    }
    // Only ONE mute operation: avoid toggling twice (QML + wpctl).
    function toggleOutputMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }
    function toggleInputMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }
}
