extends Node


#onready var gsdSlider = $HSlider
#onready var gsdValue = $Label
@onready var currSpeed = 1

@export var toggleFast:Texture2D = preload("res://Assets2D/UI/iconFastForward.png")
@export var toggleNormal:Texture2D = preload("res://Assets2D/UI/iconNormalForward.png")

var speedMode = {
	1 : 1.5,
	2 : 2.0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var getSpeedData = GameData.return_game_speed_data()
	Engine.time_scale = float(getSpeedData)
	currSpeed = int(getSpeedData)
	toggle_icon()

func _on_BtnSpeed_pressed():
	currSpeed += 1
	if currSpeed > speedMode.size():
		currSpeed = 1
	Engine.time_scale = speedMode[currSpeed]
	GameData.save_game_speed(speedMode[currSpeed])
	toggle_icon()

func toggle_icon():
	if currSpeed == 1:
		self.icon = toggleNormal
	else:
		self.icon = toggleFast
