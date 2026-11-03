extends Node3D
@export var gridMap:GridMap
@export var lightmap:Texture2D
@export var diminishmap:Texture2D
@export var lightmap_origin:Vector2
@export var lightmap_size:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	ShaderGlobalManager.set_lightmap(lightmap,diminishmap,lightmap_origin,lightmap_size)
	#LightingManager.generate_tile_lightmap(gridMap)
	
	$Camera3D/AnimationPlayer.play("move")
	pass
