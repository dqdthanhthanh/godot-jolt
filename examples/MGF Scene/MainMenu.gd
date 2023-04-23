extends Control

func _init():
	GameData.create_file_data()

func _ready() -> void:
	$ButtonVoiceTest.visible = Global.isDebug
	
	if OS.get_name() == "HTML5":
		$GridContainer.get_child(1).is_lock = true
		$GridContainer.get_child(1).info_text = "Click To Dowload Full App"
	if Global.device_is_mobile():
		pass
	else:
		Global.MGFMode = Global.MainUI
	check_ver()
	
	Notification.create_achi(0,"Wellcome MGF",["New Update " + Global.ver,
	"-  Add two playable teams in Season Mode: Machine and Soldier.",
	"-  New design skins for the players in two teams Machine and Soldier.",
	"-  Optimized and fixed Weather effect shaders.",
		])
	Account.notifi_news()
# warning-ignore:return_value_discarded
#	$GridContainer.get_child(0).connect("pressed", self, "_on_ButtonMatch_pressed")
# warning-ignore:return_value_discarded
	$GridContainer.get_child(2).connect("pressed", Callable(self, "_on_ButtonFreeMode_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(1).connect("pressed", Callable(self, "_on_ButtonSeason_pressed"))
# warning-ignore:return_value_discarded
	$GridContainer.get_child(4).connect("pressed", Callable(self, "_on_ButtonShop_pressed"))
## warning-ignore:return_value_discarded
#	$GridContainer.get_child(3).connect("pressed", self, "_on_ButtonRank_pressed")
# warning-ignore:return_value_discarded
	$GridContainer.get_child(5).connect("pressed", Callable(self, "_on_ButtonInfo_pressed"))
	
	GlobalTheme.set_color(SeasonData.teamA)
	
	await get_tree().create_timer(0.1).timeout
	$GridContainer.get_child(1).disabled = false

func _on_ButtonMatch_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Global.MGFMode = Global.MainGame
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/QuickMatch/QuickMatch.tscn")

func _on_ButtonFreeMode_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Global.gameModeCur = 1
	Global.MGFMode = Global.FreeMode
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/QuickMatch/QuickMatch.tscn")

func _on_ButtonSeason_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	if OS.get_name() == "HTML5":
		OS.shell_open("https://mgf-game.itch.io/mgf")
	else:
		Global.MGFMode = Global.Season
	# warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")

func _on_ButtonShop_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Global.MGFMode = Global.Market
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Market/Market.tscn")

func _on_ButtonInfo_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/MainInfo.tscn")

func _on_ButtonRank_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded

func check_ver():
	var file_data:FileData = FileData.new()
	
	var data = GameData.get_data(GameData.setting_data_path)
	var oldVer = data.ver
	var newVer = file_data.settings.ver

	if not FileAccess.file_exists(GameData.data_path):
		print("New Update")
		GameData.create_new_data_ver()
	elif int(newVer) > int(oldVer):
		print("New Update")
		GameData.create_new_data_ver()
	elif int(newVer) < int(oldVer):
		print("Error, update")
		GameData.create_new_data_ver()
	else:
		print("Check Done")
		
	newVer = oldVer
	
	SeasonData.ss = data.season
	return newVer

func _exit_tree():
	queue_free()

func _on_ButtonVoiceTest_pressed():
	SceneTransition.change_scene_to_file("res://MGF Scene/tts_3x_test/Control.tscn")


func _on_button_base_pressed():
	get_tree().change_scene_to_file("res://MGF Scene/MainInfo.tscn")
