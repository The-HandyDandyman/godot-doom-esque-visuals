extends Camera3D



func _process(delta):
	var directionAmount:float = 0.0
	if Input.is_action_pressed("rotate_cam_right"):
		directionAmount = -2 * delta
	elif Input.is_action_pressed("rotate_cam_left"):
		directionAmount = 2 * delta
	self.rotate_y(directionAmount)
