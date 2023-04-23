extends Button

func _on_ButtonRestart_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/GameScene.tscn")

func _on_Button_Win_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://scenes/Main.tscn")

func _on_MenuButton_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/GameScene.tscn")

func _on_ButtonExit_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	get_tree().quit()

func _on_Formation1_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	FormationData.CanFormation = true
	FormationData.teamForm = Global.teamID1
	FormationData.teamFor = 1
	GlobalTheme.set_color(Global.teamID1)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_Formation2_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	FormationData.CanFormation = true
	FormationData.teamForm = Global.teamID2
	FormationData.teamFor = 2
	GlobalTheme.set_color(Global.teamID2)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")


func _on_ButtonMatch_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/QuickMatch/QuickMatch.tscn")


func _on_ButtonLeague_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/League/BXH.tscn")

func _on_Home_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/MainMenu.tscn")
