extends MeshInstance3D

@onready var animator:AnimationPlayer = $AnimationPlayer
var directionAmount:float = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("animate")

func _process(delta):
	if Input.is_action_pressed("rotate_right"):
		directionAmount += 0.01
	elif Input.is_action_pressed("rotate_left"):
		directionAmount -= 0.01
	directionAmount = clamp(-0.4,0.4,directionAmount)
	self.rotate_y(directionAmount)
