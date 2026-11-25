pragma ComponentBehavior: Bound

import QtQuick
import "../../services"
import "../../barkit" as Pill
import "../kit" as K

// ARCHRUUD native MET Norway forecast. No Yr iframe/HTML scraping.
Column {
    id: page
    property var host
    spacing: 11
    readonly property color fill: Theme.shadow
    readonly property color ink: Theme.ink(fill, 7)
    readonly property color accent: Theme.primary
    function dim(a) { return Qt.rgba(page.ink.r, page.ink.g, page.ink.b, a) }
    function glyph(code) {
        var c = Number(code);
        if (c === 0) return "wx-clear-day";
        if (c === 1 || c === 2) return "wx-partly-cloudy-day";
        if (c === 45 || c === 48) return "wx-fog";
        if (c === 61 || c === 63 || c === 65) return "wx-rain";
        if (c === 66 || c === 67) return "wx-sleet";
        if (c === 71 || c === 73 || c === 75) return "wx-snow";
        if (c === 95) return "wx-thunderstorm";
        return "wx-cloudy";
    }
    property bool week: false

    Item {
        height: 35; width: parent.width
        K.QsBack {
            id: back
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            onClicked: page.host.back()
        }
        Text {
            anchors { left: back.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
            text: "Weather  ·  MET Norway"
            font.family: Theme.fontPrimary
            font.pixelSize: 17
            font.weight: Font.DemiBold
            color: page.ink
        }
    }
    Text {
        width: parent.width
        text: "Choose one weather location"
        font.family: Theme.fontPrimary
        font.pixelSize: 11
        color: page.dim(0.55)
    }
    Row {
        spacing: 7
        K.QsChip {
            text: "Automatic"
            active: Config.weatherSpot === "auto"
            onClicked: Weather.selectSpot("auto")
        }
        K.QsChip {
            text: "Home"
            active: Config.weatherSpot === "home"
            onClicked: Weather.selectSpot("home")
        }
        K.QsChip {
            text: "Cabin"
            active: Config.weatherSpot === "cabin"
            onClicked: Weather.selectSpot("cabin")
        }
        K.QsChip {
            visible: !!(Config.locations && Config.locations.custom)
            text: "Selected"
            active: Config.weatherSpot === "custom"
            onClicked: Weather.selectSpot("custom")
        }
    }
    Rectangle {
        width: parent.width
        height: 94
        radius: 18
        color: page.dim(0.07)
        Column {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: 13
            spacing: 5
            Text {
                width: parent.width
                text: Weather.city || (Config.weatherSpot === "auto" ? "Detecting location..." : "Weather")
                font.family: Theme.fontPrimary
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: page.ink
                elide: Text.ElideRight
            }
            Row {
                spacing: 11
                Pill.GlyphIcon {
                    width: 36; height: 36
                    name: page.glyph(Weather.current ? Weather.current.code : -1)
                    color: page.accent
                }
                Text {
                    text: Weather.available ? (Math.round(Weather.tempNow) + "°") : "--°"
                    font.family: Theme.mono; font.pixelSize: 28
                    font.weight: Font.Bold; color: page.ink
                }
                Column {
                    spacing: 1
                    Text {
                        text: Weather.available ? Weather.condition : (Weather.status || "No forecast")
                        font.family: Theme.fontPrimary; font.pixelSize: 11
                        color: page.ink
                    }
                    Text {
                        text: Weather.available ? ("Wind " + Weather.wind + " m/s") : ""
                        font.family: Theme.fontPrimary; font.pixelSize: 10
                        color: page.dim(0.62)
                    }
                }
            }
        }
    }
    Row {
        spacing: 7
        K.QsChip { text: "Next 24 hours"; active: !page.week; onClicked: page.week = false }
        K.QsChip { text: "Next 8 days"; active: page.week; onClicked: page.week = true }
    }
    Text {
        width: parent.width
        visible: (page.week ? Weather.daily : Weather.hourly).length === 0
        text: Weather.status || "Waiting for forecast..."
        font.family: Theme.fontPrimary; font.pixelSize: 11
        color: page.dim(0.62)
        wrapMode: Text.WordWrap
    }
    Repeater {
        model: page.week ? Weather.daily : Weather.hourly
        delegate: Rectangle {
            id: forecastRow
            required property var modelData
                required property int index
            width: page.width
            height: 37
            radius: 9
            color: (index % 2 === 0) ? page.dim(0.04) : "transparent"
            Text {
                anchors { left: parent.left; leftMargin: 9; verticalCenter: parent.verticalCenter }
                width: 92
                text: page.week ? String(forecastRow.modelData.day) : String(forecastRow.modelData.time)
                font.family: Theme.mono; font.pixelSize: 12; color: page.ink
            }
            Pill.GlyphIcon {
                anchors.centerIn: parent
                width: 22; height: 22
                name: page.glyph(forecastRow.modelData.code)
                color: page.accent
            }
            Text {
                anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                text: page.week ? (forecastRow.modelData.min + "° / " + forecastRow.modelData.max + "°")
                    : (forecastRow.modelData.temp + "°")
                font.family: Theme.mono; font.pixelSize: 12; color: page.ink
            }
        }
    }
    Text {
        width: parent.width
        text: Weather.status || "Data: MET Norway / Yr"
        font.family: Theme.fontPrimary; font.pixelSize: 10
        color: page.dim(0.45)
        wrapMode: Text.WordWrap
    }
}
