import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.modules.workspaces
import qs.modules.theme
import qs.modules.clock
import qs.modules.systray
import qs.modules.launcher
import qs.config

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
        // bottom: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusiveZone: Configuration.bar.showBackground ? 44 : 40
    implicitHeight: 44

    Rectangle {
        id: bar
        anchors.fill: parent

        property color bgcolor: Qt.rgba(Qt.color(Colors.background).r, Qt.color(Colors.background).g, Qt.color(Colors.background).b, 0.5)

        color: Configuration.bar.showBackground ? bgcolor : "transparent"

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.5)
        }

        // Fake bottom border
        Rectangle {
            height: 0
            color: Colors.background
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        // Left side of bar
        RowLayout {
            id: leftSide
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            Workspaces {
                bar: QtObject {
                    property var screen: panel.screen
                }
            }
        }

        // Right side of bar
        RowLayout {
            id: rightSide
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            spacing: 4

            SysTray {
                bar: panel
            }

            Clock {
                id: clockComponent
            }
        }
    }
}
