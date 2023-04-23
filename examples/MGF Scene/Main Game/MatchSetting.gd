extends Control


@onready var MainGame = get_parent().get_parent().get_parent().get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(Global.btntime).timeout
	load_data()


func load_data():
	var data = GameData.get_data(GameData.setting_data_path)
	$VBoxContainer/CamHeight/BtnCamHeight.value = data.Match.Controller[0]
	$VBoxContainer/CamPov/BtnCamPov.value = data.Match.Controller[1]
	
	MainGame.Cam.position.y = ($VBoxContainer/CamHeight/BtnCamHeight.value*1.0)/12.5*5
	MainGame.camPos = MainGame.Cam.position
	Global.camHeight = ($VBoxContainer/CamHeight/BtnCamHeight.value*1.0)/12.5*5
	MainGame.Cam.fov = remap($VBoxContainer/CamPov/BtnCamPov.value,0,100,30,80)

func _on_BtnCamHeight_drag_ended(value_changed):
	MainGame.Cam.position.y = ($VBoxContainer/CamHeight/BtnCamHeight.value*1.0)/12.5*5
	Global.camHeight = ($VBoxContainer/CamHeight/BtnCamHeight.value*1.0)/12.5*5
	var data = GameData.get_data(GameData.setting_data_path)
	data.Match.Controller[0] = $VBoxContainer/CamHeight/BtnCamHeight.value
	GameData.save_data(GameData.setting_data_path,data)

func _on_BtnCamPov_drag_ended(value_changed):
	MainGame.Cam.fov = remap($VBoxContainer/CamPov/BtnCamPov.value,0,100,30,80)
	var data = GameData.get_data(GameData.setting_data_path)
	data.Match.Controller[1] = $VBoxContainer/CamPov/BtnCamPov.value
	GameData.save_data(GameData.setting_data_path,data)


func _on_BtnSensitivity_drag_ended(value_changed):
	pass # Replace with function body.
