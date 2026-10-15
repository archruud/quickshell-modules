pragma Singleton
import QtQuick
import Quickshell

Singleton {
  // Ryoku's tray DBusMenu daemon is not part of this standalone port.
  property var items: []
  function activate(service,x,y) {}
  function aboutToShow(service) {}
  function menuEvent(service,id) {}
}
