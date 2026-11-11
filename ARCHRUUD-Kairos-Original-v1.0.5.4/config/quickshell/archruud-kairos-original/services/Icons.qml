pragma Singleton
import QtQuick
import Quickshell

Singleton { function path(name, fallback) { return "image://icon/" + String(name || "application-x-executable"); } }
