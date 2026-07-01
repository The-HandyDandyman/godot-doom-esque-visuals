extends Node3D

@onready var Text:Control = $Text/RichTextLabel
@onready var WorldEnv:WorldEnvironment = $WorldEnvironment

@export var environment_a:Environment
@export var environment_b:Environment
@onready var skybox:MeshInstance3D = $FullMap/LazySkyboxBecauseThisIsATestMap

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	Text.text = "Q and E to adjust camera\nA and D to rotate Godot plush\n" + ScreenOverlay.paletteRelatedText + "Escape to toggle fog (Currently set to " + str(WorldEnv.environment.fog_enabled) + ")\nTab to toggle environment\nBackspace to hide instructions"
