pragma Singleton
import QtQuick
import Quickshell

Singleton {
 function label(d) { return d ? String(d.name || d.deviceName || d.address || "Bluetooth device") : ""; }
 function typeLabel(d) { return "Device"; }
 function glyphFor(d) { return "bluetooth"; }
 function linkCommand(mac) { return ["bluetoothctl", "connect", mac]; }
}
