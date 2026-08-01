extends Node

var pausable_time:float
var time_rollover:float = ProjectSettings.get_setting("rendering/limits/time/time_rollover_secs")

var fog:bool = false
var lightDiminish:bool = false

func _ready():
	use_pausable_time(true)
	set_fog(fog)
	set_light_dim(lightDiminish)

func use_pausable_time(use:bool = true):
	set_process(use)

func set_pausable_time(time:float = pausable_time):
	RenderingServer.global_shader_parameter_set("pausable_time",time)
	pausable_time = time
	if time >= time_rollover:
		time = 0.0
		print(time)

func _process(delta):
	set_pausable_time(pausable_time + delta)

func set_fog(active:bool,fog_modulate:Color = Color.BLACK,fog_diminish_curve:float = 1.0,min_fog:float = 0.0, max_fog:float = 8.0):
	RenderingServer.global_shader_parameter_set("fog_diminishing",active)
	fog = active
	if active:
		RenderingServer.global_shader_parameter_set("fog_modulate",fog_modulate)
		RenderingServer.global_shader_parameter_set("fog_diminish_curve",fog_diminish_curve)
		RenderingServer.global_shader_parameter_set("fog_min_diminish",min_fog)
		RenderingServer.global_shader_parameter_set("fog_max_diminish",max_fog)

func set_light_dim(active:bool,light_diminish_curve:float = 5.5,min_light:float = 0.0, max_light:float = 6.0):
	RenderingServer.global_shader_parameter_set("light_diminishing",active)
	lightDiminish = active
	if active:
		RenderingServer.global_shader_parameter_set("light_diminish_curve",light_diminish_curve)
		RenderingServer.global_shader_parameter_set("light_min_diminish",min_light)
		RenderingServer.global_shader_parameter_set("light_max_diminish",max_light)
