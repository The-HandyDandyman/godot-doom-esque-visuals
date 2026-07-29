extends Node3D

@onready var Text:Control = $Text/RichTextLabel
@onready var WorldEnv:WorldEnvironment = $WorldEnvironment

@export var environment_a:Environment
@export var environment_b:Environment
@onready var skybox:MeshInstance3D = $FullMap/LazySkyboxBecauseThisIsATestMap
@onready var cameraPoint:AnimationPlayer = $Camera3D/AnimationPlayer
@export var sky:MeshInstance3D

func _ready():
	var paletteTest:TextureRect = ScreenOverlay.get_node("ScreenOverlay/OverlayB/PaletteTest")
	if paletteTest:
		paletteTest.visible = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sky != null:
		var skyOffset:Vector2 = Vector2(sky.get_surface_override_material(0).get_shader_parameter("offset").x + 0.01 * delta,0)
		sky.get_surface_override_material(0).set_shader_parameter("offset",skyOffset) # Really shoddy sky autoscroll, just here for demonstration purposes
	if Input.is_action_just_pressed("ui_cancel"):
		WorldEnv.environment.fog_enabled = not WorldEnv.environment.fog_enabled
	if Input.is_action_just_pressed("ui_text_backspace"):
		Text.visible = not Text.visible
	if Input.is_action_just_pressed("ui_text_indent"):
		if environment_a == null or environment_b == null: return
		skybox.visible = not skybox.visible
		var newEnvironment:Environment
		if skybox.visible:
			newEnvironment = environment_a
		else:
			newEnvironment = environment_b
		newEnvironment.fog_enabled = WorldEnv.environment.fog_enabled
		WorldEnv.environment = newEnvironment
	if Input.is_action_just_pressed("ui_text_delete"):
		if cameraPoint.current_animation != "otherpoint":
			cameraPoint.play("otherpoint")
		else:
			cameraPoint.play("RESET")
	Text.text = "Q and E to adjust camera\nA and D to rotate Godot plush\n" + ScreenOverlay.paletteRelatedText + "Escape to toggle fog (Currently set to " + str(WorldEnv.environment.fog_enabled) + ")\nTab to toggle environment\nDel to switch view\nR and T to adjust ghost opacity\nH to switch ghost dither texture\nBackspace to hide instructions"
