extends Control

@onready var team1s
@onready var teamAStats = $TeamSelect/TeamStats/TeamAStats
@onready var teamSM = $TeamSelect/TeamSM/ScrollContainer/CenterContainer/GridContainer
@onready var teamIcon = $TeamSelect/Teamselect1
@onready var ssMatch = $SeasonMatch
@onready var mainBtn = $MainBtn
@onready var disable = $Disable

@onready var seasonMain = $SeasonMain
@onready var seasonName = $SeasonMain/LabelBase
@onready var tabContainer = $TabContainer
@onready var SeasonTab = preload("res://MGF Scene/Season/SeasonTab.tscn")
@onready var BtnTab = preload("res://MGF Scene/Season/BtnTab.tscn")


func _ready():
	Settings.set_color(SeasonData.teamA)
	$MatchInfo.hide()
	get_set_season_name()
	Global.MGFMode = Global.Season
	check_league_data()

func create_teams_ins():
	var teamIns = preload("res://MGF Scene/ConfigController/Teamselect.tscn")
	if teamSM.get_child_count()>0:
		for unit in teamSM.get_children():
			unit.queue_free()
	
	var data = GameData.season_load_data()
	var teamData = data.teams
	for i in teamData.size():
		var ins = teamIns.instantiate()
		ins.teamIcon = i
		teamSM.add_child(ins)
	
	for unit in teamSM.get_children():
		unit.add_to_group("team1")
	team1s = get_tree().get_nodes_in_group("team1")
	for team1 in team1s:
		team1.connect("pressed",Callable(self,"_on_teamSelectButton").bind(team1))

func _on_teamSelectButton(value):
	SeasonData.teamA = value
	var data = GameData.season_load_data()
	var teamData = data.teams
	SeasonData.teamA = value.teamIcon
	teamIcon.icon = load(teamData[value.teamIcon].icon)
	GameData.load_teamStats_data(teamAStats,value.teamIcon)
	GameData.return_radarStats_data($TeamSelect/RadarChartStats,value.teamIcon)
	Settings.set_color(SeasonData.teamA)

func _on_ButtonTeamApply_pressed():
	var time = Time.get_datetime_dict_from_system()
	var year = time["year"]
	
	var base = GameData.get_data(GameData.data_path)
	base.season.active = 1
	base.settings.seasons.append(year+base.settings.seasons.size())
	base.settings.season = base.settings.seasons.size()-1
	GameData.save_data(GameData.data_path,base)
	
	var df = GameData.get_data(GameData.default_path)
	FileData.ss.teams = df.teams
	FileData.ss.players = df.players
	
	GameData.save_data(GameData.season_get_file_path(),FileData.ss)
	
#	print(GameData.season_get_file_path())
	var data = GameData.season_load_data()
	var seasonData = data.season
	seasonData.name = year + base.settings.seasons.size()-1
	seasonData.teamA = SeasonData.teamA

	GameData.save_data(GameData.season_get_file_path(),data)
	
	var teamName = SeasonData.get_team_select_name()
	NotiData.create_achi(1,"New Season Achievement","First time playing season mode")
	NotiData.create_noti("New Season "+ str(seasonData.name),teamName + ": New Season " + str(seasonData.name) + " begin")
	$Account.notifi_active()
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Messenger.push_notification(0,"New Season " +str(seasonData.name))

func check_league_data():
	var data = GameData.get_data(GameData.data_path)
	var teamData = data.teams
	var seasonData = data.season
	if seasonData.active == 1:
		$TeamSelect.hide()
		seasonMain.show()
		mainBtn.show()
		tabContainer.show()
	else:
		create_teams_ins()
		teamIcon.icon = load(teamData[int(SeasonData.teamA)].icon)
		GameData.load_teamStats_data(teamAStats,int(SeasonData.teamA))
		GameData.return_radarStats_data($TeamSelect/RadarChartStats,int(SeasonData.teamA))
		$TeamSelect.show()
		seasonMain.hide()
		mainBtn.hide()
		tabContainer.hide()

func get_set_season_name():
	var data = GameData.get_data(GameData.data_path)
	var season = data.settings.season
	var seasons = data.settings.seasons
	
	if seasons.size()>0:
		seasonName.text = str(seasons[season])
		tabContainer.get_child(0).name = str(seasons[season])
		tabContainer.get_child(0).current_tab = SeasonData.TabManager
		tabContainer.get_child(0).load_setup()

func _on_Home_pressed():
	SceneTransition.change_scene_to_file("res://MGF Scene/UIMenu.tscn")

func _on_Teamselect1_pressed():
	FormationData.isDisable = true
	Global.MGFMode = Global.Season
	FormationData.teamForm = SeasonData.teamA
	FormationData.CanFormation = true
	FormationData.teamFor = 1
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_BtnManager_pressed():
	tabContainer.get_child(0).current_tab = 0

func _on_BtnMarket_pressed():
	tabContainer.get_child(0).current_tab = 3

func _on_BtnNextMatch_pressed():
	SeasonData.find_match()
	tabContainer.get_child(0).nextMatch.load_setup()
	tabContainer.get_child(0).current_tab = 1

func _on_BtnLeague_pressed():
	tabContainer.get_child(0).current_tab = 2

func _on_BtnSettings_pressed():
	tabContainer.get_child(0).current_tab = 4
