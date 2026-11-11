pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
Singleton {
 readonly property var bat: UPower.displayDevice
 readonly property bool present: bat && bat.isLaptopBattery && bat.isPresent
 readonly property int pct: present ? Math.round(bat.percentage * 100) : 100
 readonly property bool charging: present && bat.state === UPowerDeviceState.Charging
 readonly property bool low: present && !charging && pct <= 20
}
