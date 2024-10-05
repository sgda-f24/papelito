shader_type canvas_item;

// Vertex Shader Parameters
uniform float wave_amplitude : hint_range(0.0, 20.0) = 10.0; // Controls the height of the waves
uniform float wave_frequency : hint_range(0.0, 5.0) = 1.0;    // Controls the frequency of the waves
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;        // Controls the speed of the wave animation
uniform float upper_limit : hint_range(-1000.0, 1000.0) = 0.0; // Y-coordinate below which vertices will be affected

// Fragment Shader Parameters
uniform float frag_wave_speed : hint_range(0.0, 10.0) = 3.0;      // Wave loop speed for fragment shader
uniform float frag_wave_frequency : hint_range(0.0, 20.0) = 10.0; // Wave vertical frequency for fragment shader
uniform float frag_wave_width : hint_range(0.0, 5.0) = 1.0;       // Wave width for fragment shader
uniform float transparency : hint_range(0.0, 1.0) = 0.5;          // Transparency level (0.0 to 1.0)

void vertex() {
    // Transform the local vertex position to world coordinates
    vec2 world_vertex_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;

    // Only affect vertices below the upper_limit
    if (VERTEX.y <= upper_limit) {
        // Calculate the wave displacement using world X position
        float wave = sin(TIME * wave_speed + world_vertex_position.x * wave_frequency) * wave_amplitude;

        // Apply the displacement to the vertex's Y position
        VERTEX.y += wave;
    }
}

void fragment() {
    // Calculate UV offset for the wave effect
    vec2 wave_uv_offset;
    wave_uv_offset.x = cos((TIME * frag_wave_speed) + UV.x + UV.y * frag_wave_frequency * 2.0) * frag_wave_width * 0.01;

    // Set the final color
    COLOR.a *= transparency;
}