#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;       // Normalized radius (0.0-0.5)
    float startAngle;   // Radians
    float progressAngle;// Radians span
    float amplitude;    // Normalized
    float frequency;
    float phase;
    float thickness;    // Normalized
    float pixelSize;    // 1.0 / canvasSize (to help with AA)
    vec4 color;
} ubuf;

#define PI 3.14159265359

// Calculate the target radius for a given angle
// This defines our "ideal" wavy path in polar coordinates
float targetRadiusAt(float angle) {
    // We base the wave on the relative angle so it travels along the path
    // correctly regardless of startAngle
    float relAngle = angle - ubuf.startAngle;
    
    // Normalize logic not strictly needed here if we assume inputs are continuous,
    // but for the sine wave phase it helps if we want consistent frequency.
    
    return ubuf.radius + ubuf.amplitude * sin(ubuf.frequency * relAngle + ubuf.phase);
}

// Robust Distance Field search in Polar Coordinates
// This replicates the logic from wavyline.frag but adapted for r/theta
float distanceToWave(float r, float theta) {
    // 1. Define search window in Angular space
    // How many radians does the wave "wobble"? 
    // This is trickier than linear X. We estimate a safe angular window.
    // At radius R, arc length L = R * theta. 
    // We want to search +/- a few pixels worth of arc length.
    
    // A safe heuristic: The wave slope is bounded. We search a small angular neighborhood.
    // 0.1 radians is usually enough for high frequency waves at typical radii.
    float searchWindow = 0.15; 
    
    float minStart = theta - searchWindow;
    float minEnd = theta + searchWindow;
    
    const int numSteps = 24; // Lower steps than linear because polar is expensive? Or keep high?
                             // WavyLine used 40. Let's try 30.
    
    float minDistanceSq = 1.0e+20;
    
    for (int i = 0; i <= numSteps; ++i) {
        float t = float(i) / float(numSteps);
        float sampleTheta = mix(minStart, minEnd, t);
        
        // Calculate the ideal point on the wave at this sample angle
        float sampleR = targetRadiusAt(sampleTheta);
        
        // Convert sample point back to Cartesian relative to center (0,0)
        // We compare it against our current pixel's position (r, theta) -> (x,y)
        // Actually, we can just do distance in Cartesian space.
        
        // Current pixel position (already known as r, theta)
        // vec2 currentPos = vec2(r * cos(theta), r * sin(theta)); // This is just 'uv'
        
        // Sample position
        // vec2 samplePos = vec2(sampleR * cos(sampleTheta), sampleR * sin(sampleTheta));
        
        // Optimization: We can compute distance squared directly in polar? 
        // Law of cosines: d^2 = r1^2 + r2^2 - 2*r1*r2*cos(theta1 - theta2)
        // This avoids expensive sin/cos inside the loop? 
        // Actually sin/cos might be needed for the wave anyway. 
        // Let's stick to Cartesian distance for correctness.
        
        // But wait, constructing vec2 inside loop is fine.
        float dX = r * cos(theta) - sampleR * cos(sampleTheta);
        float dY = r * sin(theta) - sampleR * sin(sampleTheta);
        float distSq = dX*dX + dY*dY;
        
        minDistanceSq = min(minDistanceSq, distSq);
    }
    
    return sqrt(minDistanceSq);
}

void main() {
    // UV centered at 0,0
    vec2 uv = qt_TexCoord0 - 0.5;
    
    float r = length(uv);
    float theta = atan(uv.y, uv.x); // [-PI, PI]
    
    // Normalize theta to [0, 2PI)
    if (theta < 0.0) theta += 2.0 * PI;
    
    // --- Masking Logic ---
    float relAngle = theta - ubuf.startAngle;
    relAngle = mod(relAngle, 2.0 * PI);
    if (relAngle < 0.0) relAngle += 2.0 * PI;
    
    // Strict cut
    if (relAngle > ubuf.progressAngle) {
        discard;
    }
    
    // --- Distance Calculation ---
    // If we are too far from the base ring, discard early to save trig
    // Max wave deviation = amplitude. Max thickness = thickness/2.
    // Margin = amplitude + thickness.
    float margin = ubuf.amplitude + ubuf.thickness;
    if (abs(r - ubuf.radius) > margin) {
        discard;
    }
    
    // Perform robust distance search
    float d = distanceToWave(r, theta);
    
    // --- Rendering ---
    float halfThick = ubuf.thickness * 0.5;
    
    // AA width: use fwidth or passed pixel size
    float aa = fwidth(d);
    if (aa == 0.0) aa = 0.001; // Fallback
    
    float alpha = 1.0 - smoothstep(halfThick - aa, halfThick + aa, d);
    
    fragColor = ubuf.color * alpha * ubuf.qt_Opacity;
}
