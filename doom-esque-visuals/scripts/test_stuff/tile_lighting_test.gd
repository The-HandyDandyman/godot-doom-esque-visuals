extends Node3D
@export var gridMap:GridMap

# Called when the node enters the scene tree for the first time.
func _ready():
	#LightingManager.generate_tile_lightmap(gridMap)
	$Camera3D/AnimationPlayer.play("move")
	pass
