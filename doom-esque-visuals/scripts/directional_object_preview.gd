extends MeshInstance3D

@onready var animator:AnimationPlayer = $AnimationPlayer
var directionAmount:float = 0.01
# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("animate")

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		directionAmount += 0.005
	elif Input.is_action_pressed("ui_down"):
		directionAmount -= 0.005
	self.rotate_y(directionAmount)
