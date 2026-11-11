pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
 id: root
 property bool wifiPresent: false
 property bool wifiRadio: false
 property string wifiConnectivity: "Disconnected"
 property string activeSsid: ""
 property var accessPoints: []
 property string localIp: ""
 property string publicIp: ""
 signal replied(int id,bool ok,string error)
 property int opId: 0
 Process {
  id: poll
  command: ["python3",Quickshell.shellPath("scripts/backend.py"),"network"]
  stdout: StdioCollector {
   onStreamFinished: {
    try { var v=JSON.parse(text);
      root.wifiPresent=!!v.wifiPresent; root.wifiRadio=!!v.wifiRadio;
      root.wifiConnectivity=v.wifiConnectivity || "Disconnected";
      root.activeSsid=v.activeSsid || "";
      root.accessPoints=v.accessPoints || [];
      root.localIp=v.localIp || ""; root.publicIp=v.publicIp || "";
    } catch(e) { console.warn("Network status:",e); }
   }
  }
 }
 Process { id: cmd; stdout: StdioCollector { id: result }
  onExited: (code) => {root.replied(root.opId,code===0,result.text);root.refresh();}
 }
 Timer { running:true; repeat:true; interval:15000; triggeredOnStart:true;
  onTriggered: root.refresh() }
 function refresh() { if (!poll.running) poll.running=true; }
 function setWifiEnabled(v) { if (!cmd.running) cmd.exec(["python3",Quickshell.shellPath("scripts/backend.py"),"wifi-toggle",v?"on":"off"]); }
 function disconnectWifi() { if (!cmd.running) cmd.exec(["python3",Quickshell.shellPath("scripts/backend.py"),"wifi-disconnect"]); }
 function connectWifi(ssid,pass,bssid,hidden) {
  var id=++root.opId;
  if (pass && pass.length > 0) {
    Qt.callLater(function () { root.replied(id,false,"New password-protected networks are not supported yet. Please use nmgui."); });
    return id;
  }
  if (!cmd.running) cmd.exec(["python3",Quickshell.shellPath("scripts/backend.py"),"wifi-connect",ssid,pass||"",bssid||"",hidden?"yes":"no"]);
  return id;
 }
}
