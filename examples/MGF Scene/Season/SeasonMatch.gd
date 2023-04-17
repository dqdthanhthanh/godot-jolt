extends Control

@onready var setGameMode = $OptionButtonSetGameMode
@onready var setStadium = $OptionButtonSetStadium
@onready var menu = get_parent()

@onready var teamAStats = $TeamStatsA/TeamAStats
@onready var teamBStats = $TeamStatsB/TeamAStats

@onready var teamAChart = $TeamStatsA/RadarChartStats
@onready var teamBChart = $TeamStatsB/RadarChartStats

var teamA
var teamB

func _ready():
	if Global.MGFMode == Global.SeasonMatch:
		load_setup()
	else:
		hide()

func load_setup():
	$Teamselect1._ready()
	$Teamselect2._ready()
	show()
	Global.MGFMode = Global.Season
	add_items_GameMode()
	if SeasonData.MatchPlay == 1:
		teamA = SeasonData.teamA
		teamB = SeasonData.teamB
	else:
		teamA = SeasonData.teamB
		teamB = SeasonData.teamA
	GameData.load_teamStats_data(teamAStats,int(teamA))
	GameData.return_radarStats_data(teamAChart,int(teamA))
	GameData.load_teamStats_data(teamBStats,int(teamB))
	GameData.return_radarStats_data(teamBChart,int(teamB))

func _on_Home_pressed():
	Global.MGFMode = Global.Season
	SeasonData.TabManager = 1
	hide()

func _on_ButtonTeamApply_pressed():
	var nextMatch = menu.tabContainer.get_child(0).nextMatch
	nextMatch.create_match_data(1)

func _on_Teamselect1_pressed():
	SeasonData.check_team_select(teamA)
	Global.MGFMode = Global.SeasonMatch
	FormationData.teamForm = Global.teamID1
	FormationData.CanFormation = true
	FormationData.teamFor = 1
	Settings.set_color(FormationData.teamForm)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_Teamselect2_pressed():
	SeasonData.check_team_select(teamB)
	Global.MGFMode = Global.SeasonMatch
	FormationData.teamForm = Global.teamID2
	FormationData.CanFormation = true
	FormationData.teamFor = 2
	Settings.set_color(FormationData.teamForm)
# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

## Set GameMode
func add_items_GameMode():
	Global.gameModeCur = 1
	setGameMode.text = Global.gameModeName[1]

func _on_OptionButtonSetGameMode_button_up():
	if Global.MGFMode != 10:
		Global.optionSelect = 0
		Global.itemSize = range(0,(Global.gameModeName.size()-3))
		$SwipeMenu/ScrollContainer.card_item_instance()
		$SwipeMenu/LabelBase.text = "GameMode"
		$SwipeMenu.show()


func _on_OptionButtonSetStadium_pressed():
	Global.optionSelect = 1
	Global.itemSize = range(0,Global.staName.size())
	$SwipeMenu/ScrollContainer.card_item_instance()
	$SwipeMenu/LabelBase.text = "Stadium"
	$SwipeMenu.show()
	setStadium.disabled = true
