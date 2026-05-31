shader_type canvas_item; // This secondary palette shader's used to create a sort of "palette corruption" effect at the moment, 
//though I hope to figure out how to make this effect work by rows and how to map the colors more properly for palette swapping the whole screen.

uniform sampler2D palette: filter_nearest, repeat_enable;
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;
uniform float palette_offset_x: hint_range(0.0,1.0);
uniform float palette_offset_y: hint_range(0.0,1.0);

void fragment() {
	vec4 rgba = texture(screen_texture, UV);
	vec4 final_color = texture(palette, vec2(rgba.r + palette_offset_x, rgba.g + palette_offset_y));
	final_color.a = rgba.a;
	
	COLOR = final_color;
}