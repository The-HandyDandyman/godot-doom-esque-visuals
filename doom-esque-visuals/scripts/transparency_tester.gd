extends Sprite3D


@onready var animator:AnimationPlayer = $AnimationPlayer
@onready var ghostColor:Color = material_override.get_shader_parameter("modulate")
@onready var ghost_alpha:float = ghostColor.a
@export var dither_textures:Array[Texture2D]

var dither_index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("float")
	set_opacity(ghost_alpha)
	set_dither_texture(dither_index)
	


func set_dither_texture(index):
	if dither_textures.size() == 0: return
	dither_index = index if index < dither_textures.size() else 0
	material_override.set_shader_parameter("dither_tex",dither_textures[dither_index])

func set_opacity(alpha:float):
	var newColor:Color = ghostColor
	newColor.a = alpha
	material_override.set_shader_parameter("modulate",newColor)
func _process(delta):
	if Input.is_action_pressed("opacity_up"):
		ghost_alpha = ghost_alpha + 0.01 if ghost_alpha < 1 else 1 
		set_opacity(ghost_alpha)
	elif Input.is_action_pressed("opacity_down"):
		ghost_alpha = ghost_alpha - 0.01 if ghost_alpha > 0 else 0
		set_opacity(ghost_alpha)
	if Input.is_action_just_pressed("ui_filedialog_show_hidden"):
		dither_index += 1
		set_dither_texture(dither_index)
