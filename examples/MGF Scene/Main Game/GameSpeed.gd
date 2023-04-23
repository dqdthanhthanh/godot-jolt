extends Node

@onready var currSpeed:int = 1

var speedMode: = [1.5,2.0,2.0]

func _ready() -> void:
	var getSpeedData = GameData.return_game_speed_data()
	Engine.time_scale = speedMode[int(getSpeedData)]
	currSpeed = int(getSpeedData)
	toggle_icon()

func _on_BtnSpeed_pressed() -> void:
	if currSpeed == 0:
		currSpeed += 1
	else:
		currSpeed = 0
	Engine.time_scale = speedMode[int(currSpeed)]
	GameData.save_game_speed(int(currSpeed))
	toggle_icon()

func toggle_icon() -> void:
	var toggleFast:Texture2D = load("res://Assets2D/UI/iconFastForward.png")
	var toggleNormal:Texture2D = load("res://Assets2D/UI/iconNormalForward.png")
	
	if currSpeed == 0:
		self.icon = toggleNormal
	else:
		self.icon = toggleFast

func _exit_tree():
	queue_free()
