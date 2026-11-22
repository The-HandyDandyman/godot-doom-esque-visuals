shader_type spatial;
render_mode unshaded;
uniform vec4 modulate: source_color = vec4(1.0,1.0,1.0,1.0);
uniform bool y_billboard = false; // Enables Y-Billboarding when true
uniform sampler2D sprite_texture: source_color, filter_nearest;

group_uniforms Dither;
uniform bool use_global_dither = true;
uniform sampler2D dither_tex : repeat_enable,filter_nearest;
uniform float dither_scale = 1.0;
global uniform sampler2D global_dither_tex : repeat_enable,filter_nearest;
global uniform float global_dither_scale;

group_uniforms Lightmap;
uniform sampler2D lightmap:hint_default_white,filter_nearest;
uniform vec2 lightmap_size = vec2(1.0);
uniform vec2 lightmap_origin = vec2(0.0);
uniform int use_lightmap:hint_enum("Disabled","Enabled","Global") = 2;
global uniform sampler2D global_lightmap:hint_default_white,filter_nearest,repeat_disable;
global uniform vec2 global_lightmap_size;
global uniform vec2 global_lightmap_origin;

group_uniforms LightMask;
uniform sampler2D light_mask:hint_default_black,filter_nearest;
uniform float light_mask_strength:hint_range(0.0,1.0) = 1.0;

group_uniforms Light_Diminishing;
global uniform bool light_diminishing = false;
global uniform float light_min_diminish = 0.0;
global uniform float light_max_diminish = 4.0;
global uniform float light_diminish_curve = 1.0;
global uniform bool radial_diminish = false;
global uniform bool color_banding = false;
global uniform sampler2D global_diminish_map:hint_default_white,filter_nearest,repeat_disable;
uniform sampler2D diminish_map:hint_default_white,filter_nearest,repeat_disable;
global uniform int color_bands = 32;
global uniform bool fog_diminishing = false;
global uniform vec4 fog_modulate : source_color = vec4(0.0,0.0,0.0,1.0);
global uniform float fog_min_diminish = 0.0;
global uniform float fog_max_diminish = 4.0;
global uniform float fog_diminish_curve = 1.0;

group_uniforms Pausable_Shader_Time;
uniform bool use_pausable_time = true;
global uniform float pausable_time = 0.0;

group_uniforms Palette;
uniform bool use_palette_swap = false;
uniform sampler2D palette_in: filter_nearest, source_color;
uniform sampler2D palette_out: filter_nearest, hint_default_transparent, source_color;
uniform ivec2 palette_size;
uniform ivec2 palette_offset;
group_uniforms Palette_Scroll;
uniform bool use_palette_scroll = false;
uniform vec2 palette_scroll_speed;

varying flat vec3 world_origin;
varying vec2 adjusted_light_origin;
varying flat vec3 light_color;
varying flat vec3 dim_color;
varying vec2 selected_lightmap_size;
varying vec2 selected_lightmap_origin;

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

float diminish_factor_calc(float min_val,float max_val, float dim_curve, float vertex_dim){
	float dim = pow(1.0 - smoothstep(min_val,max_val,vertex_dim),max(0.001,dim_curve)); // Initial calculations
	return  mix(dim,(floor(dim * float(color_bands)) / float(color_bands)),float(color_banding)); // Apply color banding if needed
}

