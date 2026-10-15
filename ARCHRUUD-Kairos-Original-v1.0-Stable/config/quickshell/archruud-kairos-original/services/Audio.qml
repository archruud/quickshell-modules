pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
Singleton {
 id: root
 readonly property var sink: Pipewire.defaultAudioSink
 readonly property var source: Pipewire.defaultAudioSource
 readonly property var all: Pipewire.nodes ? Pipewire.nodes.values : []
 readonly property var outputs: all.filter(function (n) { return n && PwNodeType.toString(n.type) === "AudioSink"; })
 readonly property var inputs: all.filter(function (n) { return n && PwNodeType.toString(n.type) === "AudioSource"; })
 PwObjectTracker { objects: root.all }
 function setOutput(n) { if (n) Pipewire.preferredDefaultAudioSink = n; }
 function setInput(n) { if (n) Pipewire.preferredDefaultAudioSource = n; }
 function nodeLabel(n) { return n ? (n.description || n.name || "Audio device") : ""; }
 function nodeIcon(n) { return "speaker"; }
}
