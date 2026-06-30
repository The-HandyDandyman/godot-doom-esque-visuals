extends Node2D

@onready var screenOverlay:CanvasLayer = $ScreenOverlay
@onready var adaptPalCover:ColorRect = $ScreenOverlay/OverlayB/adaptToPal
@onready var adaptPalShader:ShaderMaterial = adaptPalCover.material
@onready var palSwapCover:ColorRect = $ScreenOverlay/OverlayA/palSwap
@onready var palSwapShader:ShaderMaterial = palSwapCover.material
@export var defaultPALETTE:Texture
@export var PALETTE_SWAP:Texture
@export var defaultPalSize:Vector2i = Vector2i(16,16)
@export var defaultPalOffset:Vector2i = Vector2i(0,0)
var paletteSize:Vector2i = defaultPalSize

## Variable just used to test palette offset and palette swap
var newOffset:Vector2i = Vector2i.ZERO
var previousPalOffset:Vector2i = newOffset
var swap:bool = true

func paletteSetup(material:ShaderMaterial = palSwapShader, defaultPal:Texture = defaultPALETTE, paletteSwap:Texture = PALETTE_SWAP,paletteOffset:Vector2i = defaultPalOffset,newSize:Vector2i = defaultPalSize):
	if PALETTE_SWAP == null:
		PALETTE_SWAP = defaultPALETTE
	setDefaultPalette(defaultPal,material)
	setPaletteSwap(paletteSwap,material)
	setPaletteOffset(paletteOffset,material)
	setPaletteSize(newSize,material)

func setDefaultPalette(paletteTexture:Texture = defaultPALETTE,material:ShaderMaterial = palSwapShader):
	if paletteTexture == null: return
	material.set_shader_parameter("origPalette",paletteTexture)

func setPaletteSwap(paletteTexture:Texture = PALETTE_SWAP,material:ShaderMaterial = palSwapShader):
	if paletteTexture == null: return
	material.set_shader_parameter("palette",paletteTexture)

func setPaletteSize(newSize:Vector2i = defaultPalSize,material:ShaderMaterial = palSwapShader):
	paletteSize = newSize
	material.set_shader_parameter("paletteSize",paletteSize)

func setPaletteOffset(paletteOffset:Vector2i = Vector2i(0,0),material:ShaderMaterial = palSwapShader):
	print(paletteOffset)
	material.set_shader_parameter("paletteOffset",paletteOffset)

# Called when the node enters the scene tree for the first time.

func fullPaletteSetup(defaultPal:Texture = defaultPALETTE, paletteSwap:Texture = PALETTE_SWAP,paletteOffset:Vector2i = defaultPalOffset,newSize:Vector2i = defaultPalSize):
	paletteSetup()
	adaptPalShader.set_shader_parameter("palette",defaultPal)
	
func _ready():
	fullPaletteSetup()
# Remove the process function if you're using this for a project
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		newOffset.x -= 1
	elif Input.is_action_just_pressed("ui_left"):
		newOffset.x += 1
	if Input.is_action_just_pressed("ui_up"):
		newOffset.y += 1
	elif Input.is_action_just_pressed("ui_down"):
		newOffset.y -= 1
	if previousPalOffset != newOffset:
		previousPalOffset = newOffset
		setPaletteOffset(newOffset)
	if Input.is_action_just_pressed("ui_accept"):
		swap = not swap
	if swap:
		setPaletteSwap(PALETTE_SWAP)
	else:
		setPaletteSwap(defaultPALETTE)
