shader_type spatial;
render_mode unshaded, depth_prepass_alpha, depth_draw_opaque;
uniform vec4 modulate: source_color = vec4(1.0,1.0,1.0,1.0);
uniform bool y_billboard = false; // Enables Y-Billboarding when true
uniform sampler2D sprite_texture: source_color, filter_nearest;

group_uniforms Dither;
uniform sampler2D dither_tex : repeat_enable,filter_nearest;
uniform float dither_scale = 1.0;

group_uniforms Lightmap;
uniform sampler2D lightmap:hint_default_white,filter_nearest;
uniform vec2 lightmap_size = vec2(1.0);
uniform vec2 lightmap_offset = vec2(0.0);
group_uniforms LightMask;
uniform sampler2D light_mask:hint_default_black,filter_nearest;
uniform float light_mask_strength:hint_range(0.0,1.0) = 1.0;

varying flat vec3 world_origin;
varying flat vec3 light_color;

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

vec3 create_lightmap_color(vec2 offset){
	// Run the same calculations done for the ground
	vec2 actual_lightmap_size = vec2(1.0) / lightmap_size;
	vec2 lightmap_uv = fract((world_origin.xz * actual_lightmap_size) + lightmap_offset + offset);
	return texture(lightmap,lightmap_uv).rgb;
}

void vertex() {
	world_origin = MODEL_MATRIX[3].xyz;
	if (y_billboard == true) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	}
	else {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	// Apply object scale last after other calculations have been run
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
	vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
	vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
	vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
	vec4(0.0, 0.0, 0.0, 1.0));
	// Handle lightmap colors: we're handling it in here so that way the light is just one color
	light_color = create_lightmap_color(vec2(0));
}

void fragment() {
	vec4 final_albedo = texture(sprite_texture,UV);
	final_albedo *= modulate;
	// Handle dithered transparency
	ivec2 dither_size = textureSize(dither_tex, 0);
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / dither_scale);
	vec2 dither_uv = FRAGCOORD.xy * f_dither_size;
	float dither_threshold = texture(dither_tex, dither_uv).r;
	if (final_albedo.a < 0.001 || final_albedo.a < dither_threshold) {
		discard;
	}
	// Apply light mask to light color
	vec3 light_mask_tex = texture(light_mask,UV).rgb;
	vec3 light_color_masked = screen(light_color,light_mask_tex * vec3(light_mask_strength));
	ALBEDO = final_albedo.rgb * light_color_masked;
}