vec3 palette_swap(vec3 original_color){
	float actual_time = mix(TIME,pausable_time,float(use_pausable_time));
	vec3 final_color = original_color;
	vec2 uv_offset = 1.0/vec2(palette_size);
	int x = 0;
	for (int x = 0; x < palette_size.x; x++){
		for (int y = 0; y < palette_size.y; y++) {
			vec2 palette_uv = vec2(float(x) + 0.5, float(y) + 0.5) * uv_offset;
			// Set palette offset properly and ensure it's modulated to the palette size
			vec2 pal_offset = vec2(mod(float(x + palette_offset.x), float(palette_size.x)),mod(float(y + palette_offset.y), float(palette_size.y)));
			vec2 pal_scroll_offset = pal_offset + vec2((palette_scroll_speed * actual_time));
			pal_offset = mix(pal_offset,pal_scroll_offset,float(use_palette_scroll));
			// Set new palette UV using the pal_offset and the uv_offset
			vec2 new_palette_uv = vec2(pal_offset.x + 0.5, pal_offset.y + 0.5) * uv_offset;
			
			vec4 old_color = texture(palette_in, palette_uv);
			vec4 new_color = texture(palette_out, new_palette_uv);
			// If you're offsetting palette: make sure no two colors on your palette index are the same! Original code used 0.0 but 0.01 has seemed to work better in this case
			float same_color = step(distance(final_color, old_color.rgb), 0.01);
			
			final_color = mix(final_color, new_color.rgb, same_color * float(new_color.a > 0.001));
		}
	}
	return mix(original_color,final_color,float(use_palette_swap));
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
	// Determine if lightmap is global or not and use that to help with UV mapping
	selected_lightmap_origin = mix(lightmap_origin,global_lightmap_origin,float(use_lightmap > 1));
	selected_lightmap_size = mix(lightmap_size,global_lightmap_size,float(use_lightmap > 1));
	// Handle lightmap colors: we're handling it in here so that way the light is just one color
	vec2 local_world_pos = world_origin.xz - selected_lightmap_origin;
	adjusted_light_origin = (local_world_pos / selected_lightmap_size) + vec2(0.5);
	light_color = mix(texture(lightmap,adjusted_light_origin).rgb,texture(global_lightmap,adjusted_light_origin).rgb,float(use_lightmap > 1));
	dim_color = mix(texture(diminish_map,adjusted_light_origin).rgb,texture(global_diminish_map,adjusted_light_origin).rgb,float(use_lightmap > 1));
}

void fragment() {
	vec4 final_albedo = texture(sprite_texture,UV);
	final_albedo.rgb = palette_swap(final_albedo.rgb);
	final_albedo *= modulate;
	// Handle dithered transparency
	ivec2 dither_size = ivec2(mix(vec2(textureSize(dither_tex, 0)),vec2(textureSize(global_dither_tex, 0)),float(use_global_dither)));
	float target_dither_scale = mix(dither_scale,global_dither_scale,float(use_global_dither));
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / target_dither_scale);
	vec2 dither_uv = FRAGCOORD.xy * f_dither_size;
	float dither_threshold = mix(texture(dither_tex, dither_uv).r, texture(global_dither_tex, dither_uv).r, float(use_global_dither));
	if (final_albedo.a < 0.001 || final_albedo.a < dither_threshold) {
		discard;
	}
	// Apply light mask to light color
	vec3 light_mask_tex = texture(light_mask,UV).rgb;
	vec3 light_color_masked = light_mask_tex * vec3(light_mask_strength);
	light_color_masked = mix(light_color_masked,vec3(1.0),1.0 - float(use_lightmap > 0));
	// Calculate light diminishing and fog
	float vertex_diminish = mix(-VERTEX.z,length(VERTEX),float(radial_diminish));
	float light_diminish_factor = diminish_factor_calc(light_min_diminish,light_max_diminish,light_diminish_curve,vertex_diminish);
	float fog_diminish_factor = diminish_factor_calc(fog_min_diminish,fog_max_diminish,fog_diminish_curve,vertex_diminish);
	// Create final light diminishing
	vec3 final_light_diminish = mix(light_color,dim_color,float(light_diminishing) * light_diminish_factor);
	light_color_masked = screen(light_color_masked,final_light_diminish);
	vec3 complete_albedo = final_albedo.rgb * modulate.rgb * light_color_masked;
	vec3 fog_albedo = mix(complete_albedo,fog_modulate.rgb,1.0 - fog_diminish_factor);
	ALBEDO = mix(complete_albedo,fog_albedo,float(fog_diminishing));
	//ALBEDO = final_light_diminish;
}