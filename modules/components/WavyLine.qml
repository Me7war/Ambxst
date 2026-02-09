import QtQuick
import QtQuick.Shapes
import qs.config
import qs.modules.theme

Item {
    id: root

    // =========================================================================
    // API Properties
    // =========================================================================
    property color color: Styling.srItem("overprimary")
    property real lineWidth: 2
    property real frequency: 2
    property real amplitude: 4
    property real speed: 5
    property bool running: true

    // Compatibility properties
    property real amplitudeMultiplier: 1.0 // Legacy support
    property real fullLength: width
    property bool animationsEnabled: true

    // =========================================================================
    // Internal Logic
    // =========================================================================

    property real actualAmplitude: amplitude * amplitudeMultiplier
    
    // Wave Animation (Phase Shift)
    property real wavePhase: 0

    Timer {
        id: animationTimer
        interval: 32 // ~30 fps target
        running: root.running && root.visible && root.animationsEnabled && root.width > 0
        repeat: true
        onTriggered: {
            if (root.width <= 0) return;

            // Calculate phase shift per tick
            // Wave equation: y = A * sin(kx - wt)
            // k = 2PI / wavelength
            
            // Use fullLength if available to ensure constant wavelength regardless of current width
            let baseLen = (root.fullLength > 0) ? root.fullLength : root.width;
            let freq = (root.frequency > 0) ? root.frequency : 1;
            let wavelength = baseLen / freq;
            
            // Speed is pixels per second
            // dx per tick = speed * dt
            let dt = interval / 1000.0;
            
            // Apply a multiplier to make the default speed values (usually ~5-10) feel responsive
            // Reduced from 20.0 to 4.0 based on feedback
            let visualSpeedMultiplier = 4.0; 
            let dx = root.speed * visualSpeedMultiplier * dt;
            
            // Convert dx to dPhase
            // phase = (dx / wavelength) * 2PI
            let dPhase = (dx / wavelength) * Math.PI * 2;
            
            // Subtract phase to move wave right
            root.wavePhase = (root.wavePhase - dPhase) % (Math.PI * 2);
        }
    }

    // Dynamic Point Generation
    function generatePoints(phase) {
        let points = [];
        if (root.width <= 0) return points;

        let w = root.width;
        let h = root.height;
        let cy = h / 2;
        let amp = root.actualAmplitude;
        
        let baseLen = (root.fullLength > 0) ? root.fullLength : root.width;
        let freq = (root.frequency > 0) ? root.frequency : 1;
        
        // Step size: 2px is a good balance for smoothness vs performance
        let step = 2; 

        // Generate points covering 0 to width
        // Because we animate phase, the wave slides through these fixed x-coordinates
        for (let x = 0; x <= w + step; x += step) {
            let cx = Math.min(x, w);
            
            // Calculate angle based on fixed baseLength/fullLength to prevent squashing
            // angle = x * (2PI * frequency / fullLength)
            let angle = cx * (freq * 2 * Math.PI / baseLen);
            
            // Apply phase
            let yOffset = Math.sin(angle + phase) * amp;
            
            points.push(Qt.point(cx, cy + yOffset));
            
            if (cx >= w) break;
        }
        return points;
    }

    // Clipper Item to handle stroke caps extending beyond bounds
    // We expand the clip rect by lineWidth to show round caps, but clip any large overflows
    Item {
        id: clipper
        anchors.fill: parent
        anchors.margins: -root.lineWidth 
        clip: true 
        
        Shape {
            // Position shape correctly relative to clipper (which starts at -margin)
            x: root.lineWidth
            y: root.lineWidth
            width: root.width
            height: root.height
            
            // Use CurveRenderer for smooth anti-aliased lines
            preferredRendererType: Shape.CurveRenderer
            
            ShapePath {
                strokeColor: root.color
                strokeWidth: root.lineWidth
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                
                startX: polyline.path.length > 0 ? polyline.path[0].x : 0
                startY: polyline.path.length > 0 ? polyline.path[0].y : root.height / 2

                PathPolyline {
                    id: polyline
                    path: root.generatePoints(root.wavePhase)
                }
            }
        }
    }
}
