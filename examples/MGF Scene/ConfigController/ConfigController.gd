extends Node

@onready var team1s = get_tree().get_nodes_in_group("team1")
@onready var team2s = get_tree().get_nodes_in_group("team2")

@onready var teamAStats = $MainUI/TeamStats/TeamStats/TeamAStats
@onready var teamBStats = $MainUI/TeamStats/TeamStats/TeamBStats

@onready var setGameMode = $MainUI/GameMode/OptionButtonSetGameMode
@onready var setStadium = $MainUI/Stadium/OptionButtonSetStadium
@onready var setTime = $MainUI/Time/OptionButtonSetTime

@onready var btnHome = $MainUI/SetPlay/SetHomeAway

@onready var teamAPar = $TeamASelect/TeamSM/ScrollContainer/CenterContainer/GridContainer
@onready var teamBPar = $TeamBSelect/TeamSM/ScrollContainer/CenterContainer/GridContainer

@onready var teamASe = $MainUI/TeamSelect/TeamA
@onready var teamBSe = $MainUI/TeamSelect/TeamB

@onready var teamAChart = $MainUI/RadarChart/TeamA
@onready var teamBChart = $MainUI/RadarChart/TeamB

@onready var UIteamColorA:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamA.tres")
@onready var UIteamColorB:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamB.tres")

func _ready():
	Global.gameModeCur = 1
	btnHome.text = "Play Home"
	Global.MatchPlay = 1
	GameData.load_game_settings()
	create_teams_ins_select()
	add_items_GameMode()
	add_items_Stadium()
	add_items_Time()
	create_team_ins_stats()
	Settings.set_color(SeasonData.teamA)
	Settings.color_UI(UIteamColorA,Settings.teamColor[Global.teamID1][0],0.5)
	Settings.color_UI(UIteamColorB,Settings.teamColor[Global.teamID2][0],0.5)

func create_teams_ins_select():
	var teamA = teamAPar
	var teamB = teamBPar
	var teamIns = preload("res://MGF Scene/ConfigController/Teamselect.tscn")
	
	if teamA.get_child_count()>0:
		for unit in teamA.get_children():
			unit.queue_free()
	if teamB.get_child_count()>0:
		for unit in teamB.get_children():
			unit.queue_free()
	
	var data = GameData.get_data(GameData.data_path)
	var teamData = data.teams
	
	for i in teamData.size():
		var ins = teamIns.instantiate()
		ins.teamIcon = i
		teamA.add_child(ins)
	for i in teamData.size():
		var ins = teamIns.instantiate()
		ins.teamIcon = i
		teamB.add_child(ins)
	
	for unit in teamA.get_children():
		unit.add_to_group("team1")
	for unit in teamB.get_children():
		unit.add_to_group("team2")
	
	team1s = get_tree().get_nodes_in_group("team1")
	team2s = get_tree().get_nodes_in_group("team2")
	for team1 in team1s:
		team1.connect("pressed",Callable(self,"_on_teamSelectButton").bind(team1))
	for team2 in team2s:
		team2.connect("pressed",Callable(self,"_on_team1SelectButton").bind(team2))

## Get Team 
func create_team_ins_stats():
	GameData.load_teamStats_data(teamAStats,Global.teamID1)
	GameData.load_teamStats_data(teamBStats,Global.teamID2)
	GameData.return_radarStats_data(teamAChart,Global.teamID1)
	GameData.return_radarStats_data(teamBChart,Global.teamID2)

## Set GameMode
func add_items_GameMode():
	if Global.MGFMode != 10:
		Global.gameModeCur = 1
		setGameMode.text = Global.gameModeName[1]
	else:
		Global.gameModeCur = 3
		setGameMode.text = Global.gameModeName[3]

## Set Stadium
func add_items_Stadium():
	setStadium.text = Global.staName[Global.staCur]
#	setStadium.icon = Global.staImg[Global.staCur]

## Set GameTime
func add_items_Time():
	setTime.text = str(Global.time[Global.SetTime]*2)

func _on_teamSelectButton(team1):
	var data = GameData.get_data(GameData.data_path)
	Global.teamID1 = team1.teamIcon
	teamASe.icon = load(data.teams[team1.teamIcon].icon)
	GameData.load_teamStats_data(teamAStats,Global.teamID1)
	GameData.return_radarStats_data(teamAChart,Global.teamID1)
	Settings.color_UI(UIteamColorA,Settings.teamColor[Global.teamID1][0],0.5)

func _on_team1SelectButton(team2):
	var data = GameData.get_data(GameData.data_path)
	Global.teamID2 = team2.teamIcon
	teamBSe.icon = load(data.teams[team2.teamIcon].icon)
	GameData.load_teamStats_data(teamBStats,Global.teamID2)
	GameData.return_radarStats_data(teamBChart,Global.teamID2)
	Settings.color_UI(UIteamColorB,Settings.teamColor[Global.teamID2][0],0.5)

func _on_SetTeamRandom_pressed():
	var data = GameData.get_data(GameData.data_path)
	randomize()
	var random_teamA = randi() % data.teams.size()
	var random_teamB = randi() % data.teams.size()
	teamASe.icon = load(data.teams[random_teamA].icon)
	teamBSe.icon = load(data.teams[random_teamB].icon)
	Global.teamID1 = random_teamA
	Global.teamID2 = random_teamB
	Settings.color_UI(UIteamColorA,Settings.teamColor[Global.teamID1][0],0.5)
	Settings.color_UI(UIteamColorB,Settings.teamColor[Global.teamID2][0],0.5)
	create_team_ins_stats()

func _on_OptionButtonSetTime_button_up():
	var size = Global.time.size()
	if Global.MGFMode != 10:
		size = Global.time.size()-1
	Global.SetTime = (Global.SetTime + 1) % size
	setTime.text = str(Global.time[Global.SetTime]*2)


func _on_SetHomeAway_pressed():
	if Global.MatchPlay == 1:
		btnHome.text = "Play Away"
		Global.MatchPlay = 2
	else:
		btnHome.text = "Play Home"
		Global.MatchPlay = 1

func _on_OptionButtonSetGameMode_pressed():
	if Global.MGFMode != 10:
		Global.optionSelect = 0
		Global.itemSize = range(0,(Global.gameModeName.size()-1))
		$SwipeMenu/ScrollContainer.card_item_instance()
		$SwipeMenu/LabelBase.text = "GameMode"
		$SwipeMenu.show()
		setGameMode.disabled = true

func _on_OptionButtonSetStadium_pressed():
	Global.optionSelect = 1
	Global.itemSize = range(0,Global.staName.size())
	$SwipeMenu/ScrollContainer.card_item_instance()
	$SwipeMenu/LabelBase.text = "Stadium"
	$SwipeMenu.show()
	setStadium.disabled = true
