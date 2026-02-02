import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.modules.components
import qs.modules.corners
import qs.modules.services
import qs.modules.theme
import qs.config

Item {
    id: root

    required property ShellScreen targetScreen
    property bool hasFullscreenWindow: false

    readonly property bool frameEnabled: Config.bar?.frameEnabled ?? false
    
    // Reference the bar/dock content to get states
    readonly property var barPanel: Visibilities.barPanels[targetScreen.name]
    readonly property var dockPanel: Visibilities.dockPanels[targetScreen.name]
    
    // Independent reveal states for each component
    readonly property bool barReveal: barPanel ? barPanel.reveal : true
    readonly property bool dockReveal: dockPanel ? dockPanel.reveal : true
    readonly property bool notchReveal: barPanel ? barPanel.notchReveal : true

    // Hover states for thickness restoration logic
    readonly property bool barHovered: barPanel ? (barPanel.barHoverActive || barPanel.notchHoverActive || barPanel.notchOpen) : false
    readonly property bool dockHovered: dockPanel ? (dockPanel.reveal && (dockPanel.activeWindowFullscreen || dockPanel.keepHidden || !dockPanel.pinned)) : false

    readonly property real baseThickness: {
        const base = Config.bar?.frameThickness ?? 6;
        return Math.max(1, Math.min(Math.round(base), 40));
    }

    readonly property bool containBar: Config.bar?.containBar ?? false
    readonly property string barPos: Config.bar?.position ?? "top"
    readonly property string notchPos: Config.notchPosition ?? "top"

    readonly property int barSize: {
        if (!barPanel) return 44; // Fallback
        const isHoriz = barPos === "top" || barPos === "bottom";
        return isHoriz ? barPanel.barTargetHeight : barPanel.barTargetWidth;
    }

    // Animation progress for each component to sync thickness with reveal
    property real _barAnimProgress: barReveal ? 1.0 : 0.0
    Behavior on _barAnimProgress {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 2
            easing.type: Easing.OutCubic
        }
    }

    property real _dockAnimProgress: dockReveal ? 1.0 : 0.0
    Behavior on _dockAnimProgress {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 2
            easing.type: Easing.OutCubic
        }
    }

    property real _notchAnimProgress: notchReveal ? 1.0 : 0.0
    Behavior on _notchAnimProgress {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 2
            easing.type: Easing.OutCubic
        }
    }

    // Bar expansion logic (synchronized with bar reveal animation)
    readonly property int barExpansion: Math.round((barSize + baseThickness) * _barAnimProgress)

    // Selective thickness restoration per side
    readonly property int topThickness: {
        let t = baseThickness;
        if (hasFullscreenWindow) {
            let restoreTop = false;
            if (barPos === "top" && barHovered) restoreTop = true;
            if (notchPos === "top" && barHovered) restoreTop = true; // Notch and bar usually sync hover
            if (dockPanel && dockPanel.position === "top" && dockHovered) restoreTop = true;
            
            // Apply animation progress to thickness restoration
            let progress = 0.0;
            if (barPos === "top" || notchPos === "top") progress = Math.max(_barAnimProgress, _notchAnimProgress);
            if (dockPanel && dockPanel.position === "top") progress = Math.max(progress, _dockAnimProgress);
            
            t = restoreTop ? (baseThickness * progress) : 0;
        }
        return Math.round(t) + ((containBar && barPos === "top") ? barExpansion : 0);
    }

    readonly property int bottomThickness: {
        let t = baseThickness;
        if (hasFullscreenWindow) {
            let restoreBottom = false;
            if (barPos === "bottom" && barHovered) restoreBottom = true;
            if (notchPos === "bottom" && barHovered) restoreBottom = true;
            if (dockPanel && dockPanel.position === "bottom" && dockHovered) restoreBottom = true;
            
            let progress = 0.0;
            if (barPos === "bottom" || notchPos === "bottom") progress = Math.max(_barAnimProgress, _notchAnimProgress);
            if (dockPanel && dockPanel.position === "bottom") progress = Math.max(progress, _dockAnimProgress);
            
            t = restoreBottom ? (baseThickness * progress) : 0;
        }
        return Math.round(t) + ((containBar && barPos === "bottom") ? barExpansion : 0);
    }

    readonly property int leftThickness: {
        let t = baseThickness;
        if (hasFullscreenWindow) {
            let restoreLeft = false;
            if (barPos === "left" && barHovered) restoreLeft = true;
            if (dockPanel && dockPanel.position === "left" && dockHovered) restoreLeft = true;
            
            let progress = 0.0;
            if (barPos === "left") progress = _barAnimProgress;
            if (dockPanel && dockPanel.position === "left") progress = Math.max(progress, _dockAnimProgress);
            
            t = restoreLeft ? (baseThickness * progress) : 0;
        }
        return Math.round(t) + ((containBar && barPos === "left") ? barExpansion : 0);
    }

    readonly property int rightThickness: {
        let t = baseThickness;
        if (hasFullscreenWindow) {
            let restoreRight = false;
            if (barPos === "right" && barHovered) restoreRight = true;
            if (dockPanel && dockPanel.position === "right" && dockHovered) restoreRight = true;
            
            let progress = 0.0;
            if (barPos === "right") progress = _barAnimProgress;
            if (dockPanel && dockPanel.position === "right") progress = Math.max(progress, _dockAnimProgress);
            
            t = restoreRight ? (baseThickness * progress) : 0;
        }
        return Math.round(t) + ((containBar && barPos === "right") ? barExpansion : 0);
    }

    readonly property int actualFrameSize: frameEnabled ? baseThickness : 0
    readonly property int borderWidth: Config.theme.srBg.border[1]
    
    // innerRadius restoration logic - synchronized with highest progress
    readonly property real targetInnerRadius: {
        if (!root.hasFullscreenWindow) return Styling.radius(4 + borderWidth);
        if (!barHovered && !dockHovered) return 0;
        
        let progress = Math.max(_barAnimProgress, _dockAnimProgress, _notchAnimProgress);
        return Styling.radius(4 + borderWidth) * progress;
    }
    
    property real innerRadius: targetInnerRadius

    // Visual part
    StyledRect {
        id: frameFill
        anchors.fill: parent
        variant: "bg"
        radius: 0
        enableBorder: false
        visible: root.frameEnabled
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: frameMask
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }

    Item {
        id: frameMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            id: maskRect
            x: root.leftThickness
            y: root.topThickness
            width: parent.width - (root.leftThickness + root.rightThickness)
            height: parent.height - (root.topThickness + root.bottomThickness)
            radius: root.innerRadius
            color: "white"
            visible: width > 0 && height > 0
        }
    }
}
