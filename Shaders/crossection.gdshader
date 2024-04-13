shader_type spatial;
render_mode unshaded, cull_front, depth_test_disabled;

uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE: hint_normal_roughness_texture, filter_linear;

uniform float red_intensity:hint_range(0.0, 10.0, 0.01);
//uniform float depth_range:hint_range(0.1, 100.0, 0.1);

varying vec4 world_pos;

void vertex() {
	world_pos = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb;
	float rougness = texture(NORMAL_TEXTURE, SCREEN_UV).w;
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z / 100.0;
	
	//vec4 world_pos = INV_PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX * FRAGCOORD;
	if (world_pos.y > 0.0) {
		ALBEDO = (screen_color + vec3(1.0, 0.0, 0.0) * red_intensity) / (1.0 + red_intensity);
	} else {
		discard;
	}
	//ALBEDO = vec3(linear_depth);
	//ALBEDO = normal;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
