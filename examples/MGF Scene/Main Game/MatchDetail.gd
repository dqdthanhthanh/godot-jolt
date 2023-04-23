extends Control

@onready var TabControl: = $MainBtn
@onready var tabs: = $TabBar
@onready var time: = $TabBar/Stats/Menu/LabelBase

@onready var main: = $TabBar/Stats/MatchInfo/mainLabel
@onready var playerTeamA: = $TabBar/Stats/MatchInfo/PlayerInfo/PlayerA/Player
@onready var playerTeamB: = $TabBar/Stats/MatchInfo/PlayerInfo/PlayerB/Player

@onready var teamName: = $TabBar/Stats/MatchInfo/TeamName

@onready var teamA: = $TabBar/Stats/MatchInfo/TeamA
@onready var teamB: = $TabBar/Stats/MatchInfo/TeamB

@onready var goalA: = $TabBar/Stats/GoalA/Item
@onready var goalB: = $TabBar/Stats/GoalB/Item

@onready var btnClose: = $TabBar/Stats/ButtonClose
@onready var btnHome: = $TabBar/Stats/ButtonHome

@onready var playerGoals: = preload("res://MGF Scene/Main Game/PlayerGoals.tscn")

func set_up() -> void:
	$TabBar/Info/MatchReady.load_setup(true)

func update_player_stats(team,player,child,data,save:bool = false) -> void:
	var obj
	if child > 0:
		if team == 1:
			obj = playerTeamA
			teamName.get_node("A").text = player.teamData.fullName
		else:
			obj = playerTeamB
			teamName.get_node("B").text = player.teamData.fullName
		
		obj.get_child(0).get_node("team").text = "Icon"
		obj.get_child(0).get_node("time").show()
		obj.get_child(0).get_node("energy").show()
		var ins = obj.get_child(child)
		ins.get_node("name").text = str(player.playerID) + " " +str(player.playerData.Name)
		ins.get_node("team").hide()
		ins.get_node("player").show()
		ins.get_node("time").show()
		ins.get_node("energy").show()
		
		if ins.get_node("team").visible == true:
			ins.get_node("team").text = ""
			ins.get_node("team").texture = Team.load_team_icon(player.teamData.icon)
		if ins.get_node("player/icon").visible == true:
			ins.get_node("player").text = ""
			ins.get_node("player/icon").texture = Player.load_icon(player.playerData.Icon)
		
		ins.get_node("goal").text = str(player.matchGoals)
		ins.get_node("assits").text = str(player.matchAssits)
		ins.get_node("shots").text = str(player.matchShots)
		ins.get_node("passes").text = str(abs(player.matchShots-player.matchPasses))
		ins.get_node("blocks").text = str(player.matchMoves + round(player.matchBlocks*1.0/3.0))
		if player.playerPositionMath == "CM":
			ins.get_node("blocks").text = str(round((player.matchMoves*1.0/2.0 + player.matchBlocks*1.0/5.0)))
		if player.playerPositionMath == "RF" or player.playerPositionMath == "LF":
			ins.get_node("blocks").text = str(round(player.matchMoves*1.0/5.0))
		if player.playerPositionMath == "GK" or player.matchSaves > 0:
			var opShot:int
			var opGoal:int = data.teamGoalC[team-1]
#			var gkSave:int = player.matchSaves
			if team == 1:
				opShot = data.teamShot[1]
			else:
				opShot = data.teamShot[0]
			if opGoal == 0:
				ins.get_node("saves").text = "100"
			else:
				ins.get_node("saves").text = str(round(((opShot-opGoal)*1.0/opShot)*100))
#				ins.get_node("saves").text = str(player.matchSaves)
		ins.get_node("time").text = str(player.statsPlayTime)
		ins.get_node("energy").text = str("%.0f" % player.statEnergy)
		
		var point = get_player_point(player,team,data)
		ins.get_node("pos").text = "%.1f" % point
		player.matchPoints = point
		if player.statsPlayTime == 0:
			ins.get_node("pos").text = "-"

func update_team_stats(team,data) -> void:
	var obj
	if team == 1:
		obj = teamA
	else:
		obj = teamB
	var ball = data.teamBall[0] + data.teamBall[1]
	if ball == 0:
		ball = 1
	obj.get_node("ball").text = str(round(data.teamBall[team-1]*1.0/ball*100))
	obj.get_node("shot").text = str(data.teamShot[team-1])
	obj.get_node("miss").text = str(data.teamMiss[team-1])
	obj.get_node("pass").text = str(abs(data.teamPass[team-1]-data.teamShot[team-1]))
	obj.get_node("block").text = str(data.teamDef[team-1])
	obj.get_node("save").text = str(data.teamSave[team-1])

func get_player_point(player,team,obj) -> float:
	var point:float
	point = 5.0 + (player.matchGoals + player.matchAssits/2.0
	+ player.matchPasses/10.0 + player.matchMoves/10.0 + player.matchShots/15.0
	+ player.matchSaves/10.0 + player.matchBlocks/10.0 + player.matchTackles/10.0
	- player.matchFouls/2.0 - player.matchOwnGoals - player.matchMistakes/2.0)
	
	if player.playerPositionMath == "GK":
		if obj.teamGoalC[team-1] > 0:
			point -= 0.2*obj.teamGoalC[team-1]
		else:
			point += 1.5
	elif (player.playerPositionMath == "CB"
	or player.playerPositionMath == "RB"
	or player.playerPositionMath == "LB"):
		if obj.teamGoalC[team-1] > 0:
			point -= 0.2*obj.teamGoalC[team-1]
		else:
			point += 1.0
	elif player.playerPositionMath == "CM":
		if obj.teamGoalC[team-1] > 0:
			point -= 0.1*obj.teamGoalC[team-1]
		else:
			point += 0.5
	
	if team == 1:
		if obj.teamGoal[0] > obj.teamGoal[1]:
			point += 0.5
		else:
			point -= 0.2*obj.teamGoalC[0]
	else:
		if obj.teamGoal[1] > obj.teamGoal[0]:
			point += 0.5
		else:
			point -= 0.2*obj.teamGoalC[1]
	
	point = clamp(point,2,10)
	return float(point)

func _exit_tree():
	queue_free()
