extends Control

@onready var Round: = $UI/Round/Round
@onready var menu: = get_parent()

@onready var teamAStats: = $UI/Main/TeamStats/TeamStats/TeamAStats
@onready var teamBStats: = $UI/Main/TeamStats/TeamStats/TeamBStats

func _ready():
	if Global.MGFMode == Global.SeasonMatch:
		load_setup()
	else:
		hide()

func load_setup(value:bool = false,type:int = 0) -> void:
	$UI/Main/Teamselect1._ready()
	$UI/Main/Teamselect2._ready()
	var data
	if value == false:
		var bg = load("res://MGF Scene/Setup/BGSetup.tscn").instantiate()
		$BG.add_child(bg)
		Round.text = "Round " + str(SeasonData.MatchDay+1)
		data = GameData.season_load_data()
		if SeasonData.MatchPlay == 1:
			Global.teamID1 = SeasonData.teamA
			Global.teamID2 = SeasonData.teamB
		else:
			Global.teamID1 = SeasonData.teamB
			Global.teamID2 = SeasonData.teamA
	else:
		$UI/Main/WeatherUI.show()
		$Disable.show()
		Round.hide()
		$UI/Main/ButtonStatGame.hide()
		$Home.hide()
		data = GameData.formation_load_data()
	
	if type != 0:
		var bg = load("res://MGF Scene/Setup/BGSetup.tscn").instantiate()
		$BG.add_child(bg)
		Round.text = Global.gameModeList[Global.gameModeCur].name
		$UI/Round.hide()
	
	var teamData = data.teams
	$UI/Main/TeamName/A.text = teamData[Global.teamID1].fullName
	$UI/Main/TeamName/B.text = teamData[Global.teamID2].fullName
	GameData.load_teamStats_data(teamAStats,int(Global.teamID1))
	GameData.load_teamStats_data(teamBStats,int(Global.teamID2))
	$UI/Main/FormationMatch.set_up()
	show()

func _on_Teamselect1_pressed() -> void:
	Global.MGFMode = Global.SeasonMatch
	if SeasonData.check_season_mode() == true:
		SeasonData.check_team_select(Global.teamID1)
	FormationData.teamForm = Global.teamID1
	FormationData.teamFor = 1
	GlobalTheme.set_color(FormationData.teamForm)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_Teamselect2_pressed() -> void:
	Global.MGFMode = Global.SeasonMatch
	if SeasonData.check_season_mode() == true:
		SeasonData.check_team_select(Global.teamID2)
	FormationData.teamForm = Global.teamID2
	FormationData.teamFor = 2
	GlobalTheme.set_color(FormationData.teamForm)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_ButtonStatGame_pressed() -> void:
	Global.MGFMode = Global.SeasonMatch
	await get_tree().create_timer(Global.btntime).timeout
	SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn","match")

func _on_Home_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	SeasonData.TabManager = 1
	hide()

func _exit_tree():
	queue_free()
