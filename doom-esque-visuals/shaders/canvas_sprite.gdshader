shader_type canvas_item;

uniform vec4 secondary_modulate: source_color = vec4(1.0,1.0,1.0,1.0);
// This is legit just here so palette swapping prior to using modulate is possible
group_uniforms Dither;
uniform bool use_global_dither = true;
uniform sampler2D dither_tex : repeat_enable,filter_nearest;
uniform float dither_scale = 1.0;
global uniform sampler2D global_dither_tex : repeat_enable,filter_nearest;
global uniform float global_dither_scale;

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

void fragment() {
	COLOR.rgb = palette_swap(COLOR.rgb);
	COLOR *= secondary_modulate;
	vec2 uv = UV / TEXTURE_PIXEL_SIZE;
	// Handle dithered transparency
	ivec2 dither_size = ivec2(mix(vec2(textureSize(dither_tex, 0)),vec2(textureSize(global_dither_tex, 0)),float(use_global_dither)));
	float target_dither_scale = mix(dither_scale,global_dither_scale,float(use_global_dither));
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / target_dither_scale);
	vec2 dither_uv = FRAGCOORD.xy * f_dither_size;
	float dither_threshold = mix(texture(dither_tex, dither_uv).r, texture(global_dither_tex, dither_uv).r, float(use_global_dither));
	if (COLOR.a < 0.001 || COLOR.a < dither_threshold) {
		discard;
	}
}