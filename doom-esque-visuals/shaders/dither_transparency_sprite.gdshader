shader_type canvas_item;


group_uniforms Dither;

uniform sampler2D dither_tex : repeat_enable,filter_nearest;
uniform float dither_scale = 1.0;
uniform float transparency:hint_range(0.0,1.0) = 1.0;



void fragment() {
	vec2 uv = UV / TEXTURE_PIXEL_SIZE;
	// Handle dithered transparency
	ivec2 dither_size = textureSize(dither_tex, 0);
	vec2 f_dither_size = vec2(1.0 / float(dither_size.x), 1.0 / float(dither_size.y)) * vec2(1.0 / dither_scale);
	vec2 dither_uv = uv * f_dither_size;
	float dither_threshold = texture(dither_tex, dither_uv).r;
	if (COLOR.a < 0.001 || COLOR.a < dither_threshold || transparency < 0.001 || transparency < dither_threshold) {
		discard;
	}
}