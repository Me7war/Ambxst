import QtQuick
import QtQuick.Controls
import QtMultimedia
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    
    WlrLayershell.layer: WlrLayer.Overlay
    visible: GlobalStates.mirrorWindowVisible

    // Start position
    property int xPos: 200
    property int yPos: 200
    property bool isSquare: true
    
    // Dynamic Size
    property int currentWidth: isSquare ? 300 : 480
    property int currentHeight: 300

    // Mask solo la webcam para que lo demás sea click-through
    mask: Region {
        item: container
    }

    ClippingRectangle {
        id: container
        x: xPos
        y: yPos
        width: currentWidth
        height: currentHeight
        // Fondo negro mientras carga, transparente si está activa
        color: camera.cameraStatus === Camera.ActiveStatus ? "transparent" : "black"
        radius: Styling.radius(12)
        
        // Borde
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Styling.primary
            border.width: 1
            radius: parent.radius
            z: 2 // Encima del video
        }

        CaptureSession {
            id: captureSession
            camera: Camera {
                id: camera
                active: root.visible
            }
            videoOutput: videoOutput
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            // Siempre Crop para evitar barras negras
            fillMode: VideoOutput.PreserveAspectCrop 
        }
        
        // Drag Handler (Mover ventana)
        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            
            property point globalStartPoint: Qt.point(0,0)
            property int startXPos: 0
            property int startYPos: 0
            
            onPressed: (mouse) => {
                globalStartPoint = mapToItem(null, mouse.x, mouse.y)
                startXPos = root.xPos
                startYPos = root.yPos
            }
            
            onPositionChanged: (mouse) => {
                if (pressed) {
                    var p = mapToItem(null, mouse.x, mouse.y)
                    var dx = p.x - globalStartPoint.x
                    var dy = p.y - globalStartPoint.y
                    root.xPos = startXPos + dx
                    root.yPos = startYPos + dy
                }
            }

            // Controls Overlay
            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                spacing: 16
                z: 3 // Encima de todo
                
                // Show only on hover or when buttons are pressed
                opacity: (dragArea.containsMouse || controlHover.containsMouse) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                HoverHandler {
                    id: controlHover
                }

                // Toggle Ratio Button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Styling.surface
                    border.color: Styling.surfaceVariant
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: root.isSquare ? Icons.arrowsOutCardinal : Icons.aperture
                        font.family: Icons.font
                        color: Styling.text
                        font.pixelSize: 20
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isSquare = !root.isSquare
                            // Reset size logic
                            if (root.isSquare) {
                                root.currentHeight = 300
                                root.currentWidth = 300
                            } else {
                                root.currentHeight = 300
                                root.currentWidth = 480 // Reset to default wide
                            }
                        }
                    }
                }

                // Close Button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Colors.red
                    
                    Text {
                        anchors.centerIn: parent
                        text: Icons.cancel
                        font.family: Icons.font
                        color: "white" // Always white on red
                        font.pixelSize: 20
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: GlobalStates.mirrorWindowVisible = false
                    }
                }
            }
        }

        // Resize Handle (Esquina inferior derecha)
        Rectangle {
            width: 20
            height: 20
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: "transparent"
            z: 4
            
            // Icono visual de resize
            Text {
                anchors.centerIn: parent
                text: Icons.caretDoubleDown // Usamos caretDoubleDown o similar como indicador
                rotation: -45
                font.family: Icons.font
                color: Styling.primary
                font.pixelSize: 12
                opacity: (dragArea.containsMouse || resizeArea.containsMouse) ? 0.8 : 0
            }

            MouseArea {
                id: resizeArea
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                hoverEnabled: true
                preventStealing: true
                
                property point startPoint: Qt.point(0,0)
                property int startW: 0
                property int startH: 0

                onPressed: (mouse) => {
                    // Usar coordenadas de escena (null) ya que root no es un Item
                    startPoint = mapToItem(null, mouse.x, mouse.y)
                    startW = root.currentWidth
                    startH = root.currentHeight
                    mouse.accepted = true
                }

                onPositionChanged: (mouse) => {
                    if (pressed) {
                        var p = mapToItem(null, mouse.x, mouse.y)
                        var dx = p.x - startPoint.x
                        
                        // Mínimo 150px
                        var newW = Math.max(150, startW + dx)
                        
                        if (root.isSquare) {
                            root.currentWidth = newW
                            root.currentHeight = newW
                        } else {
                            // Proteger contra división por cero
                            if (startH > 0) {
                                var ratio = startW / startH
                                root.currentWidth = newW
                                root.currentHeight = newW / ratio
                            }
                        }
                    }
                }
            }
        }
    }
}
