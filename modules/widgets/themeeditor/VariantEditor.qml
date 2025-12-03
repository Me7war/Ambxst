pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.config

StyledRect {
    id: root

    required property string variantId
    signal close()

    variant: "pane"

    // Get the config object for this variant
    readonly property var variantConfig: {
        switch (variantId) {
        case "bg": return Config.theme.srBg;
        case "internalbg": return Config.theme.srInternalBg;
        case "pane": return Config.theme.srPane;
        case "common": return Config.theme.srCommon;
        case "focus": return Config.theme.srFocus;
        case "primary": return Config.theme.srPrimary;
        case "primaryfocus": return Config.theme.srPrimaryFocus;
        case "overprimary": return Config.theme.srOverPrimary;
        case "secondary": return Config.theme.srSecondary;
        case "secondaryfocus": return Config.theme.srSecondaryFocus;
        case "oversecondary": return Config.theme.srOverSecondary;
        case "tertiary": return Config.theme.srTertiary;
        case "tertiaryfocus": return Config.theme.srTertiaryFocus;
        case "overtertiary": return Config.theme.srOverTertiary;
        case "error": return Config.theme.srError;
        case "errorfocus": return Config.theme.srErrorFocus;
        case "overerror": return Config.theme.srOverError;
        default: return Config.theme.srCommon;
        }
    }

    readonly property string variantDisplayName: {
        switch (variantId) {
        case "bg": return "Background";
        case "internalbg": return "Internal Background";
        case "pane": return "Pane";
        case "common": return "Common";
        case "focus": return "Focus";
        case "primary": return "Primary";
        case "primaryfocus": return "Primary Focus";
        case "overprimary": return "Over Primary";
        case "secondary": return "Secondary";
        case "secondaryfocus": return "Secondary Focus";
        case "oversecondary": return "Over Secondary";
        case "tertiary": return "Tertiary";
        case "tertiaryfocus": return "Tertiary Focus";
        case "overtertiary": return "Over Tertiary";
        case "error": return "Error";
        case "errorfocus": return "Error Focus";
        case "overerror": return "Over Error";
        default: return "Unknown";
        }
    }

    // List of available color names from Colors.qml
    readonly property var colorNames: [
        "background", "surface", "surfaceBright", "surfaceContainer",
        "surfaceContainerHigh", "surfaceContainerHighest", "surfaceContainerLow",
        "surfaceContainerLowest", "surfaceDim", "surfaceTint", "surfaceVariant",
        "primary", "primaryContainer", "primaryFixed", "primaryFixedDim",
        "secondary", "secondaryContainer", "secondaryFixed", "secondaryFixedDim",
        "tertiary", "tertiaryContainer", "tertiaryFixed", "tertiaryFixedDim",
        "error", "errorContainer",
        "overBackground", "overSurface", "overSurfaceVariant",
        "overPrimary", "overPrimaryContainer", "overPrimaryFixed", "overPrimaryFixedVariant",
        "overSecondary", "overSecondaryContainer", "overSecondaryFixed", "overSecondaryFixedVariant",
        "overTertiary", "overTertiaryContainer", "overTertiaryFixed", "overTertiaryFixedVariant",
        "overError", "overErrorContainer",
        "outline", "outlineVariant",
        "inversePrimary", "inverseSurface", "inverseOnSurface",
        "shadow", "scrim",
        "blue", "blueContainer", "overBlue", "overBlueContainer",
        "cyan", "cyanContainer", "overCyan", "overCyanContainer",
        "green", "greenContainer", "overGreen", "overGreenContainer",
        "magenta", "magentaContainer", "overMagenta", "overMagentaContainer",
        "red", "redContainer", "overRed", "overRedContainer",
        "yellow", "yellowContainer", "overYellow", "overYellowContainer",
        "white", "whiteContainer", "overWhite", "overWhiteContainer"
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Preview
            StyledRect {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                variant: root.variantId
                enableBorder: true

                Text {
                    anchors.centerIn: parent
                    text: Icons.cube
                    font.family: Icons.font
                    font.pixelSize: 24
                    color: parent.itemColor
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.variantDisplayName
                    font.family: Styling.defaultFont
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.primary
                }

                Text {
                    text: "variant: \"" + root.variantId + "\""
                    font.family: "monospace"
                    font.pixelSize: 11
                    color: Colors.overBackground
                    opacity: 0.6
                }
            }

            Button {
                implicitWidth: 32
                implicitHeight: 32

                background: StyledRect {
                    variant: parent.hovered ? "error" : "common"
                }

                contentItem: Text {
                    text: Icons.cancel
                    font.family: Icons.font
                    font.pixelSize: 16
                    color: parent.parent.hovered ? Colors.overError : Colors.overBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.close()
            }
        }

        // Scrollable content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                // Gradient Type Section
                GroupBox {
                    Layout.fillWidth: true
                    title: "Gradient Type"
                    
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

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Repeater {
                            model: ["linear", "radial", "halftone"]

                            delegate: Button {
                                id: typeButton
                                required property string modelData
                                required property int index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 32

                                readonly property bool isSelected: root.variantConfig.gradientType === modelData

                                background: StyledRect {
                                    variant: typeButton.isSelected ? "primary" : (typeButton.hovered ? "focus" : "common")
                                }

                                contentItem: Text {
                                    text: typeButton.modelData.charAt(0).toUpperCase() + typeButton.modelData.slice(1)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: typeButton.isSelected ? Colors.overPrimary : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: root.variantConfig.gradientType = modelData
                            }
                        }
                    }
                }

                // Item Color Section
                GroupBox {
                    Layout.fillWidth: true
                    title: "Item Color (Icons/Text)"

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

                    ColorSelector {
                        anchors.fill: parent
                        colorNames: root.colorNames
                        currentValue: root.variantConfig.itemColor
                        onColorChanged: newColor => root.variantConfig.itemColor = newColor
                    }
                }

                // Border Section
                GroupBox {
                    Layout.fillWidth: true
                    title: "Border"

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
                        spacing: 12

                        // Border width
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Width:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            SpinBox {
                                id: borderWidthSpinner
                                Layout.preferredWidth: 100
                                from: 0
                                to: 10
                                value: root.variantConfig.border[1]
                                editable: true

                                onValueModified: {
                                    let border = root.variantConfig.border.slice();
                                    border[1] = value;
                                    root.variantConfig.border = border;
                                }

                                background: StyledRect {
                                    variant: "common"
                                }

                                contentItem: TextInput {
                                    text: borderWidthSpinner.textFromValue(borderWidthSpinner.value, borderWidthSpinner.locale)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    readOnly: !borderWidthSpinner.editable
                                    validator: borderWidthSpinner.validator
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: borderWidthSpinner.mirrored ? 0 : parent.width - width
                                    height: parent.height
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    variant: borderWidthSpinner.up.pressed ? "primary" : (borderWidthSpinner.up.hovered ? "focus" : "common")

                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: borderWidthSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: borderWidthSpinner.mirrored ? parent.width - width : 0
                                    height: parent.height
                                    implicitWidth: 24
                                    implicitHeight: 24
                                    variant: borderWidthSpinner.down.pressed ? "primary" : (borderWidthSpinner.down.hovered ? "focus" : "common")

                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: borderWidthSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            Text {
                                text: "px"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Border color
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Color:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            ColorSelector {
                                Layout.fillWidth: true
                                colorNames: root.colorNames
                                currentValue: root.variantConfig.border[0]
                                onColorChanged: newColor => {
                                    let border = root.variantConfig.border.slice();
                                    border[0] = newColor;
                                    root.variantConfig.border = border;
                                }
                            }
                        }
                    }
                }

                // Opacity Section
                GroupBox {
                    Layout.fillWidth: true
                    title: "Opacity"

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

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Slider {
                            id: opacitySlider
                            Layout.fillWidth: true
                            from: 0.0
                            to: 1.0
                            value: root.variantConfig.opacity
                            stepSize: 0.05

                            onMoved: root.variantConfig.opacity = value

                            background: StyledRect {
                                x: opacitySlider.leftPadding
                                y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 6
                                width: opacitySlider.availableWidth
                                height: implicitHeight
                                variant: "common"

                                Rectangle {
                                    width: opacitySlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Colors.primary
                                    radius: parent.radius
                                }
                            }

                            handle: StyledRect {
                                x: opacitySlider.leftPadding + opacitySlider.visualPosition * (opacitySlider.availableWidth - width)
                                y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                variant: opacitySlider.pressed ? "primaryfocus" : "primary"
                            }
                        }

                        Text {
                            text: (root.variantConfig.opacity * 100).toFixed(0) + "%"
                            font.family: Styling.defaultFont
                            font.pixelSize: 12
                            color: Colors.overBackground
                            Layout.preferredWidth: 40
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Gradient Stops Section
                GradientStopsEditor {
                    Layout.fillWidth: true
                    colorNames: root.colorNames
                    stops: root.variantConfig.gradient
                    onUpdateStops: newStops => root.variantConfig.gradient = newStops
                }

                // Linear/Radial specific settings
                GroupBox {
                    Layout.fillWidth: true
                    title: root.variantConfig.gradientType === "radial" ? "Radial Settings" : "Linear Settings"
                    visible: root.variantConfig.gradientType !== "halftone"

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
                        spacing: 12

                        // Angle (for linear)
                        RowLayout {
                            visible: root.variantConfig.gradientType === "linear"
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Angle:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 80
                            }

                            SpinBox {
                                id: angleSpinner
                                Layout.preferredWidth: 120
                                from: 0
                                to: 360
                                value: root.variantConfig.gradientAngle
                                editable: true
                                wrap: true

                                onValueModified: root.variantConfig.gradientAngle = value

                                background: StyledRect { variant: "common" }

                                contentItem: TextInput {
                                    text: angleSpinner.textFromValue(angleSpinner.value, angleSpinner.locale)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    readOnly: !angleSpinner.editable
                                    validator: angleSpinner.validator
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: parent.width - width
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: angleSpinner.up.pressed ? "primary" : (angleSpinner.up.hovered ? "focus" : "common")
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: angleSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: 0
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: angleSpinner.down.pressed ? "primary" : (angleSpinner.down.hovered ? "focus" : "common")
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: angleSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            Text {
                                text: "degrees"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Center X/Y (for radial)
                        RowLayout {
                            visible: root.variantConfig.gradientType === "radial"
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Center X:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            Slider {
                                id: centerXSlider
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: root.variantConfig.gradientCenterX
                                stepSize: 0.05

                                onMoved: root.variantConfig.gradientCenterX = value

                                background: StyledRect {
                                    x: centerXSlider.leftPadding
                                    y: centerXSlider.topPadding + centerXSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 6
                                    width: centerXSlider.availableWidth
                                    variant: "common"

                                    Rectangle {
                                        width: centerXSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Colors.primary
                                        radius: parent.radius
                                    }
                                }

                                handle: StyledRect {
                                    x: centerXSlider.leftPadding + centerXSlider.visualPosition * (centerXSlider.availableWidth - width)
                                    y: centerXSlider.topPadding + centerXSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    variant: centerXSlider.pressed ? "primaryfocus" : "primary"
                                }
                            }

                            Text {
                                text: root.variantConfig.gradientCenterX.toFixed(2)
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 35
                            }
                        }

                        RowLayout {
                            visible: root.variantConfig.gradientType === "radial"
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Center Y:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 60
                            }

                            Slider {
                                id: centerYSlider
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: root.variantConfig.gradientCenterY
                                stepSize: 0.05

                                onMoved: root.variantConfig.gradientCenterY = value

                                background: StyledRect {
                                    x: centerYSlider.leftPadding
                                    y: centerYSlider.topPadding + centerYSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 6
                                    width: centerYSlider.availableWidth
                                    variant: "common"

                                    Rectangle {
                                        width: centerYSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Colors.primary
                                        radius: parent.radius
                                    }
                                }

                                handle: StyledRect {
                                    x: centerYSlider.leftPadding + centerYSlider.visualPosition * (centerYSlider.availableWidth - width)
                                    y: centerYSlider.topPadding + centerYSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    variant: centerYSlider.pressed ? "primaryfocus" : "primary"
                                }
                            }

                            Text {
                                text: root.variantConfig.gradientCenterY.toFixed(2)
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 35
                            }
                        }
                    }
                }

                // Halftone specific settings
                GroupBox {
                    Layout.fillWidth: true
                    title: "Halftone Settings"
                    visible: root.variantConfig.gradientType === "halftone"

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
                        spacing: 12

                        // Dot color
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Dot Color:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            ColorSelector {
                                Layout.fillWidth: true
                                colorNames: root.colorNames
                                currentValue: root.variantConfig.halftoneDotColor
                                onColorChanged: newColor => root.variantConfig.halftoneDotColor = newColor
                            }
                        }

                        // Background color
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "BG Color:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            ColorSelector {
                                Layout.fillWidth: true
                                colorNames: root.colorNames
                                currentValue: root.variantConfig.halftoneBackgroundColor
                                onColorChanged: newColor => root.variantConfig.halftoneBackgroundColor = newColor
                            }
                        }

                        // Dot size range
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Dot Min:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            SpinBox {
                                id: dotMinSpinner
                                Layout.preferredWidth: 100
                                from: 0
                                to: 200
                                value: root.variantConfig.halftoneDotMin * 10
                                editable: true

                                property real realValue: value / 10.0

                                onValueModified: root.variantConfig.halftoneDotMin = realValue

                                textFromValue: function(value, locale) {
                                    return (value / 10.0).toFixed(1);
                                }

                                valueFromText: function(text, locale) {
                                    return parseFloat(text) * 10;
                                }

                                background: StyledRect { variant: "common" }

                                contentItem: TextInput {
                                    text: dotMinSpinner.textFromValue(dotMinSpinner.value, dotMinSpinner.locale)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: parent.width - width
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: dotMinSpinner.up.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: dotMinSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: 0
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: dotMinSpinner.down.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: dotMinSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Dot Max:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            SpinBox {
                                id: dotMaxSpinner
                                Layout.preferredWidth: 100
                                from: 0
                                to: 200
                                value: root.variantConfig.halftoneDotMax * 10
                                editable: true

                                property real realValue: value / 10.0

                                onValueModified: root.variantConfig.halftoneDotMax = realValue

                                textFromValue: function(value, locale) {
                                    return (value / 10.0).toFixed(1);
                                }

                                valueFromText: function(text, locale) {
                                    return parseFloat(text) * 10;
                                }

                                background: StyledRect { variant: "common" }

                                contentItem: TextInput {
                                    text: dotMaxSpinner.textFromValue(dotMaxSpinner.value, dotMaxSpinner.locale)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: parent.width - width
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: dotMaxSpinner.up.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: dotMaxSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: 0
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: dotMaxSpinner.down.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: dotMaxSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Gradient range
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Start:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            Slider {
                                id: halftoneStartSlider
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: root.variantConfig.halftoneStart
                                stepSize: 0.05

                                onMoved: root.variantConfig.halftoneStart = value

                                background: StyledRect {
                                    x: halftoneStartSlider.leftPadding
                                    y: halftoneStartSlider.topPadding + halftoneStartSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 6
                                    width: halftoneStartSlider.availableWidth
                                    variant: "common"

                                    Rectangle {
                                        width: halftoneStartSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Colors.primary
                                        radius: parent.radius
                                    }
                                }

                                handle: StyledRect {
                                    x: halftoneStartSlider.leftPadding + halftoneStartSlider.visualPosition * (halftoneStartSlider.availableWidth - width)
                                    y: halftoneStartSlider.topPadding + halftoneStartSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    variant: halftoneStartSlider.pressed ? "primaryfocus" : "primary"
                                }
                            }

                            Text {
                                text: root.variantConfig.halftoneStart.toFixed(2)
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 35
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "End:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            Slider {
                                id: halftoneEndSlider
                                Layout.fillWidth: true
                                from: 0.0
                                to: 1.0
                                value: root.variantConfig.halftoneEnd
                                stepSize: 0.05

                                onMoved: root.variantConfig.halftoneEnd = value

                                background: StyledRect {
                                    x: halftoneEndSlider.leftPadding
                                    y: halftoneEndSlider.topPadding + halftoneEndSlider.availableHeight / 2 - height / 2
                                    implicitHeight: 6
                                    width: halftoneEndSlider.availableWidth
                                    variant: "common"

                                    Rectangle {
                                        width: halftoneEndSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Colors.primary
                                        radius: parent.radius
                                    }
                                }

                                handle: StyledRect {
                                    x: halftoneEndSlider.leftPadding + halftoneEndSlider.visualPosition * (halftoneEndSlider.availableWidth - width)
                                    y: halftoneEndSlider.topPadding + halftoneEndSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    variant: halftoneEndSlider.pressed ? "primaryfocus" : "primary"
                                }
                            }

                            Text {
                                text: root.variantConfig.halftoneEnd.toFixed(2)
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 35
                            }
                        }

                        // Angle
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Angle:"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                Layout.preferredWidth: 100
                            }

                            SpinBox {
                                id: halftoneAngleSpinner
                                Layout.preferredWidth: 120
                                from: 0
                                to: 360
                                value: root.variantConfig.gradientAngle
                                editable: true
                                wrap: true

                                onValueModified: root.variantConfig.gradientAngle = value

                                background: StyledRect { variant: "common" }

                                contentItem: TextInput {
                                    text: halftoneAngleSpinner.textFromValue(halftoneAngleSpinner.value, halftoneAngleSpinner.locale)
                                    font.family: Styling.defaultFont
                                    font.pixelSize: 12
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    selectByMouse: true
                                }

                                up.indicator: StyledRect {
                                    x: parent.width - width
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: halftoneAngleSpinner.up.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.plus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: halftoneAngleSpinner.up.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }

                                down.indicator: StyledRect {
                                    x: 0
                                    height: parent.height
                                    implicitWidth: 24
                                    variant: halftoneAngleSpinner.down.pressed ? "primary" : "common"
                                    Text {
                                        anchors.centerIn: parent
                                        text: Icons.minus
                                        font.family: Icons.font
                                        font.pixelSize: 12
                                        color: halftoneAngleSpinner.down.pressed ? Colors.overPrimary : Colors.overBackground
                                    }
                                }
                            }

                            Text {
                                text: "degrees"
                                font.family: Styling.defaultFont
                                font.pixelSize: 12
                                color: Colors.overBackground
                                opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }
                }

                // Spacer at the bottom
                Item { Layout.preferredHeight: 20 }
            }
        }
    }
}
