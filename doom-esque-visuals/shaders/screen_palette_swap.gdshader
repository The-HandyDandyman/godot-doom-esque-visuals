shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// original palette
uniform sampler2D palette_in: filter_nearest, source_color;
// palette that will be displayed on the screen
uniform sampler2D palette_out: filter_nearest, source_color;
// number of colors in palettes, horizontally and vertically.
uniform ivec2 palette_size;
// the palette's offset in pixels
uniform ivec2 palette_offset;

void fragment() {
	vec4 screen_color = COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	// We ought to make sure the uv offset is pixel by pixel
	vec2 uv_offset = 1.0/vec2(palette_size);
	
	for (int x = 0; x < palette_size.x; x++)
		for (int y = 0; y < palette_size.y; y++) {
			vec2 palette_uv = vec2(float(x) + 0.5, float(y) + 0.5) * uv_offset;
			// Set palette offset properly and ensure it's modulated to the palette size
			vec2 pal_offset = vec2(mod(float(x + palette_offset.x), float(palette_size.x)),mod(float(y + palette_offset.y), float(palette_size.y)));
			
			// Set new palette UV using the pal_offset and the uv_offset
			vec2 new_palette_uv = vec2(pal_offset.x + 0.5, pal_offset.y + 0.5) * uv_offset;
			
			vec4 old_color = texture(palette_in, palette_uv);
			vec4 new_color = texture(palette_out, new_palette_uv);
			// If you're offsetting palette: make sure no two colors on your palette index are the same! Original code used 0.0 but 0.01 has seemed to work better in this case
			float same_color = step(distance(screen_color, old_color), 0.01);
			
			COLOR = mix(COLOR, new_color, same_color);
		}
	}