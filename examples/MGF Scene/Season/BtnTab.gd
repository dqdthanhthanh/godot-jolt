extends Button


var id:int = 0


func _on_BtnTab_pressed() -> void:
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	SeasonData.isSkip = false
	
	SeasonData.ss = id
	var data = GameData.get_data(GameData.setting_data_path)
	data.season = SeasonData.ss
	GameData.save_data(GameData.setting_data_path,data)
	SeasonData.find_match()
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")

func _exit_tree():
	queue_free()
