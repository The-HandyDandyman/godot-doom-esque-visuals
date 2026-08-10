extends Node3D
var mouselook:bool = false
var yshearing:bool = false
var previouslyYshear:bool = false
@onready var actualCamera:Camera3D = $Camera3D

const MOUSE_SENSITIVITY:float = 0.25
const MIN_VERTICAL_ROTATION:float = -89
const MAX_VERTICAL_ROTATION:float = 89

func _ready():
	set_frustum_fov(actualCamera,75)

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
		actualCamera.rotation.x = 0
		actualCamera.frustum_offset.y = 0
	var directionAmount:float = 0.0
	if Input.is_action_pressed("rotate_cam_right"):
		directionAmount = -2 * delta
	elif Input.is_action_pressed("rotate_cam_left"):
		directionAmount = 2 * delta
	self.rotate_y(directionAmount)


func set_y_shear(active:bool = not yshearing):
	yshearing = active
	# Convert rotation degrees to frustum_offset/"shear" and vice versa when switching
	if active:
		var degreesToShear:float = tan(deg_to_rad(actualCamera.rotation_degrees.x)) * (actualCamera.size / 2.0)
		actualCamera.frustum_offset.y = clamp(degreesToShear,MIN_VERTICAL_ROTATION / 180, MAX_VERTICAL_ROTATION / 180)
		actualCamera.rotation_degrees.x = 0
	else:
		var shearToDegrees:float = atan(actualCamera.frustum_offset.y / (actualCamera.size / 2.0))
		actualCamera.rotation_degrees.x = clamp(rad_to_deg(shearToDegrees),MIN_VERTICAL_ROTATION, MAX_VERTICAL_ROTATION)
		actualCamera.frustum_offset.y = 0
		
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotation_degrees.y += event.relative.x * -MOUSE_SENSITIVITY
		if yshearing:
			actualCamera.frustum_offset.y += deg_to_rad(event.relative.y * (-MOUSE_SENSITIVITY * 0.1))
			actualCamera.frustum_offset.y = clamp(actualCamera.frustum_offset.y,MIN_VERTICAL_ROTATION / 180, MAX_VERTICAL_ROTATION / 180)
		else:
			actualCamera.rotation_degrees.x += event.relative.y * -MOUSE_SENSITIVITY
			actualCamera.rotation_degrees.x = clamp(actualCamera.rotation_degrees.x, MIN_VERTICAL_ROTATION, MAX_VERTICAL_ROTATION)

func set_frustum_fov(camera:Camera3D,fov:float = 75.0):
	return 2 * camera.near * tan(deg_to_rad(fov) / 2.0)
