extends Control


@onready var teamAStats: = $MainUI/TeamStats/TeamStats/TeamAStats
@onready var teamBStats: = $MainUI/TeamStats/TeamStats/TeamBStats

@onready var setGameMode: = $MainUI/GameMode/OptionButtonSetGameMode
@onready var setStadium: = $MainUI/Stadium/OptionButtonSetStadium
@onready var setTime: = $MainUI/Time/OptionButtonSetTime

@onready var btnMatchPlay: = $MainUI/SetPlay/SetHomeAway

@onready var teamA: = $TeamASelect/TeamList
@onready var teamB: = $TeamBSelect/TeamList

@onready var teamASe: = $MainUI/TeamSelect/TeamA
@onready var teamBSe: = $MainUI/TeamSelect/TeamB

@onready var matchOptions: = $MatchOptions

var UIteamColorA:StyleBoxFlat = load("res://Assets2D/Theme/btnUITeamA.tres")
var UIteamColorB:StyleBoxFlat = load("res://Assets2D/Theme/btnUITeamB.tres")

var data:Dictionary

func _ready() -> void:
	data = GameData.get_data(GameData.data_path)
	btnMatchPlay.text = "Play Home"
	Global.MatchPlay = 1
	add_items_GameMode()
	add_items_Stadium()
	add_items_Time()
	
	GlobalTheme.set_color(SeasonData.teamA)
	GlobalTheme.color_UI(UIteamColorA,GlobalTheme.teamColor[Global.teamID1][0],0.5)
	GlobalTheme.color_UI(UIteamColorB,GlobalTheme.teamColor[Global.teamID2][0],0.5)
	
	teamASe.update_data(data.teams[Global.teamID1])
	teamBSe.update_data(data.teams[Global.teamID2])
	
	create_team_ins_stats()
	create_teams_ins_select()

## Get Team 
func create_team_ins_stats() -> void:
	GameData.load_teamStats_data(teamAStats,Global.teamID1)
	GameData.load_teamStats_data(teamBStats,Global.teamID2)

func create_teams_ins_select() -> void:
	teamA.create_team_list()
	teamB.create_team_list()
	
	await get_tree().create_timer(Global.btntime).timeout
	
	for unit in teamA.group.get_children():
		unit.connect("pressed", Callable(self, "_on_team_select_pressed").bind(1,unit.id))
		
	for unit in teamB.group.get_children():
		unit.connect("pressed", Callable(self, "_on_team_select_pressed").bind(2,unit.id))

func _on_team_select_pressed(team,id) -> void:
	if team == 1:
		Global.teamID1 = id
		teamASe.update_data(data.teams[id])
		GameData.load_teamStats_data(teamAStats,Global.teamID1)
		GlobalTheme.color_UI(UIteamColorA,GlobalTheme.teamColor[Global.teamID1][0],0.5)
	else:
		Global.teamID2 = id
		teamBSe.update_data(data.teams[id])
		GameData.load_teamStats_data(teamBStats,Global.teamID2)
		GlobalTheme.color_UI(UIteamColorB,GlobalTheme.teamColor[Global.teamID2][0],0.5)

func _on_SetTeamRandom_pressed() -> void:
	randomize()
	var random_teamA = randi() % data.teams.size()
	var random_teamB = randi() % data.teams.size()
	
	teamASe.update_data(data.teams[random_teamA])
	teamBSe.update_data(data.teams[random_teamB])
	
	Global.teamID1 = random_teamA
	Global.teamID2 = random_teamB
	GlobalTheme.color_UI(UIteamColorA,GlobalTheme.teamColor[Global.teamID1][0],0.5)
	GlobalTheme.color_UI(UIteamColorB,GlobalTheme.teamColor[Global.teamID2][0],0.5)
	create_team_ins_stats()

## Set GameMode
func add_items_GameMode() -> void:
	setGameMode.text = Global.gameModeList[Global.gameModeCur].name

## Set Stadium
func add_items_Stadium() -> void:
	setStadium.text = "MGF Stadium"
#	setStadium.text = Global.staList[Global.staCur].name
#	setStadium.icon = load(Global.staImg[Global.staCur])

## Set GameTime
func add_items_Time() -> void:
	setTime.text = str(Global.timeList[Global.timeCur].time*2)

func _on_SetHomeAway_pressed() -> void:
	if Global.MatchPlay == 1:
		btnMatchPlay.text = "Play Away"
		Global.MatchPlay = 2
	else:
		btnMatchPlay.text = "Play Home"
		Global.MatchPlay = 1

func _on_OptionButtonSetGameMode_pressed() -> void:
	matchOptions.load_set_up()

func _on_OptionButtonSetStadium_pressed() -> void:
	SceneTransition.transition()

func _on_OptionButtonSetTime_pressed() -> void:
	pass
#	var size = Global.timeList.size()
#	if Global.MGFMode != 10:
#		size = Global.timeList.size()-1
#	Global.timeCur = (Global.timeCur + 1) % size
#	setTime.text = String(Global.timeList[Global.timeCur].time*2)

func _on_StartGameButton_pressed() -> void:
	if Global.gameModeCur == 4:
		GameData.play_game_guide(true)
	else:
		FormationData.teamFor = Global.MatchPlay
		GameData.save_game_settings()
	# 	warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn","match")
#		get_tree().change_scene_to_file("res://MGF Scene/MainGame.tscn")

func _exit_tree():
	queue_free()
