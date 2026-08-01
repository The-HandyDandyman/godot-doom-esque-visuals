extends MeshInstance3D


@onready var animator:AnimationPlayer = $AnimationPlayer
@onready var path:AnimationPlayer = $notAPath3DBecauseImLazy
@export var multi_step:bool = false
var directionAmount:float = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	material_override = material_override.duplicate() # Just doing this so that way the materials aren't duplicated in editor
	if multi_step:
		move_time()
	else:
		animator.play("animate")
		path.play("waddle")

func move_time():
	if animator.current_animation != "animate":
		animator.play("animate")
	path.play("move")
	await path.animation_finished
	animator.play("RESET")
	path.play("look_around")
	await path.animation_finished
	animator.play("animate")
	path.play("move_2")
	await path.animation_finished
	move_time()
