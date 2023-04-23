extends Control

@onready var image = $BackGround

var bg:Dictionary = {
	"image":[
		{"file":"00816-2252159293.jpg","label":"Background","active":true,"type":0},
		{"file":"00828-1151896567.jpg","label":"Background","active":true,"type":0},
		{"file":"00830-3862997287.jpg","label":"Background","active":true,"type":0},
		{"file":"00831-2315283149.jpg","label":"Background","active":true,"type":0},
		{"file":"00832-4046300330.jpg","label":"Background","active":true,"type":0},
	]
}

func _ready() -> void:
	image.texture = load(load_random_image())
	await get_tree().create_timer(0.2).timeout
	$PanelBottom/ver.text = Global.ver + "  "

func load_random_image() -> String:
	var files = bg.image
	var ranimage = Calculate.random_in_size(files).file
	return "res://Assets2D/UI/stadium/High/" + ranimage

func _exit_tree():
	queue_free()
