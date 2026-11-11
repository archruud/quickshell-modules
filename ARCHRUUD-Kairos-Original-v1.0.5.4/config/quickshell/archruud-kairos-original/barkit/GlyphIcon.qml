import QtQuick

// Standalone ARCHRUUD mapping of Ryoku glyph names to installed Material
// Symbols Rounded ligatures. No placeholder Unicode artwork or embedded fonts.
Text {
    id: root
    property string name: "info"
    readonly property var map: ({
        "wifi": "wifi", "bluetooth": "bluetooth", "speaker": "volume_up",
        "audio": "volume_up", "monitor": "desktop_windows", "battery": "battery_full",
        "sun": "light_mode", "moon": "dark_mode",
        "wx-clear-day": "sunny", "wx-clear-night": "clear_night",
        "wx-partly-cloudy-day": "partly_cloudy_day",
        "wx-partly-cloudy-night": "partly_cloudy_night",
        "wx-cloudy": "cloud", "wx-overcast": "cloud",
        "wx-mist": "foggy", "wx-fog": "foggy",
        "wx-drizzle": "rainy", "wx-rain-light": "rainy",
        "wx-rain": "rainy", "wx-rain-heavy": "rainy_heavy",
        "wx-sleet": "weather_mix", "wx-snow-light": "weather_snowy",
        "wx-snow": "weather_snowy", "wx-snow-heavy": "weather_snowy",
        "wx-thunderstorm": "thunderstorm", "wx-hail": "weather_hail",
        "wx-unknown": "cloud"
    })
    text: map[name] || "devices_other"
    font.family: "Material Symbols Rounded"
    font.pixelSize: Math.max(12, Math.min(width, height) * 0.8)
    font.weight: Font.Normal
    font.letterSpacing: 0
    color: "#EAF6FF"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
