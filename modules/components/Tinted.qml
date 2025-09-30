pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import qs.modules.theme
import qs.config

Item {
    property var sourceItem: null  // The icon item to tint

    Loader {
        active: Config.tintIcons
        anchors.fill: parent
        sourceComponent: Item {
            Desaturate {
                id: desaturate
                visible: false
                anchors.fill: parent
                source: sourceItem
                desaturation: 0.3
            }
            ColorOverlay {
                anchors.fill: parent
                source: desaturate
                color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.2)
            }
        }
    }
}