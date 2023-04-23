extends Control

var index:int = 0

@onready var bxh: = get_parent().get_node("NextMatch/League/VScrollBarBXH/VBoxContainer")
@onready var bxhMG: = get_parent().get_node("SeasonManager/League/VScrollBarBXH/VBoxContainer")

@onready var playerStats: = $Players/PlayerStats
@onready var players: = $Players/PlayerStats/Players
@onready var tab: = $TabBtns
@onready var tabstt: = $Players/MainBtn

func load_setup() -> void:
	get_players_stats($TabBtns.current_tab)
	create_league_table(bxh)
	create_league_table(bxhMG,false)

func create_league_table(parent = bxh,value = true) -> void:
	var insTeamIndex: = load("res://MGF Scene/Season/TeamIndex.tscn")
	
	##Create League Table
	var data = GameData.season_load_data()
	var teamData = data.teams
	
	if parent.get_child_count()>0:
		for i in parent.get_child_count():
			if i > 0:
				parent.get_child(i).queue_free()
	
	if value == true:
		teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_goal"))
		teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_point"))
		for n in range(teamData.size()):
			n+=1
			var team = insTeamIndex.instantiate()
			parent.add_child(team)
			if SeasonData.teamA == teamData[n-1].id:
				index = n
			team.index = n
			teamData[n-1].index = n
			team.id = teamData[n-1].id
			team.teamName = teamData[n-1].name
			team.teamIcon = Team.load_team_icon(teamData[n-1].icon)
			
			team.matchTime = teamData[n-1].statS[0]
			team.matchW = teamData[n-1].statS[2]
			team.matchD = teamData[n-1].statS[3]
			team.matchL = teamData[n-1].statS[4]
			
			team.point = teamData[n-1].statS[1]
			team.pointW = teamData[n-1].statS[5]
			team.pointL = teamData[n-1].statS[6]
			team.cup = int(teamData[n-1].statS[5])-int(teamData[n-1].statS[6])
			team.get_team_data()
	else:
		teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_id"))
		var teamSelect = teamData[SeasonData.teamA]
		var team = insTeamIndex.instantiate()
		parent.add_child(team)
		team.index = index
		team.id = SeasonData.teamA
		team.teamName = teamSelect.name
		team.teamIcon = Team.load_team_icon(teamSelect.icon)
		
		team.matchTime = teamSelect.statS[0]
		team.matchW = teamSelect.statS[2]
		team.matchD = teamSelect.statS[3]
		team.matchL = teamSelect.statS[4]
		
		team.point = teamSelect.statS[1]
		team.pointW = teamSelect.statS[5]
		team.pointL = teamSelect.statS[6]
		team.cup = int(teamSelect.statS[5])-int(teamSelect.statS[6])
		team.get_team_data()

func _on_TabBtns_on_tab_select(id):
	await get_tree().create_timer(Global.btntime).timeout
	get_players_stats(id)

func _on_MainBtn_on_tab_select(id):
	await get_tree().create_timer(Global.btntime).timeout
	get_players_stats(tab.current_tab)

func get_players_stats(value:int) -> void:
	var insPlayer: = load("res://MGF Scene/Season/PlayerStats.tscn")
	
	if players.get_child_count() > 0:
		for i in players.get_children():
			i.queue_free()
		for i in players.get_children():
			i.queue_free()
	var data = GameData.season_load_data()
	var playerData = data.players
	playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
	match value:
		0:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
		1:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_goals"))
		2:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_assits"))
		3:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_shots"))
		4:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_passes"))
		5:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_defends"))
		6:
			playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_saves"))
	
	if value != 7:
		var sizeMax:float = (playerData.size()*1.0/12)
		var size:int = int(sizeMax)
		var Max:int
		var MinSize:int = tabstt.current_tab*12
		var MaxSize:int = (tabstt.current_tab+1)*12+1
		if sizeMax > size:
			Max = size + 1
		if MaxSize > playerData.size()+1:
			MaxSize = playerData.size()+1
		tabstt.create_btn(Max)
		
