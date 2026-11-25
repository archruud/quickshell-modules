pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../services"

Item {
    id: search
    // A human-readable label is optional for coordinates not listed on maps.
    // Place-name searches retain the geocoder's existing result names.
    readonly property bool coordinateQuery: /^\s*[+-]?\d{1,3}(?:\.\d+)?\s*[,; ]\s*[+-]?\d{1,3}(?:\.\d+)?\s*$/.test(query.text.trim())
    height: coordinateQuery ? 83 : 40
    readonly property color ink: Theme.ink(Theme.shadow, 7)
    Rectangle {
        id: field
        anchors.left: parent.left
        anchors.right: searchButton.left
        anchors.rightMargin: 8
        height: 36; radius: 10; color: "#17212d"; border.color: "#34495a"
        TextInput {
            id: query
            anchors.fill: parent; anchors.margins: 9
            font.family: Theme.fontPrimary; font.pixelSize: 12
            color: search.ink; clip: true; selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            onAccepted: search.submit()
            onTextChanged: labelInput.text = "" // New coordinates must not inherit the last place's label.
            Keys.onEscapePressed: (event) => { matches.close(); event.accepted = true; }
        }
        Text {
            anchors.fill: query
            visible: query.text.length === 0 && !query.activeFocus
            text: "Place name or 59.5, 11.6"
            color: "#8194a5"; font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }
    }
    Rectangle {
        id: searchButton
        anchors.right: parent.right
        width: 78; height: 36; radius: 10
        color: "#20638c"
        Text { anchors.centerIn: parent; text: "Search"; font.family: Theme.fontPrimary; color: "white"; font.pixelSize: 12 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: search.submit() }
    }
    Rectangle {
        id: labelField
        visible: search.coordinateQuery
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: field.bottom
        anchors.topMargin: 7
        height: 36; radius: 10; color: "#17212d"; border.color: "#34495a"
        TextInput {
            id: labelInput
            anchors.fill: parent; anchors.margins: 9
            font.family: Theme.fontPrimary; font.pixelSize: 12
            color: search.ink; clip: true; selectByMouse: true
            maximumLength: 80
            verticalAlignment: TextInput.AlignVCenter
            onAccepted: search.submit()
            Keys.onEscapePressed: (event) => { matches.close(); event.accepted = true; }
        }
        Text {
            anchors.fill: labelInput
            visible: labelInput.text.length === 0 && !labelInput.activeFocus
            text: "Optional place name, e.g. Ørje"
            color: "#8194a5"; font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }
    }
    function submit() {
        if (!query.text.trim() || Weather.searching) return;
        Weather.findPlace(query.text.trim());
        matches.open();
    }
    Popup {
        id: matches
        parent: search
        x: 0; y: search.height
        width: search.width
        padding: 8
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#0a1421"
            radius: 12
            border.width: 1
            border.color: "#349de1"
        }
        contentItem: Column {
            id: hits
            width: matches.width - 16
            spacing: 4
            Text {
                width: parent.width
                height: 25
                text: Weather.searching ? "Searching..." : (Weather.searchStatus || "Enter a place name")
                color: "#9bc9e6"; font.family: Theme.fontPrimary
                font.pixelSize: 12; verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            Repeater {
                model: Weather.searchResults
                delegate: Rectangle {
                    id: hit
                    required property var modelData
                    width: hits.width; height: 46
                    color: hover.hovered ? "#203952" : "#111f2c"
                    radius: 7
                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: search.coordinateQuery && labelInput.text.trim().length > 0
                            ? labelInput.text.trim() + " · " + String(hit.modelData.name)
                            : String(hit.modelData.name)
                        color: search.ink; font.family: Theme.fontPrimary
                        font.pixelSize: 12; verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.WordWrap
                    }
                    HoverHandler { id: hover }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var selected = Object.assign({}, hit.modelData);
                            if (search.coordinateQuery && labelInput.text.trim().length > 0)
                                selected.name = labelInput.text.trim();
                            Weather.usePlace(selected);
                            matches.close();
                        }
                    }
                }
            }
            Text {
                text: "© OpenStreetMap contributors"
                color: "#8da0b4"; font.pixelSize: 10
            }
        }
    }
}
