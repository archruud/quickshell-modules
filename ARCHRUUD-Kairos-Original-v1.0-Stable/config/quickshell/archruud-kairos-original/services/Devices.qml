pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
 id: root
 property bool backlightAvailable: false
 property int backlightPct: 50
 property var ddcMonitors: []
 Process { id: brightness; command:["python3",Quickshell.shellPath("scripts/backend.py"),"brightness"];
 stdout:StdioCollector{onStreamFinished:{try{var v=JSON.parse(text);root.backlightAvailable=!!v.available;root.backlightPct=v.percent||50;}catch(e){}}} }
 Timer {interval:15000;running:true;repeat:true;triggeredOnStart:true;onTriggered:if(!brightness.running)brightness.running=true}
 function setBacklight(pct) { setProc.exec(["brightnessctl","set",Math.round(pct)+"%"]); }
 function setBrightness(bus,pct) { /* External DDC support is pending. */ }
 function startProbes(owner) {}
 function stopProbes(owner) {}
 function parseBrightness(s) { return 0; }
 Process { id:setProc }
}
