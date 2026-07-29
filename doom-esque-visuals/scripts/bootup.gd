extends Node2D
@export var nextScene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1,true).timeout
	TransitionManager.screen_melt_to_scene(nextScene.resource_path,1.0,3)
