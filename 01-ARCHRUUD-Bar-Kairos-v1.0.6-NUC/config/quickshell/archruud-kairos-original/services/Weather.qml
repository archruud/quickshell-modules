pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Standalone MET Norway weather client. Mode changes are persisted by
// backend.py and a refresh follows only after the write completes.
Singleton {
    id: root
    property bool available: false
    property var current: null
    property string city: ""
    property string location: ""
    property string condition: ""
    property real tempNow: 0
    property real wind: 0
    property bool isDay: true
    property string status: ""
    property var hourly: []
    property var daily: []
    property bool refreshQueued: false
    property var searchResults: []
    property string searchStatus: ""
    property bool searching: false
    property string locationStatus: ""

    // Search runs ONLY when the user explicitly submits, not during typing.
    function findPlace(query) {
        if (lookup.running) return;
        root.searchResults = [];
        root.searchStatus = "Searching...";
        root.searching = true;
        lookup.exec(["python3", Quickshell.shellPath("scripts/backend.py"), "search-place", query]);
    }
    function usePlace(place) {
        if (places.running) return;
        root.locationStatus = "Saving selected location...";
        places.exec(["python3", Quickshell.shellPath("scripts/backend.py"), "use-place", JSON.stringify(place)]);
    }
    function saveLocation(which, latText, lonText) {
        if (places.running || (which !== "home" && which !== "cabin")) return;
        var lat = Number(String(latText).trim().replace(",", "."));
        var lon = Number(String(lonText).trim().replace(",", "."));
        if (!isFinite(lat) || !isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180
              || !String(latText).trim() || !String(lonText).trim()) {
            root.locationStatus = "Invalid coordinates (latitude -90..90, longitude -180..180)";
            return;
        }
        root.locationStatus = "Saving coordinates...";
        var name = which === "home" ? "Hjemme" : "Hytta";
        places.exec(["python3", Quickshell.shellPath("scripts/backend.py"), "save-location", which,
                     JSON.stringify({name:name,lat:lat,lon:lon})]);
    }
    Process {
        id: lookup
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var r=JSON.parse(text);
                    root.searchResults=r.results || [];
                    root.searchStatus=r.status || "";
                } catch(e) { root.searchStatus="Place search failed"; }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.searching = false;
            if (exitCode !== 0) root.searchStatus = "Search failed. Try again later.";
        }
    }
    Process {
        id: places
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var r=JSON.parse(text);
                    var locations=Object.assign({}, Config.locations);
                    locations[r.key]=r.place;
                    Config.locations=locations;
                    Config.weatherSpot=r.spot;
                    root.locationStatus = (r.key === "custom" ? "Place selected: " : "Coordinates saved: ") + r.place.name;
                    root.refresh();
                } catch(e) { root.locationStatus = "Could not save location"; }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.locationStatus = "Could not save location. Check permissions.";
        }
    }

    function refresh() {
        if (poll.running) { root.refreshQueued = true; return; }
        poll.running = true;
    }
    function selectSpot(mode) {
        if (mode !== "auto" && mode !== "home" && mode !== "cabin" && mode !== "custom") return;
        if (selector.running) return;
        Config.weatherSpot = mode; // Immediate mutual exclusion in the UI
        root.available = false; root.city = ""; root.current = null;
        root.status = "Loading weather...";
        selector.exec(["python3", Quickshell.shellPath("scripts/backend.py"),
                       "set", "weatherSpot", JSON.stringify(mode)]);
    }
    function setUnit(unit) {
        if (unit !== "celsius" && unit !== "fahrenheit") return;
        if (units.running) return;
        Config.weatherUnit = unit;
        units.exec(["python3", Quickshell.shellPath("scripts/backend.py"),
                    "set", "weatherUnit", JSON.stringify(unit)]);
    }
    Process {
        id: selector
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) console.warn("Kairos: unable to save weather mode");
            root.refresh();
        }
    }
    Process {
        id: units
        onExited: (exitCode, exitStatus) => root.refresh()
    }
    Process {
        id: poll
        command: ["python3", Quickshell.shellPath("scripts/backend.py"), "weather"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var v = JSON.parse(text);
                    root.available = !!v.available;
                    root.current = v.current || null;
                    root.city = v.city || "";
                    root.location = v.location || "";
                    root.tempNow = Number(v.tempNow) || 0;
                    root.wind = Number(v.wind) || 0;
                    root.condition = v.condition || "";
                    root.isDay = v.isDay !== false;
                    root.status = v.status || "";
                    root.hourly = v.hourly || [];
                    root.daily = v.daily || [];
                } catch(e) {
                    console.warn("MET weather:", e);
                    root.status = "Unable to read weather response";
                }
            }
        }
        onExited: {
            if (root.refreshQueued) {
                root.refreshQueued = false;
                Qt.callLater(root.refresh);
            }
        }
    }
    Timer {
        running: true; repeat: true; interval: 900000; triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
