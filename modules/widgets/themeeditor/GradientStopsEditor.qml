pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

GroupBox {
    id: root

    required property var colorNames
    required property var stops

    signal updateStops(var newStops)

    title: "Gradient Stops (" + stops.length + "/20)"

    background: StyledRect {
        variant: "common"
    }

    label: Text {
        text: parent.title
        font.family: Styling.defaultFont
        font.pixelSize: 12
        font.bold: true
        color: Colors.primary
        leftPadding: 8
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Gradient preview bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            radius: Styling.radius(-12)
            border.color: Colors.outline
            border.width: 1

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    property var stopData: root.stops[0] || ["surface", 0.0]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[1] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[2] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[3] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[4] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[5] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[6] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[7] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[8] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: root.stops[9] || root.stops[root.stops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                id: addButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                enabled: root.stops.length < 20

                background: StyledRect {
                    variant: addButton.enabled ? (addButton.hovered ? "primaryfocus" : "primary") : "common"
                    opacity: addButton.enabled ? 1.0 : 0.5
                }

                contentItem: RowLayout {
                    spacing: 4

                    Text {
                        text: Icons.plus
                        font.family: Icons.font
                        font.pixelSize: 12
                        color: addButton.enabled ? Colors.overPrimary : Colors.overBackground
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Add Stop"
                        font.family: Styling.defaultFont
                        font.pixelSize: 11
                        color: addButton.enabled ? Colors.overPrimary : Colors.overBackground
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    if (root.stops.length >= 20) return;

                    let newStops = root.stops.slice();
                    // Add at position 1.0 with surface color
                    newStops.push(["surface", 1.0]);
                    // Sort by position
                    newStops.sort((a, b) => a[1] - b[1]);
                    root.updateStops(newStops);
                }
            }

            Button {
                id: clearButton
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                background: StyledRect {
                    variant: clearButton.hovered ? "errorfocus" : "error"
                }

                contentItem: RowLayout {
                    spacing: 4

                    Text {
                        text: Icons.broom
                        font.family: Icons.font
                        font.pixelSize: 12
                        color: Colors.overError
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: "Reset"
                        font.family: Styling.defaultFont
                        font.pixelSize: 11
                        color: Colors.overError
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                onClicked: {
                    // Reset to single default stop
                    root.updateStops([["surface", 0.0]]);
                }
            }
        }

        // Stops list
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(root.stops.length * 44, 220)
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.stops

                    delegate: StyledRect {
                        id: stopDelegate

                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        variant: "internalbg"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            // Stop number
                            Text {
                                text: (stopDelegate.index + 1) + "."
                                font.family: Styling.defaultFont
                                font.pixelSize: 11
                                font.bold: true
                                color: Colors.primary
                                Layout.preferredWidth: 20
                            }

                            // Color preview
                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                radius: Styling.radius(-12)
                                color: Config.resolveColor(stopDelegate.modelData[0])
                                border.color: Colors.outline
                                border.width: 1
                            }

                            // Color selector (simplified inline version)
                            ComboBox {
                                id: stopColorCombo
                                Layout.fillWidth: true
                                Layout.preferredHeight: 28

                                readonly property bool isHex: stopDelegate.modelData[0].startsWith("#")

                                model: ["Custom"].concat(root.colorNames)
                                currentIndex: {
                                    if (isHex) return 0;
                                    const idx = root.colorNames.indexOf(stopDelegate.modelData[0]);
                                    return idx >= 0 ? idx + 1 : 0;
                                }

                                onActivated: idx => {
                                    if (idx === 0) return;
                                    let newStops = root.stops.slice();
                                    newStops[stopDelegate.index] = [root.colorNames[idx - 1], newStops[stopDelegate.index][1]];
                                    root.updateStops(newStops);
                                }

                                background: StyledRect {
                                    variant: stopColorCombo.hovered ? "focus" : "common"
                                }

                                contentItem: Text {
                                    text: stopColorCombo.isHex ? "Custom" : stopDelegate.modelData[0]
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 10
                                    color: Colors.overBackground
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 6
                                }

                                indicator: Text {
                                    x: stopColorCombo.width - width - 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: Icons.caretDown
                                    font.family: Icons.font
                                    font.pixelSize: 10
                                    color: Colors.overBackground
                                }

                                popup: Popup {
                                    y: stopColorCombo.height + 2
                                    width: stopColorCombo.width
                                    implicitHeight: contentItem.implicitHeight > 200 ? 200 : contentItem.implicitHeight
                                    padding: 2

                                    background: StyledRect {
                                        variant: "pane"
                                        enableShadow: true
                                    }

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: stopColorCombo.popup.visible ? stopColorCombo.delegateModel : null
                                        currentIndex: stopColorCombo.highlightedIndex
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }
                                }

                                delegate: ItemDelegate {
                                    id: colorDelegate
                                    required property var modelData
                                    required property int index

                                    width: stopColorCombo.width - 4
                                    height: 24

                                    background: StyledRect {
                                        variant: colorDelegate.highlighted ? "focus" : "common"
                                    }

                                    contentItem: RowLayout {
                                        spacing: 4

                                        Rectangle {
                                            Layout.preferredWidth: 14
                                            Layout.preferredHeight: 14
                                            radius: 2
                                            color: colorDelegate.index === 0 ? "transparent" : (Colors[root.colorNames[colorDelegate.index - 1]] || "transparent")
                                            border.color: Colors.outline
                                            border.width: colorDelegate.index === 0 ? 0 : 1
                                        }

                                        Text {
                                            text: colorDelegate.modelData
                                            font.family: Styling.defaultFont
                                            font.pixelSize: 10
                                            color: Colors.overBackground
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    highlighted: stopColorCombo.highlightedIndex === index
                                }
                            }

                            // Position input
                            SpinBox {
                                id: positionSpinner
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                from: 0
                                to: 100
                                value: stopDelegate.modelData[1] * 100
                                editable: true

                                onValueModified: {
                                    let newStops = root.stops.slice();
                                    newStops[stopDelegate.index] = [newStops[stopDelegate.index][0], value / 100.0];
                                    // Sort by position
                                    newStops.sort((a, b) => a[1] - b[1]);
                                    root.updateStops(newStops);
                                }

                                textFromValue: function(value, locale) {
                                    return (value / 100.0).toFixed(2);
                                }

                                valueFromText: function(text, locale) {
                                    return Math.round(parseFloat(text) * 100);
                                }

                                background: StyledRect { variant: "common" }

                                contentItem: TextInput {
                                    text: positionSpinner.textFromValue(positionSpinner.value, positionSpinner.locale)
                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: parent.width - width
                                    height: parent.height
                                    implicitWidth: 18
                                    variant: positionSpinner.up.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 10
                                        color: positionSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: 0
                                    height: parent.height
                                    implicitWidth: 18
                                    variant: positionSpinner.down.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 10
                                        color: positionSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            // Delete button
                            Button {
                                id: deleteButton
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                enabled: root.stops.length > 1

                                background: StyledRect {
                                    variant: deleteButton.enabled ? (deleteButton.hovered ? "error" : "common") : "common"
                                    opacity: deleteButton.enabled ? 1.0 : 0.3
                                }

                                contentItem: Text {
                                    text: Icons.trash
                                    font.family: Icons.font
                                    font.pixelSize: 12
                                    color: deleteButton.enabled ? (deleteButton.hovered ? Colors.overError : Colors.overBackground) : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    if (root.stops.length <= 1) return;

                                    let newStops = root.stops.slice();
                                    newStops.splice(stopDelegate.index, 1);
                                    root.updateStops(newStops);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
