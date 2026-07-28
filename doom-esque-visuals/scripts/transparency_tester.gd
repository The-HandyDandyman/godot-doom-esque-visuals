extends Sprite3D


@onready var animator:AnimationPlayer = $AnimationPlayer
@onready var ghostColor:Color = material_override.get_shader_parameter("modulate")
@onready var ghost_alpha:float = ghostColor.a
# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("float")
	set_opacity(ghost_alpha)


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
