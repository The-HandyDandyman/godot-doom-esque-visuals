shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

uniform sampler2D palette: filter_nearest;

uniform sampler2D origPalette: filter_nearest;

uniform ivec2 paletteSize;
uniform ivec2 paletteOffset;

void fragment() {
	vec4 screenColor = COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 uvOffset = 1.0/vec2(paletteSize); //Ensures palette size is accurately translated into UVs
	
	for (int x = 0; x < paletteSize.x; x++)
		for (int y = 0; y < paletteSize.y; y++) {
			vec2 paletteUV = vec2(float(x) + 0.5, float(y) + 0.5) * uvOffset;
			// Set palette offset properly and ensure it's modulated to the palette size
			vec2 palOffset = vec2(mod(float(x + paletteOffset.x), float(paletteSize.x)),mod(float(y + paletteOffset.y), float(paletteSize.y)));
			
			// Set new palette UV using the palOffset and the uvOffset
			vec2 newPaletteUV = vec2(palOffset.x + 0.5, palOffset.y + 0.5) * uvOffset;
			
			vec4 oldColor = texture(origPalette, paletteUV);
			vec4 newColor = texture(palette, newPaletteUV);
			// If you're offsetting palette: make sure no two colors on your palette index are the same!
			float areSameColor = step(distance(screenColor, oldColor), 0.01);
			
			COLOR = mix(COLOR, newColor, areSameColor);
		}
	}