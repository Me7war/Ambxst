import QtQuick
import Quickshell.Services.Mpris
import qs.modules.theme
import qs.modules.services
import qs.modules.notch
import qs.modules.components
import qs.config

Item {
    id: root

    implicitWidth: Math.round(hasActiveNotifications ? (notificationHoverHandler.hovered ? 420 + 48 : 320 + 48) : 200 + userInfo.width + separator1.width + separator2.width + notifIndicator.width + (mainRow.spacing * 4) + 32)
    implicitHeight: mainRow.height + (hasActiveNotifications ? (notificationHoverHandler.hovered ? notificationView.implicitHeight + 32 : notificationView.implicitHeight + 16) : 0)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    readonly property bool hasActiveNotifications: Notifications.popupList.length > 0
    readonly property MprisPlayer activePlayer: MprisController.activePlayer

    HoverHandler {
        id: notificationHoverHandler
        enabled: hasActiveNotifications
    }

    Column {
        anchors.fill: parent
        spacing: hasActiveNotifications ? 4 : 0

        Behavior on spacing {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Row {
            id: mainRow
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
            spacing: 8

            UserInfo {
                id: userInfo
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: separator1
                anchors.verticalCenter: parent.verticalCenter
                text: "•"
                color: Colors.outline
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
            }

            Item {
                id: compactPlayer
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - userInfo.width - separator1.width - separator2.width - notifIndicator.width - (parent.spacing * 4)
                height: 32

                property MprisPlayer player: activePlayer
                property bool isPlaying: player?.playbackState === MprisPlaybackState.Playing
                property real position: player?.position ?? 0.0
                property real length: player?.length ?? 1.0

                Timer {
                    running: compactPlayer.isPlaying
                    interval: 1000
                    repeat: true
                    onTriggered: compactPlayer.player?.positionChanged()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Math.max(0, Config.roundness - 4)
                    color: Colors.surfaceBright

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            id: previousBtn
                            anchors.verticalCenter: parent.verticalCenter
                            text: Icons.previous
                            color: Colors.overBackground
                            font.pixelSize: 16
                            font.family: Icons.font
                            opacity: compactPlayer.player?.canGoPrevious ?? false ? 1.0 : 0.3

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: compactPlayer.player?.canGoPrevious ?? false ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: compactPlayer.player?.canGoPrevious ?? false
                                onClicked: compactPlayer.player?.previous()
                            }
                        }

                        Text {
                            id: playPauseBtn
                            anchors.verticalCenter: parent.verticalCenter
                            text: compactPlayer.isPlaying ? Icons.pause : Icons.play
                            color: Colors.overBackground
                            font.pixelSize: 16
                            font.family: Icons.font
                            opacity: compactPlayer.player?.canPause ?? false ? 1.0 : 0.3

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: compactPlayer.player ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: compactPlayer.player !== null
                                onClicked: compactPlayer.player?.togglePlaying()
                            }
                        }

                        Text {
                            id: nextBtn
                            anchors.verticalCenter: parent.verticalCenter
                            text: Icons.next
                            color: Colors.overBackground
                            font.pixelSize: 16
                            font.family: Icons.font
                            opacity: compactPlayer.player?.canGoNext ?? false ? 1.0 : 0.3

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: compactPlayer.player?.canGoNext ?? false ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: compactPlayer.player?.canGoNext ?? false
                                onClicked: compactPlayer.player?.next()
                            }
                        }
                    }

                    Item {
                        id: positionControl
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 100
                        anchors.rightMargin: 8
                        height: 4

                        Rectangle {
                            anchors.right: parent.right
                            width: (1 - (compactPlayer.length > 0 ? compactPlayer.position / compactPlayer.length : 0)) * parent.width
                            height: parent.height
                            radius: height / 2
                            color: Colors.surfaceContainerHigh
                        }

                        Loader {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            active: compactPlayer.isPlaying
                            sourceComponent: WavyLine {
                                id: wavyFill
                                frequency: 6
                                color: Colors.primary
                                amplitudeMultiplier: 0.5
                                height: positionControl.height * 6
                                width: positionControl.width * (compactPlayer.length > 0 ? compactPlayer.position / compactPlayer.length : 0)
                                lineWidth: positionControl.height
                                fullLength: positionControl.width

                                FrameAnimation {
                                    running: compactPlayer.isPlaying
                                    onTriggered: wavyFill.requestPaint()
                                }
                            }
                        }

                        Loader {
                            active: !compactPlayer.isPlaying
                            sourceComponent: Rectangle {
                                anchors.left: parent.left
                                width: positionControl.width * (compactPlayer.length > 0 ? compactPlayer.position / compactPlayer.length : 0)
                                height: positionControl.height
                                radius: height / 2
                                color: Colors.primary
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: compactPlayer.player?.canSeek ?? false ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: compactPlayer.player?.canSeek ?? false
                            onClicked: (mouse) => {
                                if (compactPlayer.player && compactPlayer.player.canSeek) {
                                    compactPlayer.player.position = (mouse.x / width) * compactPlayer.length
                                }
                            }
                        }

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            enabled: compactPlayer.player?.canSeek ?? false
                            property bool isDragging: false

                            onPressed: isDragging = true
                            onReleased: isDragging = false
                            onPositionChanged: {
                                if (isDragging && compactPlayer.player && compactPlayer.player.canSeek) {
                                    compactPlayer.player.position = Math.min(Math.max(0, (mouseX / width) * compactPlayer.length), compactPlayer.length)
                                }
                            }
                        }
                    }
                }
            }

            Text {
                id: separator2
                anchors.verticalCenter: parent.verticalCenter
                text: "•"
                color: Colors.outline
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
            }

            NotificationIndicator {
                id: notifIndicator
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: hasActiveNotifications ? (notificationHoverHandler.hovered ? notificationView.implicitHeight + 32 : notificationView.implicitHeight + 16) : 0
            clip: false
            visible: height > 0

            Behavior on height {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutQuart
                }
            }

            NotchNotificationView {
                id: notificationView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: notificationHoverHandler.hovered ? 24 : 24
                anchors.rightMargin: notificationHoverHandler.hovered ? 24 : 24
                anchors.bottomMargin: 8
                opacity: hasActiveNotifications ? 1 : 0
                notchHovered: notificationHoverHandler.hovered

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }

                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuart
                    }
                }
            }
        }
    }
}
