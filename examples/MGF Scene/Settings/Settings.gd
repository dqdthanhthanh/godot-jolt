extends Control

@onready var btnClearData = $VBoxContainer/BtnClearData

func _ready():
	btnClearData.connect("pressed",Callable(self,"btn_clear_data"))

func btn_clear_data():
	Messenger.push_notification(1,'Clear all "game data" ?')
	Messenger.btnYes.connect("pressed",Callable(self,"clear_all_data"))

func clear_all_data():
	GameData.data_clear_all(GameData.userPath)
	
	await get_tree().create_timer(0.1).timeout
	
	SceneTransition.change_scene_to_file("res://MGF Scene/UIMenu.tscn")
	Messenger.push_notification(0,'Clear data Done !!!')
	Messenger.btnYes.disconnect("pressed",Callable(self,"clear_all_data"))
