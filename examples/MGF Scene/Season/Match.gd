extends Control

var id:int = 0
var team:Array = [0,0]
var playerA
var playerB

@export var type:int = 0

@onready var insPlayer = load("res://MGF Scene/Season/Player.tscn")

func _ready() -> void:
	$info.show()

func _on_info_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	var matchInfo
	if type == 0:
		matchInfo = get_parent().get_parent().get_parent().get_parent().matchInfo
	else:
		matchInfo = get_parent().get_parent().get_parent().get_parent().get_node("MatchInfo")
	var playerInfo = matchInfo.get_node("PlayerInfo")
	
	var seasondata = GameData.season_load_data()
	var teamData = seasondata.teams
	var leagueResults = seasondata.leagueResults
	
	matchInfo.get_node("Panel/TeamName").show()
	matchInfo.get_node("Panel/TeamName/A").text = teamData[team[0]].fullName
	matchInfo.get_node("Panel/TeamName/B").text = teamData[team[1]].fullName
	
	if leagueResults.size() > SeasonData.MatchDay:
		matchInfo.show()
		playerInfo.show()
		var data = leagueResults[SeasonData.MatchDay][id]
#		print(data)
		
		matchInfo.get_node("mainLabel/logoA").texture = $Main/teamA.texture
		matchInfo.get_node("mainLabel/logoB").texture = $Main/teamB.texture

		matchInfo.get_node("mainLabel/goalA").text = str(data.match[1][0])
		matchInfo.get_node("mainLabel/goalB").text = str(data.match[1][1])

		matchInfo.get_node("TeamA/ball").text = str(data.match[2][0])
		matchInfo.get_node("TeamA/shot").text = str(data.match[3][0] - data.match[6][0])
		matchInfo.get_node("TeamA/pass").text = str(data.match[4][0])
		matchInfo.get_node("TeamA/block").text = str(data.match[5][0])
		matchInfo.get_node("TeamA/miss").text = str(data.match[6][0])
		matchInfo.get_node("TeamA/force").text = str(data.match[7][0])

		matchInfo.get_node("TeamB/ball").text = str(data.match[2][1])
		matchInfo.get_node("TeamB/shot").text = str(data.match[3][1] - data.match[6][1])
		matchInfo.get_node("TeamB/pass").text = str(data.match[4][1])
		matchInfo.get_node("TeamB/block").text = str(data.match[5][1])
		matchInfo.get_node("TeamB/miss").text = str(data.match[6][1])
		matchInfo.get_node("TeamB/force").text = str(data.match[7][1])
		
#		info.save_player_match(id)
		playerA = playerInfo.get_node("PlayerA/Player")
		playerB = playerInfo.get_node("PlayerB/Player")
		
		insPlayer = load("res://MGF Scene/Season/PlayerStats.tscn")
		var playerData = seasondata.leagueResults
		var matchR = SeasonData.MatchDay
		var matchID = playerData[matchR][id]
		
		if playerA.get_child_count() > 0:
			for i in playerA.get_children():
				i.queue_free()
			for i in playerB.get_children():
				i.queue_free()

		var playerID = matchID.player[0]
		for i in playerID.size()+1:
			var ins = insPlayer.instantiate()
			playerA.add_child(ins)
			player_ins(i,ins,seasondata,playerID)
		
		playerID = matchID.player[1]
		for i in playerID.size()+1:
			var ins = insPlayer.instantiate()
			playerB.add_child(ins)
			player_ins(i,ins,seasondata,playerID)
	
	else:
		matchInfo.show()
		playerInfo.hide()
		matchInfo.get_node("mainLabel/logoA").texture = $Main/teamA.texture
		matchInfo.get_node("mainLabel/logoB").texture = $Main/teamB.texture

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
		matchInfo.get_node("TeamB/miss").text = "0"
		matchInfo.get_node("TeamB/force").text = "0"


func player_ins(i,ins,seasondata,playerID) -> void:
	if i == 0:
		ins.get_node("team").hide()
		ins.get_node("player/icon").hide()
		ins.get_node("player").show()
		ins.get_node("player").text = "Icon"
	elif i > 0:
		var a:int = i-1
		var playerData = seasondata.players[playerID[a][0]]
		
		ins.get_node("team").hide()
		ins.get_node("player").show()
		ins.get_node("player").text = ""
		ins.get_node("player/icon").texture = Player.load_icon(playerData.Icon)
		ins.get_node("name").text = playerData.Name
		ins.get_node("goal").text = str(playerID[a][3])
		ins.get_node("assits").text = str(playerID[a][4])
		ins.get_node("shots").text = str(playerID[a][5])
		ins.get_node("passes").text = str(playerID[a][6])
		ins.get_node("blocks").text = str(playerID[a][9])
		ins.get_node("saves").text = str("%.0f" %float(playerID[a][11]))
#		ins.get_node("saves").text = str(playerID[a][6])
		ins.get_node("pos").text = str("%.1f" % float(playerID[a][2]))

func _exit_tree():
	queue_free()
