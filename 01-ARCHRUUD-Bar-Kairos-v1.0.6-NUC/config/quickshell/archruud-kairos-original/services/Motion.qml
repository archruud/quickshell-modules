pragma Singleton
import QtQuick
import Quickshell

Singleton {
 readonly property bool reduce: false
 readonly property int morph: 260
 readonly property int fast: 160
 readonly property int spatial: 230
 readonly property int easeStandard: Easing.OutCubic
 readonly property int spatialCurve: Easing.OutCubic
}
