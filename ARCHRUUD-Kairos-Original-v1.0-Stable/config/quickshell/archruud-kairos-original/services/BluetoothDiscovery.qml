pragma Singleton
import QtQuick
import Quickshell

Singleton {
 function setDiscovering(owner, adapter, want) {
  if (!adapter) return;
  adapter.discovering = want && adapter.enabled;
 }
}
