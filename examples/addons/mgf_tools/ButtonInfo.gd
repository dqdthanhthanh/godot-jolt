@tool
extends Control


@export var label_text:String = "Label"
@export var info_text:String = "Info"
@export var icon_texture = preload("res://Assets2D/UI/user.png")
@export var bg_texture = preload("res://Assets2D/UI/user.png")
@export var is_bg:bool = false
@export var is_lock:bool = false
@export var is_info:bool = true
@export var is_info_btn:bool = true

@onready var labelText:Label = $Main/Label/Label

@onready var info: = $Main/Info/Info
@onready var infoText: = $Main/Info/Info/Info
@onready var infoBtn: = $Main/Info/Info/Control

@onready var iconTexture: = $Main/Label/Icon
@onready var lockTexture: = $Main/Label/LockIcon
@onready var bgTexture: = $Main/Label/bg

var bg:Dictionary = {
	"image":[
		{"file":"00816-2252159293.jpg","label":"Background","active":true,"type":0},
		{"file":"00828-1151896567.jpg","label":"Background","active":true,"type":0},
		{"file":"00830-3862997287.jpg","label":"Background","active":true,"type":0},
		{"file":"00831-2315283149.jpg","label":"Background","active":true,"type":0},
		{"file":"00832-4046300330.jpg","label":"Background","active":true,"type":0},
	]
}

func _run() -> void:
	load_setup()

#func _process(delta) -> void:
#	if Engine.editor_hint:
#		load_setup()

func _ready() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	load_setup()

func load_setup() -> void:
	labelText.text = label_text
	infoText.text = info_text
	iconTexture.texture = icon_texture
	lockTexture.visible = is_lock
	info.visible = is_info
	infoBtn.visible = is_info_btn
	self.disabled = is_lock
	if is_lock == false:
		iconTexture.modulate.a = 0.5
	else:
		iconTexture.modulate.a = 0.5
	if is_bg == false:
		bgTexture.texture = load(load_random_image())
	else:
		bgTexture.texture = bg_texture

func load_random_image() -> String:
	var files = bg.image
	var ranimage = Calculate.random_in_size(files).file
	return "res://Assets2D/UI/stadium/Low/" + ranimage
