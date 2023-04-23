extends Control

@onready var playerStats: = $PlayerStats
@onready var players: = $PlayerStats/Players

@onready var insPlayer: = load("res://MGF Scene/Season/PlayerStats.tscn")

@onready var TabManager: = get_parent()
@onready var TabControl: = get_parent().get_parent().get_node("MainBtn")



func load_setup() -> void:
	Global.gameModeCur = 1
	await get_tree().create_timer(Global.btntime).timeout
	get_players_stats()

func _on_BtnStartMatch_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	SeasonData.find_match()
	TabManager.nextMatch.load_setup()
	TabControl.tab_select(1)
	TabManager.nextMatch.go_match()

func get_players_stats() -> void:
	if players.get_child_count() > 0:
		for i in players.get_children():
			i.queue_free()
		for i in players.get_children():
			i.queue_free()
	var data = GameData.season_load_data()
	var teamSelect = data.season.teamA
	var teamData = data.teams[int(teamSelect)].Fid
	var playerData = data.players

	for i in teamData.size()+1:
		var id = teamData[i-1]

		var ins = insPlayer.instantiate()
		players.add_child(ins)
		
		if i > 0:
			ins.get_node("name").text = str(playerData[id].PlayerID) + " " + str(playerData[id].Name)
			ins.get_node("team/icon").texture = Team.load_team_icon(data.teams[int(teamSelect)].icon)
			ins.get_node("team").text = ""
			if int(playerData[id].Season[0]) > 0:
				ins.get_node("pos").text = str("%.1f" % (float(playerData[id].Season[1])/float(playerData[id].Season[0])))
				ins.get_node("saves").text = str("%.0f" % (float(playerData[id].Season[10])/float(playerData[id].Season[0])))
			else:
				ins.get_node("saves").text = "0"
			ins.get_node("goal").text = str(playerData[id].Season[2])
			ins.get_node("assits").text = str(playerData[id].Season[3])
			ins.get_node("shots").text = str(playerData[id].Season[4])
			ins.get_node("passes").text = str(playerData[id].Season[5])
			ins.get_node("blocks").text = str(playerData[id].Season[8])

class MyCustomSorter:
	static func sort_ascending(a, b):
		if int(a.Season[2]) > int(b.Season[2]):
			return true
		return false

	static func sort_reset(a, b):
		if int(a.team) < int(b.team):
			return true
		return false

	static func customComparison(a, b):
		if typeof(a) == typeof(b):
			return a > b
		else:
			return typeof(a) < typeof(b)

func _on_BtnFormation_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	FormationData.CanFormation = true
	FormationData.isDisable = false
	var data = GameData.season_load_data()
	var leagueData = data.season
	FormationData.teamForm = leagueData.teamA
	FormationData.teamFor = 1
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _on_BtnTrainning_pressed() -> void:
	Global.gameModeCur = 2
	SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")

func _exit_tree():
	queue_free()
