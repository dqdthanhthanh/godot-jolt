extends Button

func _on_ButtonRestart_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/GameScene.tscn")

func _on_Button_Win_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://scenes/Main.tscn")

func _on_MenuButton_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/GameScene.tscn")

func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_StartGameButton_pressed():
	GameData.save_game_settings()
# 	warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")

func _on_Formation1_pressed():
	FormationData.teamForm = Global.teamID1
	FormationData.CanFormation = true
	FormationData.teamFor = 1
	Settings.set_color(Global.teamID1)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_Formation2_pressed():
	FormationData.teamForm = Global.teamID2
	FormationData.CanFormation = true
	FormationData.teamFor = 2
	Settings.set_color(Global.teamID2)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")


func _on_ButtonMatch_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/ConfigController/ConfigController.tscn")


func _on_ButtonLeague_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/League/BXH.tscn")

func _on_home_pressed():
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/UIMenu.tscn")
