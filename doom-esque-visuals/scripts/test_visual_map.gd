extends Node3D

@onready var Text:Control = $Text/RichTextLabel
@onready var WorldEnv:WorldEnvironment = $WorldEnvironment

@export var environment_a:Environment
@export var environment_b:Environment
@onready var skybox:MeshInstance3D = $FullMap/LazySkyboxBecauseThisIsATestMap
@onready var camera_point:AnimationPlayer = $Camera/AnimationPlayer
@export var sky:MeshInstance3D
@onready var music_player:AudioStreamPlayer = $AudioStreamPlayer
@export var lightmap:Texture2D
@export var diminishmap:Texture2D
@export var lightmap_origin:Vector2
@export var lightmap_size:Vector2

var sky_offset:Vector2 = Vector2.ZERO

func _ready():
	ShaderGlobalManager.set_lightmap(lightmap,diminishmap,lightmap_origin,lightmap_size)
	var palette_test:TextureRect = ScreenOverlay.get_node("ScreenOverlay/OverlayB/PaletteTest")
	if palette_test:
		palette_test.visible = true
	setup_sky_offset()

func setup_sky_offset():
	sky_offset = sky.get_surface_override_material(0).get_shader_parameter("offset")

func setup_the_fog(env:Environment):
	ShaderGlobalManager.set_fog(ShaderGlobalManager.fog,env.fog_light_color,env.fog_depth_curve,env.fog_depth_begin,env.fog_depth_end)
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		ShaderGlobalManager.fog = not ShaderGlobalManager.fog
		setup_the_fog(WorldEnv.environment)
	if Input.is_action_just_pressed("light_diminishing_toggle"):
		ShaderGlobalManager.set_light_dim(not ShaderGlobalManager.lightDiminish)
	if Input.is_action_just_pressed("ui_text_backspace"):
		Text.visible = not Text.visible
	if Input.is_action_just_pressed("mute"):
		music_player.volume_db = -80.0 if music_player.volume_db == -4.0 and music_player.playing else -4.0
		if !music_player.playing: music_player.play()
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
		if camera_point.current_animation != "otherpoint" and camera_point.current_animation != "otherotherpoint":
			camera_point.play("otherpoint")
		elif camera_point.current_animation != "otherotherpoint":
			camera_point.play("otherotherpoint")
		else:
			camera_point.play("RESET")
	Text.text = "Q and E to adjust camera\nA and D to rotate Godot plush\nW to toggle Godot plushie rotation\n" + ScreenOverlay.palette_related_text + "Escape to toggle fog (Currently set to " + str(WorldEnv.environment.fog_enabled) + ")
	Tab to toggle environment\nEquals sign to toggle light diminishing\nDel to switch view\nJ to toggle mouselook\nK to toggle y-shearing
	R and T to adjust ghost opacity\nH to switch ghost dither texture\nM to mute music\nBackspace to hide instructions"
