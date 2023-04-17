extends TabBar

@onready var playerStats = $PlayerStats
@onready var players = $PlayerStats/Players

@onready var insPlayer = load("res://MGF Scene/Season/PlayerStats.tscn")

@onready var TabManager = get_parent()


func load_setup():
	get_players_stats()


func _on_BtnMarket_pressed():
	TabManager.current_tab = 3

func _on_BtnStartMatch_pressed():
	_on_BtnNextMatch_pressed()
	await get_tree().create_timer(0.5).timeout
	TabManager.nextMatch.go_match()
	

func _on_BtnNextMatch_pressed():
	SeasonData.find_match()
	get_parent().nextMatch.load_setup()
	TabManager.current_tab = 1

func _on_BtnLeague_pressed():
	TabManager.current_tab = 2

func get_players_stats():
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
			ins.get_node("team/team").texture = load(data.teams[int(teamSelect)].icon)
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


func _on_BtnFormation_pressed():
	FormationData.isDisable = false
	var data = GameData.season_load_data()
	var leagueData = data.season
	FormationData.teamForm = leagueData.teamA
	FormationData.teamFor = 1
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")
