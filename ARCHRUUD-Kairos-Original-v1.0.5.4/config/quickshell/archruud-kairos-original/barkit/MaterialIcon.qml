import QtQuick

// Material Symbols uses text ligatures to draw icon shapes.
// Arch extra package: ttf-material-symbols-variable.
// Keep this as a normal Text-derived component: callers bind `text`, `color`
// and `font.pixelSize` just as they did in the Ryoku source.
Text {
    id: root
    property real fill: 0
    text: "help_outline"
    font.family: "Material Symbols Rounded"
    font.pixelSize: 18
    font.weight: Font.Normal
    font.letterSpacing: 0
    color: "#EAF6FF"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