#		for i in playerData.size()+1:
		for i in range(MinSize,MaxSize):
			var player = playerData[i-1]
			var ins = insPlayer.instantiate()
			players.add_child(ins)
			ins.get_node("pos").text = "P"
			if i > 0:
				ins.get_node("name").text = str(player.PlayerID) + " " +str(player.Name)
				if ins.get_node("team/icon").visible == true:
					ins.get_node("team/icon").texture = Team.load_team_icon(data.teams[int(player.Team[0])].icon)
				ins.get_node("team").text = ""
				ins.get_node("pos").text = str(player.Season[0])
				if int(player.Season[0]) > 0:
					ins.get_node("pos").text = str("%.1f" % (float(player.Season[1])/float(player.Season[0])))
					ins.get_node("saves").text = str("%.0f" % (float(player.Season[10])/float(player.Season[0])))
				else:
					ins.get_node("saves").text = "0"
		#			ins.get_node("pos").text = str(float(player.Season[1]))
		#		ins.get_node("pos").text = str(player.Season[0])
		#		ins.get_node("pos").text = str(float(player.Season[1]))
				ins.get_node("goal").text = str(player.Season[2])
				ins.get_node("assits").text = str(player.Season[3])
				ins.get_node("shots").text = str(player.Season[4])
				ins.get_node("passes").text = str(player.Season[5])
				ins.get_node("blocks").text = str(player.Season[8])
	#			ins.get_node("saves").text = str(player.Season[9])
	#			ins.get_node("saves").text = str(player.Season[10])
				await get_tree().create_timer(0).timeout
	
	## Best Team
	elif value == 7:
		tabstt.create_btn(0)
		for i in 8:
			if i == 0:
				var ins = insPlayer.instantiate()
				players.add_child(ins)
				ins.get_node("pos").text = "P"
			elif i == 1:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_gk"))
				find_best_player(insPlayer,data,playerData)
			elif i == 2:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_cb"))
				find_best_player(insPlayer,data,playerData)
			elif i == 3:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_rb"))
				find_best_player(insPlayer,data,playerData)
			elif i == 4:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_lb"))
				find_best_player(insPlayer,data,playerData)
			elif i == 5:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_cm"))
				find_best_player(insPlayer,data,playerData)
			elif i == 6:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_rf"))
				find_best_player(insPlayer,data,playerData)
			elif i == 7:
				playerData.sort_custom(Callable(MyCustomSorter, "sort_ascending_player_points"))
				playerData.sort_custom(Callable(MyCustomSorter, "sort_lf"))
				find_best_player(insPlayer,data,playerData)

func find_best_player(insPlayer,data,playerData) -> void:
	var ins = insPlayer.instantiate()
	players.add_child(ins)
	
	ins.get_node("name").text = str(playerData[0].PlayerID) + " " +str(playerData[0].Name)
	if ins.get_node("team/icon").visible == true:
		ins.get_node("team/icon").texture = Team.load_team_icon(data.teams[int(playerData[0].Team[0])].icon)
	ins.get_node("team").text = ""
	ins.get_node("pos").text = str(playerData[0].Season[0])
	if int(playerData[0].Season[0]) > 0:
		ins.get_node("saves").text = str("%.0f" % (float(playerData[0].Season[10])/float(playerData[0].Season[0])))
		ins.get_node("pos").text = str("%.1f" % (float(playerData[0].Season[1])/float(playerData[0].Season[0])))
	ins.get_node("goal").text = str(playerData[0].Season[2])
	ins.get_node("assits").text = str(playerData[0].Season[3])
	ins.get_node("shots").text = str(playerData[0].Season[4])
	ins.get_node("passes").text = str(playerData[0].Season[5])
	ins.get_node("blocks").text = str(playerData[0].Season[8])

class MyCustomSorter:
	static func sort_ascending_id(a, b):
		if int(a.id) < int(b.id):
			return true
		return false
	static func sort_ascending_point(a, b):
		if int(a.statS[1]) > int(b.statS[1]):
			return true
		return false

	static func sort_ascending_goal(a, b):
		if int(a.statS[5])-int(a.statS[6]) > int(b.statS[5])-int(b.statS[6]):
			return true
		return false
	
	static func sort_gk(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "GK":
				return true
		return false

	static func sort_cb(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "CB":
				return true
		return false

	static func sort_rb(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "RB":
				return true
		return false

	static func sort_lb(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "LB":
				return true
		return false

	static func sort_cm(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "CM":
				return true
		return false

	static func sort_rf(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "RF":
				return true
		return false

	static func sort_lf(a,b):
		if float(a.Season[1]) > float(b.Season[1]):
			if a.Team[1] == "LF":
				return true
		return false

	static func sort_ascending_player_points(a, b):
		if float(a.Season[1]/(a.Season[0]+1)) > float(b.Season[1]/(b.Season[0]+1)):
			return true
		return false

	static func sort_ascending_player_goals(a, b):
		if int(a.Season[2]) > int(b.Season[2]):
			return true
		return false

	static func sort_ascending_player_assits(a, b):
		if int(a.Season[3]) > int(b.Season[3]):
			return true
		return false

	static func sort_ascending_player_shots(a, b):
		if int(a.Season[4]) > int(b.Season[5]):
			return true
		return false

	static func sort_ascending_player_passes(a, b):
		if int(a.Season[5]) > int(b.Season[5]):
			return true
		return false

	static func sort_ascending_player_defends(a, b):
		if int(a.Season[8]) > int(b.Season[8]):
			return true
		return false

	static func sort_ascending_player_saves(a, b):
		if int(a.Season[10]) > int(b.Season[10]):
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

func _exit_tree():
	queue_free()
