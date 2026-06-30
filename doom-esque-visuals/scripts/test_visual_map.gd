extends Node3D

@onready var Text:Control = $Text/RichTextLabel
@onready var WorldEnv:WorldEnvironment = $WorldEnvironment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		WorldEnv.environment.fog_enabled = not WorldEnv.environment.fog_enabled
	if Input.is_action_just_pressed("ui_text_backspace"):
		Text.visible = not Text.visible
	Text.text = "Q and E to adjust camera\nA and D to rotate Godot plush\n" + ScreenOverlay.paletteRelatedText + "Escape to toggle fog (Currently set to " + str(WorldEnv.environment.fog_enabled) + ")\nBackspace to hide instructions"
