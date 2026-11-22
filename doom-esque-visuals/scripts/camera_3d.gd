extends Node3D
var mouselook:bool = false
var yshearing:bool = false
var previous_yshear:bool = false
@onready var actual_camera:Camera3D = $Camera3D
@onready var cam_raycast:RayCast3D = $Camera3D/RayCast3D

const MOUSE_SENSITIVITY:float = 0.25
const MIN_VERTICAL_ROTATION:float = -89
const MAX_VERTICAL_ROTATION:float = 89

func _ready():
	set_frustum_fov(actual_camera,75)

func _process(delta):
	if Input.is_action_just_pressed("mouselook_toggle"):
		mouselook = not mouselook
		if mouselook:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("yshear_toggle"):
		set_y_shear(not yshearing)
	if mouselook: return
	else: 
		actual_camera.rotation.x = 0
		actual_camera.frustum_offset.y = 0
	var dir_amount:float = 0.0
	if Input.is_action_pressed("rotate_cam_right"):
		dir_amount = -2 * delta
	elif Input.is_action_pressed("rotate_cam_left"):
		dir_amount = 2 * delta
	self.rotate_y(dir_amount)


func set_y_shear(active:bool = not yshearing):
	yshearing = active
	# Convert rotation degrees to frustum_offset/"shear" and vice versa when switching
	if active:
		var degreesToShear:float = tan(deg_to_rad(actual_camera.rotation_degrees.x)) * (actual_camera.size / 2.0)
		actual_camera.frustum_offset.y = clamp(degreesToShear,MIN_VERTICAL_ROTATION / 180, MAX_VERTICAL_ROTATION / 180)
		actual_camera.rotation_degrees.x = 0
		cam_raycast.target_position.y = actual_camera.frustum_offset.y * 50
	else:
		var shearToDegrees:float = atan(actual_camera.frustum_offset.y / (actual_camera.size / 2.0))
		actual_camera.rotation_degrees.x = clamp(rad_to_deg(shearToDegrees),MIN_VERTICAL_ROTATION, MAX_VERTICAL_ROTATION)
		actual_camera.frustum_offset.y = 0
		cam_raycast.target_position.y = 0.0
		
func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			self.rotation_degrees.y += event.relative.x * -MOUSE_SENSITIVITY
			if yshearing:
				actual_camera.frustum_offset.y += deg_to_rad(event.relative.y * (-MOUSE_SENSITIVITY * 0.1))
				actual_camera.frustum_offset.y = clamp(actual_camera.frustum_offset.y,MIN_VERTICAL_ROTATION / 180, MAX_VERTICAL_ROTATION / 180)
				cam_raycast.target_position.y = actual_camera.frustum_offset.y * 50
			else:
				actual_camera.rotation_degrees.x += event.relative.y * -MOUSE_SENSITIVITY
				actual_camera.rotation_degrees.x = clamp(actual_camera.rotation_degrees.x, MIN_VERTICAL_ROTATION, MAX_VERTICAL_ROTATION)
				cam_raycast.target_position.y = 0.0
		if event is InputEventMouseButton and event.pressed and cam_raycast.is_colliding():
			var collider:Object = cam_raycast.get_collider()
			if !is_instance_valid(collider): return
			var parent:Object = collider.get_parent()
			if !is_instance_valid(parent): return
			if parent.has_method("interact"):
				parent.interact()

func set_frustum_fov(camera:Camera3D,fov:float = 75.0):
	return 2 * camera.near * tan(deg_to_rad(fov) / 2.0)
