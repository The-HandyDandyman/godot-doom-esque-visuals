extends Node2D

@onready var screen_overlay:CanvasLayer = $ScreenOverlay
@onready var adapt_pal_cover:ColorRect = $ScreenOverlay/OverlayB/adaptToPal
@onready var adapt_pal_shader:ShaderMaterial = adapt_pal_cover.material
@onready var pal_swap_cover:ColorRect = $ScreenOverlay/OverlayA/palSwap
@onready var pal_swap_shader:ShaderMaterial = pal_swap_cover.material
@export var default_palette:Texture
@export var palette_swap:Texture
@export var default_pal_size:Vector2i = Vector2i(16,16)
@export var default_pal_offset:Vector2i = Vector2i(0,0)
var palette_size:Vector2i = default_pal_size

## Variable just used to test palette offset and palette swap
var new_offset:Vector2i = Vector2i.ZERO
var previous_pal_offset:Vector2i = new_offset
var swap:bool = false
var palette_related_text:String

func toggle_postprocess_overlay(active:bool = true):
	screen_overlay.visible = active
	for child in screen_overlay.get_children():
		child.visible = active
func palette_setup(material:ShaderMaterial = pal_swap_shader, default_pal:Texture = default_palette, pal_swap:Texture = palette_swap,palette_offset:Vector2i = default_pal_offset,new_size:Vector2i = default_pal_size):
	if pal_swap == null:
		pal_swap = default_palette
	set_default_palette(default_pal,material)
	set_palette_swap(pal_swap,material)
	set_palette_offset(palette_offset,material)
	set_palette_size(new_size,material)

func set_default_palette(palette_texture:Texture = default_palette,material:ShaderMaterial = pal_swap_shader):
	if palette_texture == null: return
	PaletteUtil.set_palette(material,palette_texture,"palette_in")

func set_palette_swap(palette_texture:Texture = palette_swap,material:ShaderMaterial = pal_swap_shader):
	if palette_texture == null: return
	PaletteUtil.set_palette(material,palette_texture,"palette_out")

func set_palette_size(new_size:Vector2i = default_pal_size,material:ShaderMaterial = pal_swap_shader):
	palette_size = new_size
	PaletteUtil.set_palette_size(material,new_size)

func set_palette_offset(palette_offset:Vector2i = Vector2i(0,0),material:ShaderMaterial = pal_swap_shader):
	PaletteUtil.set_palette_size(material,palette_offset)

# Called when the node enters the scene tree for the first time.

func full_palette_setup(default_pal:Texture = default_palette, pal_swap:Texture = palette_swap,palette_offset:Vector2i = default_pal_offset,new_size:Vector2i = default_pal_size):
	palette_setup(pal_swap_shader,default_pal,pal_swap,palette_offset,new_size)
	PaletteUtil.set_palette(adapt_pal_shader,default_pal)
	
func _ready():
	full_palette_setup()
# Remove the process function if you're using this for a project
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		new_offset.x -= 1
	elif Input.is_action_just_pressed("ui_left"):
		new_offset.x += 1
	if Input.is_action_just_pressed("ui_up"):
		new_offset.y += 1
	elif Input.is_action_just_pressed("ui_down"):
		new_offset.y -= 1
	if previous_pal_offset != new_offset:
		previous_pal_offset = new_offset
		set_palette_offset(new_offset)
	if Input.is_action_just_pressed("ui_accept"):
		swap = not swap
	if swap:
		set_palette_swap(palette_swap)
	else:
		set_palette_swap(default_palette)
	palette_related_text = "Enter to toggle palette swap (Currently set to " + str(swap) + ")\nArrow keys to set palette offset" + str(new_offset) + "\n"
