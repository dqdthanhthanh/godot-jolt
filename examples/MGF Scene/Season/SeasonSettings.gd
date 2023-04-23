extends Control


@onready var season: = get_parent().get_parent().get_parent()
var time: = Time.get_datetime_dict_from_system()
var year = time["year"]

@onready var list: = $Seasons/VScrollBarBXH/SeasonList

func load_setup() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	create_season_list()

func create_season_list() -> void:
	var data = GameData.get_data(GameData.setting_data_path)
	
#	var season = data.season
	var seasons = data.seasons
	
	for i in seasons.size():
		var btnIns = load("res://MGF Scene/Season/BtnTab.tscn").instantiate()
		list.add_child(btnIns)
		btnIns.id = i
		btnIns.text = str(seasons[i])

func _on_ButtonNextSeason_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Notification.push_noti(1,'Creat "Next Season"')
	Notification.btnYes.connect("pressed", Callable(self, "btn_next_season"))

func _on_ButtonNewSeason_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Notification.push_noti(1,'Creat "New Season" with new team')
	Notification.btnYes.connect("pressed", Callable(self, "btn_new_season"))

func _on_ButtonResetData_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Notification.push_noti(1,'Clear all data in "Season Mode"')
	Notification.btnYes.connect("pressed", Callable(self, "btn_reset_data"))

func btn_next_season() -> void:
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	var ssData = GameData.season_load_data()
	var playersData = ssData.players
	var teamsData = ssData.teams
	for i in playersData.size():
		playersData[i].Season = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		playersData[i].Match = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for n in teamsData.size():
		teamsData[n].statS = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		teamsData[n].statC = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	await get_tree().create_timer(0.1).timeout
	
#	GameData.season_save_data(ssData)

	var data = GameData.get_data(GameData.setting_data_path)
	data.seasons.append(data.seasons[data.season] + 1)
	data.season = data.seasons.size()-1
	GameData.save_data(GameData.setting_data_path,data)
	await get_tree().create_timer(0.1).timeout
#	print(data.seasons)
#	print(data.season)
#	print(GameData.season_get_file_path())
	var file_data:FileData = FileData.new()
	GameData.season_save_data(file_data.ss)
	await get_tree().create_timer(0.1).timeout
	## Lay data
	ssData = GameData.season_load_data()

	## Ke thua data
	ssData.teams = file_data.teams
	ssData.players = playersData
	ssData.teams = teamsData
	ssData.season.teamA = SeasonData.teamA
	ssData.name = data.seasons[data.season] + 1
	ssData.season.active = true
	
	## Save data voi ss moi
	GameData.season_save_data(ssData)
	await get_tree().create_timer(0.1).timeout

	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Notification.push_noti(2,"New Season " +str(ssData.name-1))
	var teamName = SeasonData.get_team_select_name()
	Notification.create_noti("New Season "+ str(ssData.name-1),[teamName + ": Next Season " + str(ssData.name-1) + " begin"])
	Notification.btnYes.disconnect("pressed", Callable(self, "btn_next_season"))

func btn_new_season() -> void:
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	var data = GameData.get_data(GameData.data_path)
	data.season.active = false
	GameData.save_data(GameData.data_path,data)
	await get_tree().create_timer(0.1).timeout
	
	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Notification.btnYes.disconnect("pressed", Callable(self, "btn_new_season"))

func btn_reset_data() -> void:
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	## CHange curr season select
	var set = GameData.get_data(GameData.setting_data_path)
	var data = GameData.get_data(GameData.data_path)
	set.season = 0
	set.seasons = []
	data.season.active = false
	GameData.save_data(GameData.setting_data_path,set)
	GameData.save_data(GameData.data_path,data)
	await get_tree().create_timer(0.1).timeout
	
	var path = GameData.user_path + GameData.season_folder + "/"
	GameData.data_clear_all(path)
	await get_tree().create_timer(0.1).timeout
	
	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Notification.btnYes.disconnect("pressed", Callable(self, "btn_reset_data"))

func _exit_tree():
	queue_free()
