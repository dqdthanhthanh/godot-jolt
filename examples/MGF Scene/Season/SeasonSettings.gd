extends TabBar


@onready var season = get_parent().get_parent().get_parent()
var time = Time.get_datetime_dict_from_system()
var year = time["year"]

@onready var list = $Seasons/VScrollBarBXH/SeasonList
@onready var BtnTab = preload("res://MGF Scene/Season/BtnTab.tscn")

func load_setup():
	create_season_list()

func create_season_list():
	var data = GameData.get_data(GameData.data_path)
	
#	var season = data.settings.season
	var seasons = data.settings.seasons
	
	for i in seasons.size():
		var btnIns = BtnTab.instantiate()
		list.add_child(btnIns)
		btnIns.id = i
		btnIns.text = str(seasons[i])

func _on_ButtonNextSeason_pressed():
	Messenger.push_notification(1,'Creat "Next Season"')
	Messenger.btnYes.connect("pressed",Callable(self,"btn_next_season"))

func _on_ButtonNewSeason_pressed():
	Messenger.push_notification(1,'Creat "New Season" with new team')
	Messenger.btnYes.connect("pressed",Callable(self,"btn_new_season"))

func _on_ButtonResetData_pressed():
	Messenger.push_notification(1,'Clear all data in "Season Mode"')
	Messenger.btnYes.connect("pressed",Callable(self,"btn_reset_data"))

func btn_next_season():
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	var ssData = GameData.season_load_data()
	SeasonData.playersData = ssData.players
	for i in SeasonData.playersData.size():
		SeasonData.playersData[i].Season = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		SeasonData.playersData[i].Match = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	SeasonData.teamsData = ssData.teams
	for n in SeasonData.teamsData.size():
		SeasonData.teamsData[n].statS = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		SeasonData.teamsData[n].statC = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	await get_tree().create_timer(0.1).timeout
	
#	GameData.season_save_data(ssData)

	var data = GameData.get_data(GameData.data_path)
	data.settings.seasons.append(data.settings.seasons[data.settings.season] + 1)
	data.settings.season = data.settings.seasons.size()-1
	GameData.save_data(GameData.data_path,data)
	await get_tree().create_timer(0.1).timeout
#	print(data.settings.seasons)
#	print(data.settings.season)
#	print(GameData.season_get_file_path())

	GameData.season_save_data(FileData.ss)
	await get_tree().create_timer(0.1).timeout
	## Lay data
	ssData = GameData.season_load_data()
	var df = GameData.get_data(GameData.default_path)

	## Ke thua data
	ssData.teams = df.teams
	ssData.players = SeasonData.playersData
	ssData.teams = SeasonData.teamsData
	ssData.season.teamA = SeasonData.teamA
	ssData.name = data.settings.seasons[data.settings.season] + 1
	ssData.season.active = 1
	
	## Save data voi ss moi
	GameData.season_save_data(ssData)
	await get_tree().create_timer(0.1).timeout

	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Messenger.push_notification(0,"New Season " +str(ssData.name-1))
	var teamName = SeasonData.get_team_select_name()
	NotiData.create_noti("New Season "+ str(ssData.name-1),teamName + ": Next Season " + str(ssData.name-1) + " begin")
	Messenger.btnYes.disconnect("pressed",Callable(self,"btn_next_season"))

func btn_new_season():
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	var data = GameData.get_data(GameData.data_path)
	data.season.active = 0
	GameData.save_data(GameData.data_path,data)
	await get_tree().create_timer(0.1).timeout
	
	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Messenger.btnYes.disconnect("pressed",Callable(self,"btn_new_season"))

func btn_reset_data():
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	
	## CHange curr season select
	var data = GameData.get_data(GameData.data_path)
	data.settings.season = 0
	data.settings.seasons = []
	data.season.active = 0
	GameData.save_data(GameData.data_path,data)
	await get_tree().create_timer(0.1).timeout
	
	var path = GameData.userPath + GameData.seasonFolder + "/"
	GameData.data_clear_all(path)
	await get_tree().create_timer(0.1).timeout
	
	## Reload scene
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Messenger.btnYes.disconnect("pressed",Callable(self,"btn_reset_data"))
