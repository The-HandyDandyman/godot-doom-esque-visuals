extends Node
class_name PaletteUtil

static func scramble(original:Texture2D) -> ImageTexture:
	var og_pal:Image = original.get_image()
	var width:int = og_pal.get_width()
	var height:int = og_pal.get_height()
	var palette_array:Array[Color]
	for y in range(height):
		for x in range(width):
			var pal_color = og_pal.get_pixel(x,y)
			if pal_color.a > 0.0:
				palette_array.append(pal_color)
	palette_array.shuffle()
	var new_pal:Image = Image.create(width,height,false,Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var pal_color = palette_array[x * y]
			new_pal.set_pixel(x,y,pal_color)
	return ImageTexture.create_from_image(new_pal)

static func set_palette(material:ShaderMaterial,pal:Texture2D,shader_param:String = "palette") -> void:
	if !is_instance_valid(material): 
		return
	material.set_shader_parameter(shader_param,pal)

static func set_palette_size(material:ShaderMaterial,size:Vector2 = Vector2(16,16)) -> void:
	if !is_instance_valid(material): 
		return
	material.set_shader_parameter("palette_size",size)

static func set_palette_offset(material:ShaderMaterial,off:Vector2 = Vector2(16,16)) -> void:
	if !is_instance_valid(material): 
		return
	material.set_shader_parameter("palette_offset",off)

static func set_palette_scroll(material:ShaderMaterial,pal_scroll:bool = true, speed:Vector2 = Vector2.UP) -> void:
	if !is_instance_valid(material): 
		return
	material.set_shader_parameter("use_palette_scroll",pal_scroll)
	material.set_shader_parameter("palette_scroll_speed",speed)
