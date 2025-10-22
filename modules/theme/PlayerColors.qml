pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.services
import qs.modules.globals
import qs.config

Item {
    id: playerColors

    property string assetsPath: Qt.resolvedUrl("../../assets/matugen/")
    property string lastProcessedArtUrl: ""
    property string lastProcessedScheme: ""
    property var artworkConnections: null

    FileView {
        id: colorsView
        path: Quickshell.dataPath("player_colors.json")
        preload: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            property color background: "#1a1111"
            property color overBackground: "#f1dedd"
            property color overPrimary: "#571d1c"
            property color primary: "#ffb3ae"
            property color shadow: "#000000"
            property color sourceColor: "#7f2424"
        }
    }

    function applyOpacity(hexColor) {
        var c = Qt.color(hexColor);
        return Qt.rgba(c.r, c.g, c.b, Config.opacity);
    }

    property color background: Config.oledMode ? Qt.rgba(0, 0, 0, Config.opacity) : applyOpacity(colorsView.adapter.background)
    property color overBackground: colorsView.adapter.overBackground
    property color overPrimary: colorsView.adapter.overPrimary
    property color primary: colorsView.adapter.primary
    property color shadow: colorsView.adapter.shadow
    property color sourceColor: colorsView.adapter.sourceColor

    function runMatugen(artworkUrl) {
        if (!artworkUrl || artworkUrl === "")
            return;
        const currentScheme = GlobalStates.wallpaperManager ? GlobalStates.wallpaperManager.currentMatugenScheme : "scheme-tonal-spot";
        if (artworkUrl === lastProcessedArtUrl && currentScheme === lastProcessedScheme)
            return;
        lastProcessedArtUrl = artworkUrl;
        lastProcessedScheme = currentScheme;
        const configPath = assetsPath.replace("file://", "") + "player.toml";
        const cachePath = Quickshell.dataPath("player_artwork.jpg");
        if (artworkUrl.startsWith("http://") || artworkUrl.startsWith("https://")) {
            downloadProcess.command = ["curl", "-sL", "-o", cachePath, artworkUrl];
            downloadProcess.running = true;
        } else if (artworkUrl.startsWith("data:image/")) {
            const base64Data = artworkUrl.split(",")[1];
            base64Process.command = ["bash", "-c", `echo "${base64Data}" | base64 -d > "${cachePath}"`];
            base64Process.running = true;
        } else {
            const artPath = artworkUrl.replace("file://", "");
            matugenProcess.command = ["matugen", "image", artPath, "-c", configPath, "-t", currentScheme];
            matugenProcess.running = true;
        }
    }

    Process {
        id: downloadProcess
        running: false
        onExited: function (code) {
            if (code === 0) {
                const cachePath = Quickshell.dataPath("player_artwork.jpg");
                const configPath = assetsPath.replace("file://", "") + "player.toml";
                matugenProcess.command = ["matugen", "image", cachePath, "-c", configPath, "-t", lastProcessedScheme];
                matugenProcess.running = true;
            } else {
                console.warn("PlayerColors: Failed to download artwork, curl exit code:", code);
            }
        }
    }

    Process {
        id: base64Process
        running: false
        onExited: function (code) {
            if (code === 0) {
                const cachePath = Quickshell.dataPath("player_artwork.jpg");
                const configPath = assetsPath.replace("file://", "") + "player.toml";
                matugenProcess.command = ["matugen", "image", cachePath, "-c", configPath, "-t", lastProcessedScheme];
                matugenProcess.running = true;
            } else {
                console.warn("PlayerColors: Failed to decode base64 artwork, exit code:", code);
            }
        }
    }

    Process {
        id: matugenProcess
        running: false
        onExited: function (code) {
            if (code !== 0) {
                console.warn("PlayerColors: matugen failed with code:", code);
            }
        }
    }

    Component {
        id: artworkConnectionsComponent
        Connections {
            function onTrackArtUrlChanged() {
                if (target && target.trackArtUrl) {
                    playerColors.runMatugen(target.trackArtUrl);
                }
            }
        }
    }

    Connections {
        target: MprisController
        function onActivePlayerChanged() {
            if (playerColors.artworkConnections) {
                playerColors.artworkConnections.destroy();
                playerColors.artworkConnections = null;
            }
            if (MprisController.activePlayer) {
                playerColors.artworkConnections = artworkConnectionsComponent.createObject(playerColors, {
                    target: MprisController.activePlayer
                });
                if (MprisController.activePlayer.trackArtUrl) {
                    playerColors.runMatugen(MprisController.activePlayer.trackArtUrl);
                }
            }
        }
    }

    Connections {
        target: GlobalStates.wallpaperManager
        function onCurrentMatugenSchemeChanged() {
            if (MprisController.activePlayer && MprisController.activePlayer.trackArtUrl) {
                lastProcessedArtUrl = "";
                runMatugen(MprisController.activePlayer.trackArtUrl);
            }
        }
    }

    Component.onCompleted: {
        if (MprisController.activePlayer) {
            artworkConnections = artworkConnectionsComponent.createObject(playerColors, {
                target: MprisController.activePlayer
            });
            if (MprisController.activePlayer.trackArtUrl) {
                runMatugen(MprisController.activePlayer.trackArtUrl);
            }
        }
    }
}
