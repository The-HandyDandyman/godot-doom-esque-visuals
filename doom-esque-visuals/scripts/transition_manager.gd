extends Control

@export var melt_transition:TextureRect
# Called when the node enters the scene tree for the first time.
func _ready():
	melt_transition.visible = false

func screen_melt_to_scene(next_scene:String,length:float = 1.0,chunk_size:int = 1,meltiness:float = 1.0):
	if chunk_size < 1: chunk_size = 1
	melt_transition.visible = true
	var tween:Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var img:Image = get_viewport().get_texture().get_image()
	var tex:ImageTexture = ImageTexture.create_from_image(img)
	melt_transition.texture = tex
	melt_transition.material.set_shader_parameter("shader_parameter/progress",0.0)
	melt_transition.material.set_shader_parameter("shader_parameter/progress",0.0)
	get_tree().change_scene_to_file(next_scene)
	get_tree().paused = true
	print("transition!")
	tween.tween_property(melt_transition.material,"shader_parameter/progress",1.0,length)
	await tween.finished
	get_tree().paused = false
	melt_transition.visible = false
