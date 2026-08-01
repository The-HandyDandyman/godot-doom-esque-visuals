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
uniform bool use_lightmap = true;

group_uniforms LightMask;
uniform sampler2D light_mask:hint_default_black,filter_nearest;
uniform float light_mask_strength:hint_range(0.0,1.0) = 1.0;

global uniform bool light_diminishing = false;
global uniform float min_diminish = 0.0;
global uniform float max_diminish = 4.0;
global uniform float diminish_curve = 1.0;
global uniform bool radial_diminish = false;
global uniform bool color_banding = false;
global uniform int color_bands = 32;
global uniform bool fog_diminishing = false;
global uniform vec4 fog_modulate : source_color = vec4(0.0,0.0,0.0,1.0);

varying flat vec3 world_origin;
varying flat vec3 light_color;

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

float diminish_factor_calc(float min_val,float max_val, float dim_curve, float vertex_dim){
	float dim = pow(1.0 - smoothstep(min_val,max_val,vertex_dim),max(0.0,dim_curve)); // Initial calculations
	return  mix(dim,(floor(dim * float(color_bands)) / float(color_bands)),float(color_banding)); // Apply color banding if needed
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
	light_color_masked = mix(light_color_masked,vec3(1.0),1.0 - float(use_lightmap));
	// Calculate light diminishing and fog
	float vertex_diminish = mix(-VERTEX.z,length(VERTEX),float(radial_diminish));
	float light_diminish_factor = diminish_factor_calc(min_diminish,max_diminish,diminish_curve,vertex_diminish);
	// Create final light diminishing
	vec3 final_light_diminish = vec3(mix(0.0,light_diminish_factor,float(light_diminishing)));
	light_color_masked = screen(light_color_masked,final_light_diminish);
	vec3 complete_albedo = final_albedo.rgb * modulate.rgb * light_color_masked;
	vec3 fog_albedo = mix(complete_albedo,fog_modulate.rgb,1.0 - light_diminish_factor);
	ALBEDO = mix(complete_albedo,fog_albedo,float(fog_diminishing));
	//ALBEDO = final_light_diminish;
}