shader_type spatial;
render_mode unshaded,cull_disabled,fog_disabled;

uniform sampler2D sky_texture : filter_nearest,source_color;
uniform bool lock_aspect = false;
uniform float aspect_ratio = 1.3333333;
uniform vec2 fov = vec2(180.0, 90.0);
uniform ivec2 tiling = ivec2(1, 1);
uniform vec2 offset = vec2(0.0, 0.0);
uniform bool transparent = false; // This is mainly here for layered backgrounds, akin to Hexen

group_uniforms Pausable_Shader_Time;
uniform bool use_pausable_time = true;
global uniform float pausable_time = 0.0;

group_uniforms Autoscroll;
uniform bool use_autoscroll = false;
uniform vec2 autoscroll_offset = vec2(0.0,0.0);

group_uniforms Palette;
uniform bool use_palette_swap = false;
uniform sampler2D palette_in: filter_nearest, source_color;
uniform sampler2D palette_out: filter_nearest, hint_default_transparent, source_color;
uniform ivec2 palette_size;
uniform ivec2 palette_offset;
group_uniforms Palette_Scroll;
uniform bool use_palette_scroll = false;
uniform vec2 palette_scroll_speed;

varying vec4 BG_COORDS;

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
	//Camera YX rotation per Basis.get_euler source code
	float y = atan(VIEW_MATRIX[0][2], VIEW_MATRIX[2][2]);
	float x = asin(VIEW_MATRIX[1][2]);

	//Map rotation to screen space
	BG_COORDS.xy = vec2(y * -0.5, x) / PI;
	BG_COORDS.y += 0.5;

	BG_COORDS.w = fov.y / 180.0;
	BG_COORDS.z = !lock_aspect ? fov.x / 360.0 : VIEWPORT_SIZE.x / (VIEWPORT_SIZE.y * aspect_ratio) * BG_COORDS.w;

	//Keep background centered vertically when FOV changes
	BG_COORDS.y *= BG_COORDS.w > 1.0 ? 0.0 : 1.0 - BG_COORDS.w;
}

void fragment() {
	vec2 final_autoscroll = vec2(-autoscroll_offset.x, autoscroll_offset.y) * mix(TIME,pausable_time,float(use_pausable_time)) * vec2(float(use_autoscroll));
	vec2 uv = (SCREEN_UV + vec2(-offset.x, offset.y) + final_autoscroll) * BG_COORDS.zw + BG_COORDS.xy;
	uv *= vec2(tiling);
	vec4 tex = texture(sky_texture, uv);
	if (tex.a < 1.0 && transparent){ //This is mainly here for cases where you want layering!
		discard;
	}
	tex.rgb = palette_swap(tex.rgb);
	ALBEDO = tex.rgb;
}