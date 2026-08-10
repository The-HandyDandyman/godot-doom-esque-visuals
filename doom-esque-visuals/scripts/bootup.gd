extends Node2D
@export var testScenes:Array[PackedScene]


func _on_button_pressed():
	TransitionManager.screen_melt_to_scene(testScenes[0].resource_path,1.0,3)


func _on_button_2_pressed():
	TransitionManager.dither_to_scene(testScenes[1].resource_path,0.25)
