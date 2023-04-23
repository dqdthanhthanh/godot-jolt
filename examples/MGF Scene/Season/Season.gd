extends Control

@onready var team1s
@onready var teamAStats: = $TeamSelect/TeamStats/TeamAStats
@onready var teamSM: = $TeamSelect/TeamSM
@onready var teamIcon: = $TeamSelect/Teamselect1
@onready var ssMatch: = $SeasonMatch
@onready var mainBtn: = $MainBtn
@onready var disable: = $Disable

@onready var seasonMain: = $SeasonMain
@onready var seasonName: = $SeasonMain/LabelBase
@onready var SeasonTab: = $SeasonTab

var data = GameData.season_load_data()

func _ready() -> void:
	mainBtn.current_tab = SeasonData.TabManager
	GlobalTheme.set_color(SeasonData.teamA)
	$MatchInfo.hide()
	get_set_season_name()
	Global.MGFMode = Global.Season
	check_league_data()
	GameData.player_data_synchronization()

func create_teams_ins() -> void:
	var teamIns = load("res://MGF Scene/QuickMatch/Teamselect.tscn")
	
	teamSM.create_team_list()
	
	for unit in teamSM.group.get_children():
		unit.add_to_group("team1")
	team1s = get_tree().get_nodes_in_group("team1")
	for team1 in team1s:
		team1.connect("pressed", Callable(self, "_on_teamSelectButton").bind(team1.id))

func _on_teamSelectButton(value) -> void:
	SeasonData.teamA = int(value)
	var teamData = data.teams
	teamIcon.update_data(teamData[value])
	GameData.load_teamStats_data(teamAStats,value)
	GameData.return_radarStats_data($TeamSelect/RadarChartStats,value)
	GlobalTheme.set_color(SeasonData.teamA)

func _on_ButtonTeamApply_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	var time = Time.get_datetime_dict_from_system()
	var year = time["year"]
	
	var ssbase = GameData.get_data(GameData.data_path)
	var base = GameData.get_data(GameData.setting_data_path)
	ssbase.season.active = true
	base.seasons.append(year+base.seasons.size())
	base.season = base.seasons.size()-1
	GameData.save_data(GameData.data_path,ssbase)
	GameData.save_data(GameData.setting_data_path,base)
	
	var file_data:FileData = FileData.new()
	
	GameData.save_data(GameData.season_get_file_path(),file_data.ss)
	
#	print(GameData.season_get_file_path())
	var data = GameData.season_load_data()
	var seasonData = data.season
	seasonData.name = year + base.seasons.size()-1
	seasonData.teamA = SeasonData.teamA

	GameData.save_data(GameData.season_get_file_path(),data)
	
	var teamName = SeasonData.get_team_select_name()
	Notification.create_achi(1,"New Season Ever Achievement",["First time playing season mode"])
	Notification.create_noti("New Season "+ str(seasonData.name),[teamName + ": New Season " + str(seasonData.name) + " begin"])
	Account.notifi_news()
	SeasonData.TabManager = 0
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Notification.push_noti(2,"New Season " +str(seasonData.name))

func check_league_data() -> void:
	var data = GameData.get_data(GameData.data_path)
	var teamData = data.teams
	var seasonData = data.season
	if seasonData.active == true:
		$TeamSelect.hide()
		seasonMain.show()
		mainBtn.show()
		SeasonTab.show()
	else:
		create_teams_ins()
		teamIcon.icon = Team.load_team_icon(teamData[int(SeasonData.teamA)].icon)
		GameData.load_teamStats_data(teamAStats,int(SeasonData.teamA))
		GameData.return_radarStats_data($TeamSelect/RadarChartStats,int(SeasonData.teamA))
		$TeamSelect.show()
		seasonMain.hide()
		mainBtn.hide()
		SeasonTab.hide()

func get_set_season_name() -> void:
	var data = GameData.get_data(GameData.setting_data_path)
	var season = data.season
	var seasons = data.seasons
	
	if seasons.size()>0:
		seasonName.text = str(seasons[season])
		SeasonTab.load_setup()

func _on_Home_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	SceneTransition.change_scene_to_file("res://MGF Scene/MainMenu.tscn")

func _on_Teamselect1_pressed() -> void:
	FormationData.isDisable = true
	Global.MGFMode = Global.Season
	FormationData.teamForm = SeasonData.teamA
	FormationData.teamFor = 1
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _exit_tree():
	queue_free()

func _on_MainBtn_on_tab_select(id):
	await get_tree().create_timer(Global.btntime).timeout
	SeasonData.TabManager = id
	if id == 1:
		SeasonData.find_match()
		SeasonTab.nextMatch.load_setup()
