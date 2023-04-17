extends Control

@onready var tabs = $TabBar
@onready var time = $TabBar/MatchDetail/Menu/LabelBase

@onready var main = $TabBar/MatchDetail/MatchInfo/mainLabel
@onready var playerTeamA = $TabBar/MatchDetail/MatchInfo/PlayerInfo/PlayerA
@onready var playerTeamB = $TabBar/MatchDetail/MatchInfo/PlayerInfo/PlayerB

@onready var teamA = $TabBar/MatchDetail/MatchInfo/TeamA
@onready var teamB = $TabBar/MatchDetail/MatchInfo/TeamB

@onready var goalA = $TabBar/MatchDetail/GoalA
@onready var goalB = $TabBar/MatchDetail/GoalB

@onready var btnClose = $TabBar/MatchDetail/ButtonClose
@onready var btnCloseMain = $ButtonClose
@onready var btnQuit = $TabBar/Settings/VBoxContainer/ButtonExit
@onready var btnHome = $TabBar/MatchDetail/ButtonHome

@onready var playerGoals = preload("res://MGF Scene/Main Game/PlayerGoals.tscn")

var openPos = Vector2.ZERO
var closePos = Vector2(0,850)

var data

func _ready():
	data = GameData.season_load_data()

func update_player_stats(team,player,child):
	if child > 0:
		if team == 1:
			team = playerTeamA
		else:
			team = playerTeamB
		var ins = team.get_child(child)
		ins.get_node("name").text = str(player.playerID) + " " +str(player.playerName)
		ins.get_node("team/team").texture = load(data.teams[int(player.playerTeam)].icon)
		ins.get_node("team").text = ""
		ins.get_node("pos").text = str("%.1f" % (float(player.gameRates)))
		ins.get_node("goal").text = str(player.gameGoals)
		ins.get_node("assits").text = str(player.gameAssits)
		ins.get_node("shots").text = str(player.gamePasses)
#		ins.get_node("shots").text = str(player.gameShots)
		ins.get_node("passes").text = str(player.gamePasses)
		ins.get_node("blocks").text = str(player.gameMoves)
#		ins.get_node("blocks").text = str(player.gameDefends)
		ins.get_node("saves").text = str(player.gameSaves)

func update_team_stats(team,stats):
	if team == 1:
		team = teamA
	else:
		team = teamB
	team.get_node("ball").text = stats
	team.get_node("shot").text = stats
	team.get_node("miss").text = stats
	team.get_node("pass").text = stats
	team.get_node("block").text = stats
	team.get_node("save").text = stats
