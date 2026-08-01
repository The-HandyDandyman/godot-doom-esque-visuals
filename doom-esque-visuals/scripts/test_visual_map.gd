extends Node3D

@onready var Text:Control = $Text/RichTextLabel
@onready var WorldEnv:WorldEnvironment = $WorldEnvironment

@export var environment_a:Environment
@export var environment_b:Environment
@onready var skybox:MeshInstance3D = $FullMap/LazySkyboxBecauseThisIsATestMap
@onready var cameraPoint:AnimationPlayer = $Camera3D/AnimationPlayer
@export var sky:MeshInstance3D
@onready var musicPlayer:AudioStreamPlayer = $AudioStreamPlayer

var skyOffset:Vector2 = Vector2.ZERO

func _ready():
	var paletteTest:TextureRect = ScreenOverlay.get_node("ScreenOverlay/OverlayB/PaletteTest")
	if paletteTest:
		paletteTest.visible = true
	setup_sky_offset()

func setup_sky_offset():
	skyOffset = sky.get_surface_override_material(0).get_shader_parameter("offset")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func setup_the_fog(env:Environment):
	ShaderGlobalManager.set_fog(ShaderGlobalManager.fog,env.fog_light_color,env.fog_depth_curve,env.fog_depth_begin,env.fog_depth_end)
func _process(delta):
	if sky != null:
		var scrollSky:Vector2 = Vector2(skyOffset.x + 0.01 * ShaderGlobalManager.pausable_time,0)
		sky.get_surface_override_material(0).set_shader_parameter("offset",scrollSky) # Really shoddy sky autoscroll, just here for demonstration purposes
	if Input.is_action_just_pressed("ui_cancel"):
		ShaderGlobalManager.fog = not ShaderGlobalManager.fog
		setup_the_fog(WorldEnv.environment)
	if Input.is_action_just_pressed("light_diminishing_toggle"):
		ShaderGlobalManager.set_light_dim(not ShaderGlobalManager.lightDiminish)
	if Input.is_action_just_pressed("ui_text_backspace"):
		Text.visible = not Text.visible
	if Input.is_action_just_pressed("mute"):
		musicPlayer.volume_db = -80.0 if musicPlayer.volume_db == -4.0 and musicPlayer.playing else -4.0
		if !musicPlayer.playing: musicPlayer.play()
	if Input.is_action_just_pressed("ui_text_indent"):
		if environment_a == null or environment_b == null: return
		skybox.visible = not skybox.visible
		var newEnvironment:Environment
		if skybox.visible:
			newEnvironment = environment_a
		else:
			newEnvironment = environment_b
		newEnvironment.fog_enabled = false
		setup_the_fog(newEnvironment)
		WorldEnv.environment = newEnvironment
	if Input.is_action_just_pressed("ui_text_delete"):
		if cameraPoint.current_animation != "otherpoint" and cameraPoint.current_animation != "otherotherpoint":
			cameraPoint.play("otherpoint")
		elif cameraPoint.current_animation != "otherotherpoint":
			cameraPoint.play("otherotherpoint")
		else:
			cameraPoint.play("RESET")
	Text.text = "Q and E to adjust camera\nA and D to rotate Godot plush\nW to toggle Godot plushie rotation\n" + ScreenOverlay.paletteRelatedText + "Escape to toggle fog (Currently set to " + str(WorldEnv.environment.fog_enabled) + ")\nTab to toggle environment\nEquals sign to toggle light diminishing\nDel to switch view\nR and T to adjust ghost opacity\nH to switch ghost dither texture\nM to mute music\nBackspace to hide instructions"
