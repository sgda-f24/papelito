// fold_shader.shader
shader_type canvas_item;

// Uniforms
uniform float fold_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 end_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);     // Blue
uniform vec4 boundary_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Yellow
uniform float max_boundary_width : hint_range(0.0, 0.05) = 0.02;       // Maximum boundary width

void fragment() {
	vec4 start_color = vec4(1.0, 1.0, 1.0, 0.0);
    // Calculate the fold line position
    float fold_line = smoothstep(-0.1, 1.1, fold_amount);
    
    // Dynamically calculate boundary width based on fold_amount
    // Boundary width peaks at fold_amount = 0.5
    float boundary_width = max_boundary_width * exp(-100.*(fold_amount-0.5)*(fold_amount-0.5));
    
    // Calculate the distance from the current fragment to the fold line
    float dist = abs(UV.y - fold_line);
    
    // Determine if the fragment is within the boundary region
    // Using smoothstep for smooth transitions
    float boundary_factor = smoothstep(boundary_width, 0.0, dist);
	
    float bounce = 0.5;
	
    // Initialize base color based on fold position
    vec4 base_color;
    if (UV.y <= fold_line) {
        // Color for the "removed" area
        base_color = mix(vec4(end_color.xyz * bounce, end_color.w), end_color, smoothstep(0.3, 0.5, fold_amount));
    } else {
        // Color for the "remaining" area
        base_color = mix(start_color, vec4(start_color.xyz * bounce, start_color.w), smoothstep(0.5, 0.7, fold_amount));
    }
	
	
	// Calculate the brightness factor based on the x-coordinate
    // This makes the boundary brighter near x=0.5 and darker near x=0 and x=1
    float brightness_factor = bounce + (1.0-bounce)* exp(-64.0*(UV.x -0.5)*(UV.x-0.5));
	
	// Compute the final boundary color with brightness modulation
    vec4 final_boundary_color = vec4(boundary_color.xyz * brightness_factor, 1.0);
    
    // Blend the boundary color with the base color
    // If within boundary_width, boundary_factor approaches 1, showing boundary_color
    // Otherwise, it shows base_color
    COLOR = mix(base_color, final_boundary_color, boundary_factor)*COLOR;
}
