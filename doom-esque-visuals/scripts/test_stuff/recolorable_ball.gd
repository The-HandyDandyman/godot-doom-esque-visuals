extends Sprite3D
class_name RecolorableBall
@export var palette_options:Array[Texture2D]
@export var use_palette_scroll:bool = false
@export var palette_scroll_speed:Vector2
var current_palette:int

# Called when the node enters the scene tree for the first time.
func _ready():
	if palette_options.size() <= 0:
		var pal_path:String = "res://graphics/palette/prefcolor"
		var list: Array = Array(
			ResourceLoader.list_directory(pal_path)
		).filter(
			func (fp: String) -> bool: return fp.ends_with(".png")
		)
		for tex in list:
			var new_tex := load(pal_path + "/" + tex)
			if new_tex is Texture2D:
				palette_options.append(new_tex)
	current_palette = randi_range(0,palette_options.size() - 1)
	PaletteUtil.set_palette(material_override,palette_options[current_palette],"palette_out")
	PaletteUtil.set_palette_scroll(material_override,use_palette_scroll,palette_scroll_speed)


func interact():
	current_palette = current_palette + 1 if current_palette + 1 < palette_options.size() else 0
	PaletteUtil.set_palette(material_override,palette_options[current_palette],"palette_out")
func _on_area_3d_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		interact()
