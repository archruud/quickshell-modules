pragma ComponentBehavior: Bound
import QtQuick
import "../services"

Column {
    id: box
    property string placeKey: "home"
    property string label: "Home"
    spacing: 5
    readonly property color ink: Theme.ink(Theme.shadow, 7)
    readonly property var place: (Config.locations && Config.locations[placeKey]) || ({lat:0,lon:0})
    Text { text: box.label + "  (latitude, longitude)"; color: box.ink; font.family: Theme.fontPrimary; font.pixelSize: 12; font.weight: Font.DemiBold }
    Row {
        width: parent.width; spacing: 8
        Rectangle {
            width: (box.width - 82 - 16)/2; height: 32; radius: 8
            color: "#17212d"; border.color: "#34495a"
            TextInput {
                id: lat
                anchors.fill: parent; anchors.margins: 8
                color: box.ink; font.family: Theme.mono; font.pixelSize: 12
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true; clip: true
                text: String(box.place.lat)
            }
        }
        Rectangle {
            width: (box.width - 82 - 16)/2; height: 32; radius: 8
            color: "#17212d"; border.color: "#34495a"
            TextInput {
                id: lon
                anchors.fill: parent; anchors.margins: 8
                color: box.ink; font.family: Theme.mono; font.pixelSize: 12
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true; clip: true
                text: String(box.place.lon)
            }
        }
        Rectangle {
            width: 82; height: 32; radius: 8; color: "#205a78"
            Text { anchors.centerIn: parent; text: "Save"; color: "white"; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: Weather.saveLocation(box.placeKey, lat.text, lon.text)
            }
        }
    }
}
