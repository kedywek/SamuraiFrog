shader_type canvas_item;

uniform vec4 colorUpper : source_color;
uniform vec4 colorLower : source_color;
uniform float playerY;
uniform float worldYMin = 0; 
uniform float worldYMax = 5000; 

void vertex() {
    // The vertex function can be left empty for 2D shaders
}

void fragment() {
    float t = clamp((-playerY - worldYMin) / (worldYMax - worldYMin), 0.0, 1.0);
    
    COLOR = mix(colorLower, colorUpper, t);
}