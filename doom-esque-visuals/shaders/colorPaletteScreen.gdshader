shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// palette that will be displayed on the screen
uniform sampler2D palette_out: filter_nearest,source_color;
// original palette
uniform sampler2D palette_in: filter_nearest,source_color;
// number of colors in palettes, horizontally and vertically.
uniform ivec2 paletteSize;
// the palette's offset in pixels
uniform ivec2 paletteOffset;

void fragment() {
	vec4 screenColor = COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	// We ought to make sure the uv offset is pixel by pixel
	vec2 uvOffset = 1.0/vec2(paletteSize);
	
	for (int x = 0; x < paletteSize.x; x++)
		for (int y = 0; y < paletteSize.y; y++) {
			vec2 paletteUV = vec2(float(x) + 0.5, float(y) + 0.5) * uvOffset;
			// Set palette offset properly and ensure it's modulated to the palette size
			vec2 palOffset = vec2(mod(float(x + paletteOffset.x), float(paletteSize.x)),mod(float(y + paletteOffset.y), float(paletteSize.y)));
			
			// Set new palette UV using the palOffset and the uvOffset
			vec2 newPaletteUV = vec2(palOffset.x + 0.5, palOffset.y + 0.5) * uvOffset;
			
			vec4 oldColor = texture(palette_in, paletteUV);
			vec4 newColor = texture(palette_out, newPaletteUV);
			// If you're offsetting palette: make sure no two colors on your palette index are the same! Original code used 0.0 but 0.01 has seemed to work better in this case
			float areSameColor = step(distance(screenColor, oldColor), 0.01);
			
			COLOR = mix(COLOR, newColor, areSameColor);
		}
	}