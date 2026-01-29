import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Item {
    id: root

    required property ShellScreen screen

    // States from Bar and Dock
    property bool barEnabled: true
    property string barPosition: "top"
    property bool barPinned: true
    property bool barReveal: true
    property bool barFullscreen: false
    property int barSize: 0
    property int barOuterMargin: 0
    property bool containBar: Config.bar?.containBar ?? false

    readonly property int borderWidth: Config.theme.srBg.border[1]

    property bool dockEnabled: true
    property string dockPosition: "bottom"
    property bool dockPinned: true
    property bool dockReveal: true
    property bool dockFullscreen: false
    property int dockHeight: (Config.dock?.height ?? 56) + (Config.dock?.margin ?? 8) + (isDefaultDock ? 0 : (Config.dock?.margin ?? 8))
    property bool isDefaultDock: (Config.dock?.theme ?? "default") === "default"

    property bool frameEnabled: Config.bar?.frameEnabled ?? false
    property int frameThickness: {
        const value = Config.bar?.frameThickness;
        if (typeof value !== "number")
            return 6;
        return Math.max(1, Math.min(Math.round(value), 40));
    }
    readonly property int actualFrameSize: frameEnabled ? frameThickness : 0

    // Helper to check if a component is active for exclusive zone on a specific side
    function getExtraZone(side) {
        if (!Config.barReady) return 0;
        
        let zone = actualFrameSize > 0 ? actualFrameSize + borderWidth : 0;

        // Bar zone
        if (barEnabled && barPosition === side && barPinned && barReveal && !barFullscreen) {
            if (zone === 0) zone = borderWidth;
            zone += barSize + barOuterMargin;
            // Add extra thickness if containing bar
            if (containBar) {
                zone += actualFrameSize;
            }
        }

        // Dock zone
        if (dockEnabled && dockPosition === side && dockPinned && dockReveal && !dockFullscreen) {
            if (zone === 0) zone = borderWidth;
            zone += dockHeight;
        }

        return zone;
    }
    
    // Determine exclusion mode based on whether we are reserving ANY space
    // If zone > 0 we should probably be ExclusionMode.Normal to ensure it takes effect
    function getExclusionMode(side) {
        // If we are calculating a zone > 0, we generally want Normal.
        // But the original code had Ignore everywhere.
        // Assuming the user wants to FIX reservation, we likely need Normal.
        // However, let's respect if the zone is 0 or minimal.
        // But actualFrameSize is at least 6 if enabled.
        
        // Wait, if original was Ignore, maybe it was just overlay?
        // But user says "no reserva el espacio que debería". This implies it SHOULD reserve.
        // So Ignore is likely wrong for the case where we WANT reservation.
        
        return getExtraZone(side) > 0 ? ExclusionMode.Normal : ExclusionMode.Ignore;
    }

    Item {
        id: noInputRegion
        width: 0
        height: 0
        visible: false
    }

    PanelWindow {
        id: topWindow
        screen: root.screen
        visible: true
        implicitHeight: 1 // Minimal height
        color: "transparent"
        anchors {
            left: true
            right: true
            top: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:top"
        exclusionMode: root.getExclusionMode("top")
        exclusiveZone: root.getExtraZone("top")
        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: bottomWindow
        screen: root.screen
        visible: true
        implicitHeight: 1
        color: "transparent"
        anchors {
            left: true
            right: true
            bottom: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:bottom"
        exclusionMode: root.getExclusionMode("bottom")
        exclusiveZone: root.getExtraZone("bottom")
        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: leftWindow
        screen: root.screen
        visible: true
        implicitWidth: 1
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:left"
        exclusionMode: root.getExclusionMode("left")
        exclusiveZone: root.getExtraZone("left")
        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: rightWindow
        screen: root.screen
        visible: true
        implicitWidth: 1
        color: "transparent"
        anchors {
            top: true
            bottom: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:reservation:right"
        exclusionMode: root.getExclusionMode("right")
        exclusiveZone: root.getExtraZone("right")
        mask: Region {
            item: noInputRegion
        }
    }
}
