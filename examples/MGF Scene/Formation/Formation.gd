extends Control

@onready var disable = $Disable

func _ready():
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		disabled(FormationData.isDisable)
#		if disable.visible == true:
#			Messenger.push_notification(0,'Team Formation Preview')
	
	var data = GameData.formation_load_data()
	var teamData = data.teams[FormationData.teamForm].Fid[0]
	
	GameData.return_radarStats_player($ItemList/RadarChartStats,teamData)
	$GroupSlots/slot1.player_data_preview(teamData)
	
	$PanelPlayerData.hide()

func disabled(value):
	disable.visible = value
