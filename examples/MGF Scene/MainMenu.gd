extends Control

@export var PanelMessenger: NodePath

func _init():
	GameData.create_file_data()

func _ready():
	print(OS.get_user_data_dir())
#	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	if Global.device_is_mobile():
		Global.isCheck = false
#	else:
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,
#		SceneTree.STRETCH_ASPECT_KEEP,
#		Vector2(1792,828),1)
#		Global.MGFMode = Global.MainUI
	GameData.check_ver()
	GameData.load_game_settings()
	
	$PanelBottom/ver.text = Global.ver + "  "
	
	NotiData.create_achi(0,"Wellcome MGF","New Update " + Global.ver)
	$Account.notifi_active()

# warning-ignore:return_value_discarded
	$GridContainer.get_child(0).connect("pressed",Callable(self,"_on_ButtonMatch_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(1).connect("pressed",Callable(self,"_on_ButtonSeason_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(2).connect("pressed",Callable(self,"_on_ButtonTrainning_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(4).connect("pressed",Callable(self,"_on_ButtonShop_pressed"))
## warning-ignore:return_value_discarded
#	$GridContainer.get_child(3).connect("pressed",Callable(self,"_on_ButtonRank_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(5).connect("pressed",Callable(self,"_on_ButtonSettings_pressed"))
	
	Settings.set_color(SeasonData.teamA)

func _on_ButtonMatch_pressed():
	Global.MGFMode = Global.MainGame
	SceneTransition.change_scene_to_file("res://MGF Scene/ConfigController/ConfigController.tscn")

func _on_ButtonTrainning_pressed():
	Global.MGFMode = Global.Trainning
	SceneTransition.change_scene_to_file("res://MGF Scene/ConfigController/ConfigController.tscn")

func _on_ButtonSeason_pressed():
	Global.MGFMode = Global.Season
	SeasonData.find_match()
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")

func _on_ButtonShop_pressed():
	Global.MGFMode = Global.SeasonMatch
	SceneTransition.change_scene_to_file("res://MGF Scene/Market/Market.tscn")

func _on_ButtonSettings_pressed():
	SceneTransition.change_scene_to_file("res://MGF Scene/Settings/Settings.tscn")

func _on_ButtonRank_pressed():
	pass
	
func wait_time():
	return await get_tree().create_timer(10.0).timeout
