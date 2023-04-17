extends Button


var id = 0
#onready var tabContainer = get_parent().get_parent().get_node("TabContainer")


func _on_BtnTab_pressed():
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	SeasonData.isSkip = false
	
	SeasonData.ss = id
	var data = GameData.get_data(GameData.data_path)
	data.settings.season = SeasonData.ss
	GameData.save_data(GameData.data_path,data)
	SeasonData.find_match()
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
