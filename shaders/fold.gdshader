// fold_shader.shader
shader_type canvas_item;

// Uniforms
uniform float fold_amount : hint_range(-0.1, 1.1) = 0.0;
uniform vec4 start_color: source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red
uniform vec4 end_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);     // Blue

void fragment() {
    // Determine if the current fragment is above the fold line
    if (UV.y <= smoothstep(0.2,0.8,fold_amount)) {
        // Fill with end_color in the removed area
        COLOR = end_color;
    } else {
        // Fill with source_color in the remaining area
        COLOR = start_color;
    }
}

