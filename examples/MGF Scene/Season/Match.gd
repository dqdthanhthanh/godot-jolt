extends Control

var id = 0
var playerA
var playerB

@onready var insPlayer = load("res://MGF Scene/Season/Player.tscn")

func _ready():
	$info.show()

func _on_info_pressed():
	var matchInfo = get_parent().get_parent().get_parent().get_parent().matchInfo
	var playerInfo = matchInfo.get_node("PlayerInfo")
	
	var seasondata = GameData.season_load_data()
	var leagueResults = seasondata.season.leagueResults
	if leagueResults.size() > SeasonData.MatchDay:
		matchInfo.show()
		playerInfo.show()
		var data = leagueResults[SeasonData.MatchDay][id]
		matchInfo.get_node("mainLabel/logoA").texture = $teamA.texture
		matchInfo.get_node("mainLabel/logoB").texture = $teamB.texture

		matchInfo.get_node("mainLabel/goalA").text = str(data[6][0])
		matchInfo.get_node("mainLabel/goalB").text = str(data[6][1])

		matchInfo.get_node("TeamA/ball").text = str(data[1][0])
		matchInfo.get_node("TeamA/shot").text = str(data[2][0] - data[7][0])
		matchInfo.get_node("TeamA/pass").text = str(data[3][0])
		matchInfo.get_node("TeamA/block").text = str(data[4][0])
		matchInfo.get_node("TeamA/miss").text = str(data[7][0])
		matchInfo.get_node("TeamA/force").text = str(data[5][0])

		matchInfo.get_node("TeamB/ball").text = str(data[1][1])
		matchInfo.get_node("TeamB/shot").text = str(data[2][1] - data[7][1])
		matchInfo.get_node("TeamB/pass").text = str(data[3][1])
		matchInfo.get_node("TeamB/block").text = str(data[4][1])
		matchInfo.get_node("TeamB/miss").text = str(data[7][1])
		matchInfo.get_node("TeamB/force").text = str(data[5][1])
		
#		info.save_player_match(id)
		playerA = playerInfo.get_node("%PlayerA")
		playerB = playerInfo.get_node("%PlayerB")
		
		insPlayer = load("res://MGF Scene/Season/Player.tscn")
		var playerData = seasondata.season.playerResults
		var matchR = SeasonData.MatchDay
		var matchID = playerData[matchR][id]
		
		if playerA.get_child_count() > 0:
			for i in playerA.get_children():
				i.queue_free()
			for i in playerB.get_children():
				i.queue_free()

		var playerID = matchID[0]
		for i in playerID.size():
			var ins = insPlayer.instantiate()
			playerA.add_child(ins)
			if i > 0:
				var playerName = seasondata.players[playerID[i][0]].Name
				
				ins.get_node("name").text = playerName
				ins.get_node("goal").text = str(playerID[i][3])
				ins.get_node("assits").text = str(playerID[i][4])
				ins.get_node("shots").text = str(playerID[i][5])
				ins.get_node("passes").text = str(playerID[i][6])
				ins.get_node("blocks").text = str(playerID[i][9])
				ins.get_node("saves").text = str("%.0f" %float(playerID[i][11]))
	#			ins.get_node("saves").text = str(playerID[i][6])
				ins.get_node("pos").text = str("%.1f" % float(playerID[i][2]))
		
		playerID = matchID[1]
		for i in playerID.size():
			var ins = insPlayer.instantiate()
			playerB.add_child(ins)
			if i > 0:
				var playerName = seasondata.players[playerID[i][0]].Name
				
				ins.get_node("name").text = playerName
				ins.get_node("goal").text = str(playerID[i][3])
				ins.get_node("assits").text = str(playerID[i][4])
				ins.get_node("shots").text = str(playerID[i][5])
				ins.get_node("passes").text = str(playerID[i][6])
				ins.get_node("blocks").text = str(playerID[i][9])
				ins.get_node("saves").text = str("%.0f" %float(playerID[i][11]))
				ins.get_node("pos").text = str("%.1f" % float(playerID[i][2]))
	
	else:
		matchInfo.show()
		playerInfo.hide()
		matchInfo.get_node("mainLabel/logoA").texture = $teamA.texture
		matchInfo.get_node("mainLabel/logoB").texture = $teamB.texture

		matchInfo.get_node("mainLabel/goalA").text = "0"
		matchInfo.get_node("mainLabel/goalB").text = "0"

		matchInfo.get_node("TeamA/ball").text = "0"
		matchInfo.get_node("TeamA/shot").text ="0"
		matchInfo.get_node("TeamA/pass").text = "0"
		matchInfo.get_node("TeamA/block").text = "0"
		matchInfo.get_node("TeamA/miss").text = "0"
		matchInfo.get_node("TeamA/force").text = "0"

		matchInfo.get_node("TeamB/ball").text = "0"
		matchInfo.get_node("TeamB/shot").text = "0"
		matchInfo.get_node("TeamB/pass").text = "0"
		matchInfo.get_node("TeamB/pass").text = "0"
		matchInfo.get_node("TeamB/block").text = "0"
		matchInfo.get_node("TeamB/force").text = "0"
