extends MeshInstance3D

@onready var animator:AnimationPlayer = $AnimationPlayer
var directionAmount:float = 0.1
var rotateToggle:bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("animate")

func _process(delta):
	if Input.is_action_pressed("rotate_right"):
		directionAmount += 0.01
	elif Input.is_action_pressed("rotate_left"):
		directionAmount -= 0.01
	if Input.is_action_just_pressed("godotplush_rotate_toggle"):
		rotateToggle = not rotateToggle
	directionAmount = clamp(-0.4,0.4,directionAmount)
	if rotateToggle:
		animator.speed_scale = 1
		self.rotate_y(directionAmount)
	else:
		animator.speed_scale = 0
