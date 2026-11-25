pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
 id: root
 property var kairos: ({padLeft:16,padRight:16,padTop:6,padBottom:10,clock12h:false,clockSeconds:true,dateWheel:true,music:true,tray:true,showLocation:true})
 readonly property var formatLoc: Qt.locale("nb_NO")
 property string weatherLocation: ""
 property string weatherUnit: "celsius"
 property string weatherSpot: "auto"
 property var locations: ({home:{name:"Hjemme",lat:59.546666,lon:11.626059},cabin:{name:"Hytta",lat:59.367511,lon:11.840253}})
 property bool loaded: false
 Process {
  id: reader
  running: true
  command: ["python3", Quickshell.shellPath("scripts/backend.py"), "settings"]
  stdout: StdioCollector {
   onStreamFinished: {
    try { var s=JSON.parse(text); root.kairos=s.kairos; root.weatherLocation=s.weatherLocation || ""; root.weatherUnit=s.weatherUnit || "celsius"; root.weatherSpot=s.weatherSpot || "auto"; root.locations=s.locations || root.locations; }
    catch(e) { console.warn("ARCHRUUD Kairos settings:",e); }
    root.loaded=true;
   }
  }
 }
 Process { id: writer }
 function setPath(path, value) {
  if (path === "kairos") root.kairos = value;
  else if (path.indexOf("kairos.") === 0) {
    var o=Object.assign({},root.kairos);
    o[path.slice(7)] = value; root.kairos=o;
  } else if (path === "weatherLocation") root.weatherLocation=String(value);
  else if (path === "weatherUnit") root.weatherUnit=String(value);
  else if (path === "weatherSpot") root.weatherSpot=String(value);
  if (!writer.running) writer.exec(["python3",Quickshell.shellPath("scripts/backend.py"),"set",path,JSON.stringify(value)]);
 }
}
