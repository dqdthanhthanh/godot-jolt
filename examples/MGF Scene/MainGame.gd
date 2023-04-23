extends Node3D

# Obj vảar
@onready var Ball:RigidBody3D = $Ball
@onready var Arrow:Node3D = $Arrow

@onready var GoalA:Area3D = $GoalA
@onready var GoalB:Area3D = $GoalB
@onready var GkA:Area3D = $GoalA/Gk
@onready var GkB:Area3D = $GoalB/Gk
@onready var KickingBallA:Area3D = $GoalA/KickingBall
@onready var KickingBallB:Area3D = $GoalB/KickingBall
@onready var BallKickA:Marker3D = $GoalA/BallKick
@onready var BallKickB:Marker3D = $GoalB/BallKick
@onready var startBall:Marker3D = $BallStart

@onready var UI:CanvasLayer = $UI
@onready var Replay = UI.ReplayPlayer
@onready var Cam:Camera3D = $Camera3D
@onready var Weather:Node3D = $Weather
@onready var Target: = $AITest/Target
@onready var SoundBG:AudioStreamPlayer = $Sounds/SoundBackGround
@onready var SFXMove:AudioStreamPlayer = $Sounds/PlayerMovingSFX
@onready var SFXShoot:AudioStreamPlayer = $Sounds/PlayerShootSFX
@onready var SFXGameWhistle:AudioStreamPlayer = $Sounds/SFXGameWhistle

@onready var TimerGame:Timer = $Timers/Timer
@onready var TimerStop:Timer = $Timers/TimerStop
@onready var TimerStartGame:Timer = $Timers/TimerStartGame
@onready var TimerNewTurn:Timer = $Timers/TimerNewTurn
@onready var AITimer:Timer = $Timers/AITimer

#@onready var effGame:EffekseerEmitter = $EffekseerEmitter

# Players Unit
#get_tree().get_nodes_in_group("units,team1,team2")
@onready var units:Array = get_tree().get_nodes_in_group("units")
var teamA:Array
var teamB:Array

# Group chua cau thu
var teamAGroup
var teamBGroup

var teamAData:Array = [3,3,3]
var teamBData:Array = [3,3,3]

var goalCheck:bool = true
var TeamA_score:int = 0
var TeamB_score:int = 0

# Global var
var time:int = 0 ## Luot dau
var teamSelect:int = 1 ##Set up luot dau doi dieu khien
var gameRound:int = Global.timeList[Global.timeCur].time
var timePlus:int = Global.timeList[Global.timeCur].plus

# Selection
const ray_length:int = 1000
var selected_units:Array = []
var selected_player:Array = []

# Check, data
var timeGoals:Array = []
var camFollowBall:bool = false
var camPos:Vector3 = Vector3.ZERO

var playersPos:Dictionary #Player position in team formation
var playerShotID:int = 0 #thuc hien hanh dong cho AI
var playerTeamID:int = 0 #thuc hien hanh dong cho AI

var isGameTime:int = 1 #Kiem tra hiep dau
var isStartGame:bool = false #DK bat dau tran dau
var isStartTurn:bool = false #DK bat dau tran dau
var timeOutMode:int = 5 #Set het gio
var shotTime:int = 0 #TestMode

# State
var state:int = SET_GAME
enum {SET_GAME,SET_IDLE, SET_PLAYER, SET_AIM, SET_ANGLE, SET_POWER, SET_SHOOT}

var AIState:int
enum {AI_DEF, AI_MID, AI_ATK}

# AI
var AI_id#Cauthu
var gkAReset:int = 0
var gkBReset:int = 0
var gkDis:float
var gkArrow:float
var gkBall:Vector3
var gkSave:float
var gkGoal:Area3D
var gkGoalDis:float

var power:float = 0 #Shot
var checkFoot:int = 0 #Chan sut bong
var checkRange:float = 2.9
var ball2Target:float = 0
var AIShootAngle:float = 0
var AIPowerShot:float = 0
var AIShoot:float = 0
var AITackle:float = 0

# Timmer Value
var timerValue:String = ""
# Timmer Change Value
var timerAI:int = 0

var ID:int = 0
var playerKick:Array = []
var teamGoal:Array = [0,0]
var teamGoalC:Array = [0,0]
var teamBall:Array = [0,0]
var teamPass:Array = [0,0]
var teamShot:Array = [0,0]
var teamMiss:Array = [0,0]
var teamDef:Array = [0,0]
var teamSave:Array = [0,0]


## Istance 2 team duoc chon vao
func _init():
	load_team_formation_data(Global.teamID1,1)
	load_team_formation_data(Global.teamID2,2)

func load_team_formation_data(value, number) -> void:
	var par = load("res://MGF Scene/MiniMap/Units.tscn").instantiate()
	add_child(par)
	if number == 1:
		teamAGroup = par
		par.name = "teamA"
	else:
		teamBGroup = par
		par.name = "teamB"
	var data = GameData.formation_load_data()
	var teamData = data.teams[value].Fid
	var playerData
	var playerPath
	var playerIns
	if teamData.size()>0:
		playerData = teamData[0]
		playerPath = data.players[playerData].FilePath
		
		## Tao team group
		Global.team = number
		## Tao cau thu
		for i in teamData.size():
			playerData = teamData[i]
			playerPath = data.players[int(playerData)].FilePath
			## Load file cau thu
			playerIns = load(playerPath).instantiate()
			## Lay data cho cau thu
			playerIns.playerID = int(teamData[i])
			playerIns.ID = ID
			ID += 1
			
			par.add_child(playerIns)
			if number == 1:
				playerIns.add_to_group("team1")
			else:
				playerIns.add_to_group("team2")

func create_player_signal() -> void:
	for unit in units:
		teamA = get_tree().get_nodes_in_group("team1")
		teamB = get_tree().get_nodes_in_group("team2")
		unit.find_targets()
	
	Arrow.hide()
	if Global.gameModeCur < 2:
		Global.isFoul = true
	else:
		Global.isFoul = false
	
	if !Global.device_is_mobile() and Global.gameModeCur == 3:
		$AITest/Target.position.z = 0
		$AITest/Target.show()
	camFollowBall = true
	
	match Global.gameModeCur:
		0:#Player vs Player
			pass
		1:#Player vs AI
			pass
		2:#Trainng
			var teamHide = 0
			if Global.MatchPlay == 1:
				teamHide = 2
			else:
				teamHide = 1
		
			for unit in units:
				if unit.team == teamHide:
					unit.playerPositionMath = "NON"
		3:#Test Mode
			UI.test_mode_active()
	
	var a = -16.5
	var team = teamA
	for i in 2:
		for unit in team:
			if unit.playerPositionMath == "NON":
				unit.position.x = a
				unit.position.z = 9
				a -= 2.5
#				unit.player_is_collision(true)
		team = teamB
		a = 16.5
	
	await get_tree().create_timer(1).timeout
	for unit in units:
		unit.rotation_degrees.y = 0

func signal_connect() -> void:
	TimerStartGame.connect("timeout", Callable(self, "_on_TimerStartGame_timeout"))
	TimerNewTurn.connect("timeout", Callable(self, "_on_TimerNewTurn_timeout"))
	TimerStop.connect("timeout", Callable(self, "_on_TimerAllStop_timeout"))
	AITimer.connect("timeout", Callable(self, "_on_AITimer_timeout"))
	TimerGame.connect("timeout", Callable(self, "_on_Timer_timeout"))
	
	GkA.connect("body_entered", Callable(self, "_on_GkA_body_entered"))
	GkB.connect("body_entered", Callable(self, "_on_GkB_body_entered"))
	
	GoalA.connect("body_entered", Callable(self, "_on_GoalA_body_entered"))
	GoalB.connect("body_entered", Callable(self, "_on_GoalB_body_entered"))
	
	KickingBallA.connect("body_entered", Callable(self, "_on_KickingBallA_body_entered"))
	KickingBallB.connect("body_entered", Callable(self, "_on_KickingBallB_body_entered"))
	
	UI.MatchDetail.btnHome.connect("pressed", Callable(self, "_on_ButtonHome_pressed"))

## Match Setup
func _ready() -> void:
	FormationData.load_team_tactic()
	UI.update_Times(time)
	create_player_signal()
	SoundGlobal.volume_low()
	signal_connect()
	Global.autoMode = false
	player_set_physics()
	change_player()
	pos_reset_players(true)
	Calculate.timer(TimerStartGame,1)
	UI.talk("Start Game")
	SFXGameWhistle.play()

func _process(delta) -> void:
	if !Global.device_is_mobile():
		target_control_input(delta)

func load_debug_log() -> void:
	if get_tree().get_root().has_node("DebugLog"):
		DebugLog.team = teamSelect
		DebugLog.state = str(state)

## Xu ly chuyen luot
func _on_TimerStartGame_timeout() -> void:
	pos_reset_hold_ball()
	change_player()
	Calculate.timer(TimerStop,3)
	await get_tree().create_timer(2).timeout
	isStartGame = true

func _on_TimerNewTurn_timeout() -> void:
	Calculate.timer(TimerStop,2)
	if teamSelect == 1:
		teamSelect = 2
	else:
		teamSelect = 1

func _on_TimerAllStop_timeout() -> void:
	change_state(SET_IDLE)
	pos_all_stop()
	goalCheck = true
	UI.newTurn.start_time()
	change_team()
	change_state(SET_PLAYER)
	change_game()

## Thay doi team duoc dieu khien
func change_game() -> void:
	if Global.gameModeCur < 2:
		## Bat dau hiep hai
		if time == gameRound:
			FormationData.AI_random_tactical()
			FormationData.load_team_tactic()
			SFXGameWhistle.play()
			isStartGame = false
			## Setup hiep 2
			isGameTime = 2
			GoalA.position.x = -14.225
			GoalB.position.x = 14.225
			GoalA.rotation_degrees.y = -180
			GoalB.rotation_degrees.y = 0
			Calculate.vibrate_set()
			teamSelect = 2
			pos_reset_players()
			Calculate.timer(TimerStartGame,1)
			UI.talk("Haft Time")
			
			await get_tree().create_timer(3).timeout
			SoundGlobal.volume_normal()
			UI.match_detail_visible(2)
			SFXGameWhistle.play()
			UI.score_voice()
		## Het gio
		if time == (gameRound*2) or teamAData[1] == 0 or teamBData[1] == 0:
			isStartGame = false
			isGameTime = 3
			await get_tree().create_timer(2).timeout
			
			for unit in units:
				unit.player_play_time(time)
			
			SFXGameWhistle.play()
			SoundBG.stop()
			Calculate.vibrate_set()
			UI.talk("FullTime")
			UI.score_voice()
			SoundGlobal.volume_normal()
			
			UI.ReplayPlayer.btnClose.hide()
			UI.ReplayPlayer.play_replay(0)
			UI.ui_visible(false)
			
			if SeasonData.check_season_mode() == true:
				UI.season_match_list_active()
			else:
				end_game()

func end_game() -> void:
	await get_tree().create_timer(5).timeout
	UI.ui_visible(true)
	UI.match_detail_visible(2)
	UI.update_noti_match_results()
	if TeamA_score > TeamB_score:
		UI.update_team_ui(UI.teamAMat)
	elif TeamA_score > TeamB_score:
		UI.update_team_ui(UI.teamBMat)
	
	if SeasonData.check_season_mode() == true:
		UI.player_performance_active()

func check_team_selected() -> bool:
	if Global.MatchPlay == teamSelect:
		return true
	else:
		return false

func units_set_up(value:int = 0) -> void:
	match value:
		0:
			units = get_tree().get_nodes_in_group("units")
		1:
			units = get_tree().get_nodes_in_group("team1")
		2:
			units = get_tree().get_nodes_in_group("team2")

func change_team() -> void:
	if isStartGame == true:
		units = get_tree().get_nodes_in_group("units")
		for unit in units:
			unit.player_play_time(time)
#		pos_reset_y()
		AI_gk_check_reset()
		time += 1
		shotTime += 1
		sub_change_start()
		if Global.gameModeCur == 3:
			if !Global.isChange:
				pos_reset_hold_ball()
				pos_reset_gk(1)
			else:
				pos_reset_hold_ball()
				pos_reset_gk(2)
			var goal = UI.return_team_goal(1)
			var shotGoal = "%.1f" % (float(goal)/shotTime * 100.0)
			if Global.isShootTest and shotTime > 1:
				UI.update_player_goal_info(selected_units[0],str(shotGoal) +"%/",false)
#				UI.TestMode.show()
		
		UI.update_Times(time)
		
		if Global.gameModeCur != 3:
			if teamSelect == 1:
				teamSelect = 1
			else:
				teamSelect = 2
		else:
			if Global.isChange == true:
				teamSelect = 1
			else:
				teamSelect = 2
		check_team_player()
		change_player()
		AI_action()
		
		notification_change_team()
	
	## MatchDetail kiem soat bong
	teamBall[units[find_player(0)].team-1] += 1
	
	for unit in units:
		unit.deselect()
	for unit in selected_units:
		unit.select()
		unit.textBox.player_talk()

func change_player(obj = Ball) -> void:
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.playerPositionMath != "NON":
			if teamSelect == 1:
				if unit.team == 1:
					unit.SelectMesh.mesh_select(0.4)
				else:
					unit.SelectMesh.mesh_select(0)
			else:
				if unit.team == 2:
					unit.SelectMesh.mesh_select(0.4)
				else:
					unit.SelectMesh.mesh_select(0)
			
			selected_units.clear()
			
			var playerSelect = units[find_player(teamSelect,obj)]
			selected_player.append(playerSelect)
			selected_units.append(playerSelect)
			
			UI.update_player_data(playerSelect)

## Kiem tra cau thu co giu bong
func check_ball_on_player() -> bool:
	var value:bool = false
	for unit in selected_units:
		if units[find_player(3)] == unit:
			value = true
		else:
			value = false
	return value

func check_ball_on_team() -> int:
	var value:int
	for unit in units:
		if units[find_player(3)] == unit:
			value = unit.team
	return value

func check_team_has_player(team) -> bool:
	if team == 1:
		units = get_tree().get_nodes_in_group("team1")
	else:
		units = get_tree().get_nodes_in_group("team2")
	var count = 0
	for unit in units:
		if unit.playerPositionMath != "NON":
			count += 1
	if count > 0:
		return true
	else:
		return false

func check_team_player() -> void:
	if check_team_has_player(1) == false:
		teamSelect = 2
	elif check_team_has_player(2) == false:
		teamSelect = 1

func check_game_has_gk(value) -> bool:
	match value:
		0:
			units = get_tree().get_nodes_in_group("units")
		1:
			units = get_tree().get_nodes_in_group("team1")
		2:
			units = get_tree().get_nodes_in_group("team2")
	var check:bool = false
	for unit in units:
		if unit.playerPositionMath == "GK":
			check = true
	return check

func find_player(value,obj = Ball) -> int:
	var a:int
	var ss:Array = []
	
	if value == 1:
		units = get_tree().get_nodes_in_group("team1")
	elif value == 2:
		units = get_tree().get_nodes_in_group("team2")
	else:
		units = get_tree().get_nodes_in_group("units")
	
	for unit in units:
		var AI_Speed:float
		if Global.AIState != Global.AI_FIGHT:
			AI_Speed = unit.turn_speed
		else:
			AI_Speed = unit.turn_def
		var diff = abs(obj.position.distance_to(unit.position+unit.AIMPOS))+AI_Speed
		if unit.playerPositionMath != "NON":
			diff -= 10
		ss.append(diff)
	
	for n in ss.size():
		if ss[n] == ss.min():
			a = n
	
	if units[a].playerPositionMath == "GK":
		if teamSelect == 1:
			gkAReset = 0
		else:
			gkBReset = 0
	return a

## Get unit player
func get_unit():
	for unit in selected_units:
		return unit

func get_unit_gk(value:int = 0):
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.playerPositionMath == "GK":
			if unit.team == value:
				return unit

func get_ball_to_target() -> void:
	for unit in selected_units:
		if unit.team == 1:
			playerShotID = unit.playerID
			playerTeamID = 1
			ball2Target = Ball.position.distance_to(GoalA.position)
		else:
			playerShotID = unit.playerID
			playerTeamID = 2
			ball2Target = Ball.position.distance_to(GoalB.position)
	if Global.isAIState:
		ball2Target = Ball.position.distance_to(AI_return_target())

## Cac ham xu ly vi tri
func pos_reset_hold_ball() -> void:
	check_team_player()
	units = get_tree().get_nodes_in_group("units")
	if Global.gameModeCur != 3:
		for unit in units:
			if unit.playerPositionMath != "NON":
				var pos = Ball.position - units[find_player(teamSelect)].AIMPOS
				GlobalTween.pos(units[find_player(teamSelect)],pos)
				unit.linear_velocity = Vector3.ZERO
				unit.angular_velocity = Vector3.ZERO
				unit.rotation_degrees.y = 0
	else:
		for unit in selected_units:
			if unit.playerPositionMath != "NON":
				var fixA = unit.FootFixR
				var fixB = unit.FootFixL
				if Global.isChange == true:
					UI.TestMode.get_player_foot_fix(fixA)
					UI.TestMode.get_player_foot_size(unit.FootSizeR*1000)
				else:
					UI.TestMode.get_player_foot_fix(fixB)
					UI.TestMode.get_player_foot_size(-unit.FootSizeL*1000)

		if Global.isChange:
			for unit in units:
				if unit.playerPositionMath != "NON":
					var pos = Ball.position - units[find_player(1)].AIMPOS
					GlobalTween.pos(units[find_player(1)],pos)
		else:
			for unit in units:
				if unit.playerPositionMath != "NON":
					var pos = Ball.position - units[find_player(2)].AIMPOS
					GlobalTween.pos_dir(units[find_player(2)],pos)

func pos_reset_players(value:bool = false, team:int = 0) -> void:
	change_state(SET_GAME)
	GlobalTween.pos(Ball,startBall.position)
	Ball.linear_velocity = Vector3.ZERO
	Ball.angular_velocity = Vector3.ZERO
	if isGameTime == 1:
		if team == 0 or team == 1:
			FormationData.reload_formation(1)
			playersPos = FormationData.get_formation()[FormationData.teamTac1]
			for unit in teamA:
				if unit.playerPositionMath != "NON":
					var pos = playersPos[unit.playerPositionMath]
					if value == false:
						GlobalTween.pos(unit,pos)
					else:
						unit.position = pos
		if team == 0 or team == 2:
			FormationData.reload_formation(2)
			playersPos = FormationData.get_formation()[FormationData.teamTac2]
			for unit in teamB:
				if unit.playerPositionMath != "NON":
					var pos = Vector3(-playersPos[unit.playerPositionMath].x,
					playersPos[unit.playerPositionMath].y,
					playersPos[unit.playerPositionMath].z)
					if value == false:
						GlobalTween.pos(unit,pos)
					else:
						unit.position = pos
	else:
		if team == 0 or team == 2:
			FormationData.reload_formation(2)
			playersPos = FormationData.get_formation()[FormationData.teamTac2]
			for unit in teamB:
				if unit.playerPositionMath != "NON":
					var pos = playersPos[unit.playerPositionMath]
					if value == false:
						GlobalTween.pos(unit,pos)
					else:
						unit.position = pos
			FormationData.reload_formation(1)
			playersPos = FormationData.get_formation()[FormationData.teamTac1]
		if team == 0 or team == 1:
			for unit in teamA:
				if unit.playerPositionMath != "NON":
					var pos = Vector3(-playersPos[unit.playerPositionMath].x,
					playersPos[unit.playerPositionMath].y,
					playersPos[unit.playerPositionMath].z)
					if value == false:
						GlobalTween.pos(unit,pos)
					else:
						unit.position = pos

func pos_reset_gk(value:int) -> void:
	if value == 1:
		gkAReset = 0
		playersPos = FormationData.get_formation()[FormationData.teamTac1]
		for unit in teamA:
			if unit.playerPositionMath == "GK":
				if isGameTime == 1:
					var pos = playersPos[unit.playerPositionMath]
					GlobalTween.pos_dir(unit,pos)
					unit.linear_velocity = Vector3.ZERO
					unit.angular_velocity = Vector3.ZERO
				else:
					var pos = Vector3(-playersPos[unit.playerPositionMath].x,
					playersPos[unit.playerPositionMath].y,
					playersPos[unit.playerPositionMath].z)
					GlobalTween.pos_dir(unit,pos)
					unit.linear_velocity = Vector3.ZERO
					unit.angular_velocity = Vector3.ZERO

	elif value == 2:
		gkBReset = 0
		playersPos = FormationData.get_formation()[FormationData.teamTac2]
		for unit in teamB:
			if unit.playerPositionMath == "GK":
				if isGameTime == 1:
					var pos = Vector3(-playersPos[unit.playerPositionMath].x,
					playersPos[unit.playerPositionMath].y,
					playersPos[unit.playerPositionMath].z)
					GlobalTween.pos_dir(unit,pos)
					unit.linear_velocity = Vector3.ZERO
					unit.angular_velocity = Vector3.ZERO
				else:
					var pos = playersPos[unit.playerPositionMath]
					GlobalTween.pos_dir(unit,pos)
					unit.linear_velocity = Vector3.ZERO
					unit.angular_velocity = Vector3.ZERO
	change_player()

func pos_reset_y() -> void:
	if Global.isFixPosY == true:
		for unit in units:
			unit.position.y = 0

func pos_all_stop() -> void:
	units =  get_tree().get_nodes_in_group("units")
	Ball.linear_velocity = Vector3.ZERO
	Ball.angular_velocity = Vector3.ZERO
	if Global.gameModeCur == 3:
		Ball.position = startBall.position
	for unit in units:
		selected_units.clear()
		if unit.playerPositionMath != "NON" and unit.playerPositionMath != "GK":
			unit.player_set_stop()
			var pos = Ball.position - units[find_player(3)].AIMPOS
			GlobalTween.pos_dir(units[find_player(3)],pos)
		if unit.playerPositionMath == "GK":
			unit.player_set_stop()

## Cac ham tinh toan
func update_powerbar(value) -> void:
	for unit in selected_units:
		unit.select()
		unit.textBox.update_powerbar(value)

func player_col_active(value) -> void:
	pass
#	Ball.set_collision_mask_value(0,value)
#	for unit in units:
#		if unit.playerPositionMath != "NON":
#			unit.set_collision_mask_value(0,value)

## Cac che do trong man choi
# Cac chuc nang trong tung che do choi
func change_state(new_state) -> void:
	state = new_state
	load_debug_log()
	player_col_active(false)
	match state:
		SET_GAME:
			UI.ReplayPlayer.replay_is_save(true)
			camFollowBall = false
		SET_IDLE:
			UI.ReplayPlayer.replay_is_save(true)
			camFollowBall = false
			player_col_active(true)
			AI_set_idle()
		SET_PLAYER:
			UI.ReplayPlayer.replay_is_save(false)
			AI_set_player()
		SET_AIM:
			UI.ReplayPlayer.replay_is_save(false)
			AI_set_aim()
		SET_ANGLE:
			UI.ReplayPlayer.replay_is_save(false)
			AI_set_angle()
		SET_POWER:
			UI.ReplayPlayer.replay_is_save(true)
			get_ball_to_target()
			AI_set_power()
		SET_SHOOT:
			UI.newTurn.isStart = false
			UI.ReplayPlayer.replay_is_save(true)
			player_col_active(true)
			update_powerbar(power)
			player_set_physics()
			player_set_shoot()
			## NewTurn
			_on_TimerNewTurn_timeout()

## Seup AI mode
func AI_mode() -> bool:
	var value:bool = false
	match Global.gameModeCur:
		0:#Player vs Player
			pass
		1:#Player vs AI
			if teamSelect == Global.MatchPlay:
				pass
			else:
				value = true
			if Global.autoMode == true:
				value = true
		2:#Trainng
			if teamSelect == Global.MatchPlay:
				pass
			else:
				value = true
			if Global.autoMode == true:
				value = true
		3:#Test Mode
			if teamSelect == Global.MatchPlay:
				pass
			else:
				value = true
			if Global.autoMode == true:
				value = true
	return value

## Tinh toan truoc khi thuc hien hanh dong cho AI
func AI_return_target():
	match Global.AIState:
		0:#AI_PASS
			Target = AI_id
		1:#AI_CREATE
			Target = AI_id
		2:#AI_SHOOT
			Target = get_unit().goal
		3:#AI_MOVE
			Target = get_unit().goal
		4:#AI_FIGHT
			Target = Ball
		5:#AI_DEF
			Target = AI_id
		6:#AI_CELEBRATE
			Target = Ball
	if Global.isDebug == true and Global.gameModeCur == 3:
		$AITest/Target.show()
		Target = $AITest/Target
	else:
		$AITest/Target.hide()
	return Target.position

func AI_check_target() -> void:
	#enum {AI_DEF, AI_MID, AI_ATK}
	match AIState:
		0:#AI_DEF
			pass
		1:#AI_MID
			pass
		2:#AI_ATK
			pass
	"""
	Xac dinh the tran dua ra quyet dinh:
		Phong ngu:
			Cau thu doi phuong co ball gan goal: khong co ball
				gianh lai bong
			ball gan goal: cau thu doi phuong gan ball: co ball
				chuyen bong len: cau thu gan goal
				tao co hoi
			cau thu doi phuong co bi kem:
				cu nguoi theo kem
				tao co hoi
		Tao co hoi:
			co cau thu gan goal chua:
				di chuyen cau thu tan cong len gan goal
				chuyen bong cho cau thu tan cong
		Tan cong: co ball
			cau thu co bong gan goal:
				sut bong
				tao co hoi: chua gan goal, cau thu chi so thap,
			cau thu co bong xa goal:
				sut bong: chi so sut xa toi, gk loi vi tri
				tao co hoi
	"""

func AI_action() -> void:
	# 1 Check team
	# 2 Check player2goal: max: move2goal min: skip
	# 3 Check HoldBall:
	# true:
	#	check ball2goal: max: pass,move2goal min: shot
	# false:
	#	check ball2goal: max: move2goal move2ball min: move2ball
	
	if AI_mode() == true:
		Global.isAIState = true
		var b2g:float = 0
		var p2g:float = 0
		var goal
		## Check Team
		if teamSelect == 1:
			goal = GoalA
		else:
			goal = GoalB
		
		p2g = units[find_player(teamSelect,goal)].position.distance_to(goal.position)
		b2g = Ball.position.distance_to(goal.position)
		
		## Check player2goal
		# {AI_PASS 0, AI_CREATE 1, AI_SHOOT 2, AI_MOVE 3, AI_FIGHT 4, AI_GOAL 5, AI_CELEBRATE 6}
		if Global.gameModeCur != 3:
			if p2g > 12.5:
				if check_ball_on_player() == true:
					if teamSelect == 1:
						change_player(GoalA)
					else:
						change_player(GoalB)
					Global.AIState = Global.AI_MOVE
					if check_ball_on_player() == true:
						Global.AIState = Global.AI_SHOOT
				else:
					if b2g > 20:
						Global.AIState = Global.AI_FIGHT
					else:
						Global.AIState = Global.AI_MOVE
			else:
				if check_ball_on_player() == true:
					if b2g > 15:
						Global.AIState = Global.AI_PASS
					else:
						Global.AIState = Global.AI_SHOOT
				else:
					if b2g > 15:
						Global.AIState = Global.AI_FIGHT
					else:
						Global.AIState = Global.AI_FIGHT
				change_player()
		change_state_AI()
		AI_find_target()

func AI_find_target() -> void:
		var target1:Array = []
		var target2:Array = []
		#	var test:Player
		for i in get_tree().get_nodes_in_group("team1"):
			if i.playerPositionMath != "NON" and i.playerPositionMath != "GK" and i != get_unit():
				target1.append(i)
		for i in get_tree().get_nodes_in_group("team2"):
			if i.playerPositionMath != "NON" and i.playerPositionMath != "GK" and i != get_unit():
				target2.append(i)
		if teamSelect == 1:
			target1.sort_custom(Callable(self, "sort_player2goal"))
			target1.pop_back()
			target1.pop_back()
			target1.pop_back()
			AI_id = Calculate.random_in_size(target1)
		else:
			target2.sort_custom(Callable(self, "sort_player2goal"))
			target2.pop_back()
			target2.pop_back()
			target2.pop_back()
			AI_id = Calculate.random_in_size(target2)

func sort_player2goal(a, b):
	var goal
	if teamSelect == 1:
		goal = GoalA
	else:
		goal = GoalB
	a.position.distance_to(goal.position)
	if a.position.distance_to(goal.position) < b.position.distance_to(goal.position):
		return true
	return false

# AIState = {AI_PASS, AI_CREATE, AI_SHOOT, AI_MOVE, AI_FIGHT, AI_DEF, AI_CELEBRATE}
func change_state_AI() -> void:
	match Global.AIState:
		Global.AI_PASS:
			for unit in selected_units:
				unit.POWERCONTROLLER = remap(unit.statShotPower,40,100,unit.a,unit.d)
				AIPowerShot = remap(unit.statShotPower,40,100,100,70)
		Global.AI_CREATE:
			var tg = AI_return_target().z
			var ballPos = 0
			
			if tg<0:
				ballPos = remap(tg,1.5,-0.5,-1,0.5)
			elif tg>=0:
				ballPos = remap(tg,-1.5,0.3,-1.5,0)
			
			var newTarget = Vector3(AI_return_target().x,0,ballPos)
			Arrow.look_at(newTarget, Vector3(0,1.01,0))
			var goalDis
			if teamSelect == 1:
				goalDis = AI_return_target().distance_to(GoalA.position)
			else:
				goalDis = AI_return_target().distance_to(GoalB.position)
			var powerGoal = remap(goalDis,0,6,0.6,1.8)
			for unit in selected_units:
				AIPowerShot = (unit.statShotPower+unit.statSpeed)/2*powerGoal
#				print(powerGoal," ",AIPowerShot)
			var rangeAngle = remap(ball2Target,0,6,15,10)
			var randomAngle = Calculate.rand_num(rangeAngle)
			Arrow.rotation_degrees.y += randomAngle
		Global.AI_SHOOT:
			for unit in selected_units:
				AIPowerShot = 100
		Global.AI_MOVE:
			for unit in selected_units:
				AIPowerShot = 100
		Global.AI_FIGHT:
			for unit in selected_units:
				AIPowerShot = 100
		Global.AI_COVER:
			for unit in selected_units:
				AIPowerShot = 100
		Global.AI_CELEBRATE:
			for unit in selected_units:
				AIPowerShot = 100

func _on_AITimer_timeout() -> void:
	if Replay.isPlayReplay == false and isStartGame == true:
		match timerAI:
			0:
				change_player()
				change_state(SET_PLAYER)
			1:
				change_state(SET_AIM)
			2:
				change_state(SET_ANGLE)
				arrow_pos()
				AI_player_angle_start_set()
				AI_player_angle_set()
			3:
				change_state(SET_POWER)
				AI_player_shot_pos_set()
				AI_draw_force_line()
			4:
				AI_player_power_set()
				change_state(SET_SHOOT)
			5:
				change_state(SET_IDLE)

func AI_draw_force_line(value:bool = true) -> void:
	if value:
		var m_pos = Cam.unproject_position(Ball.position)
		var target = Cam.unproject_position(AI_return_target())
		if check_ball_on_player() == false:
			for unit in selected_units:
				m_pos = Cam.unproject_position(unit.position)
		ClickEffect.drawForceAI.draw_line_force(m_pos,target,50,1.5)

## Chuyen hanh dong cho AI
func AI_set_idle() -> void:
	if AI_mode() == true:
		AITimer.wait_time = 0.5
		timerAI = 0
		AITimer.start()

func AI_set_player() -> void:
	if AI_mode() == true:
		AITimer.wait_time = 2
		timerAI = 1
		AITimer.start()

func AI_set_aim() -> void:
	if AI_mode() == true:
		change_state(SET_POWER)
		AITimer.wait_time = 0.5
		timerAI = 2
		AITimer.start()

func AI_set_angle() -> void:
	if AI_mode() == true:
		AITimer.wait_time = 0.5
		timerAI = 3
		AITimer.start()

func AI_set_power() -> void:
	if AI_mode() == true:
		AITimer.wait_time = 1.5
		timerAI = 4
		AITimer.start()

## Cac ham thuc hien hanh dong cho AI
func AI_find_foot() -> void:
	for unit in selected_units:
		if unit.FootUse < 75:
			if isGameTime == 1:
				if unit.team == 1:
					checkFoot = 2
				else:
					checkFoot = 1
			else:
				if unit.team == 2:
					checkFoot = 2
				else:
					checkFoot = 1
			if Global.gameModeCur == 3:
				if unit.team == 1:
					checkFoot = 2
				else:
					checkFoot = 1
		else:
			if unit.Foot == 1:
				checkFoot = 1
			else:
				checkFoot = 2

func AI_player_angle_start_set() -> void:
	for unit in selected_units:
		if Global.isAIState:
			Arrow.look_at(AI_return_target(), Vector3(0,1.01,0))
			match Global.AIState:
				0:
					var dis = Ball.position.distance_to(AI_return_target())
					var stats:float = remap(unit.statAccurate,40,100,5,10)
					AIShootAngle = Calculate.rand_num(dis/stats)
					var accurate = AI_return_target()
					accurate.z += AIShootAngle
					Arrow.look_at(accurate, Vector3(0,1.01,0))
				2:
					var gkDis:float = 0
					var gkZ:float = 0
					if teamSelect == 1:
						if check_game_has_gk(2):
							gkDis = get_unit_gk(2).position.distance_to(GoalA.position)
							gkZ = get_unit_gk(2).position.z
					else:
						if check_game_has_gk(1):
							gkDis = get_unit_gk(1).position.distance_to(GoalB.position)
							gkZ = get_unit_gk(1).position.z
					
					var angle:float = 0
					if Calculate.rand_num(1)>Calculate.rand_num(1):
						angle = 2
					else:
						angle = -2
					var rangeAngle:float = remap(ball2Target,0,25,0.5,1)
					var rangeAngleRan:float = Calculate.rand_num(rangeAngle)
					var accuAngle:float = remap(unit.statAccurate,40,100,0.5,0)
					var accuAngleRan:float = Calculate.rand_num(accuAngle)
					var accurate = AI_return_target()
					AIShootAngle = angle + accuAngleRan + rangeAngleRan
					
					if gkDis > 2.0:
						AIShootAngle = AIShootAngle/2
					if gkZ > 0.5:
						AIShootAngle = -abs(AIShootAngle)
					elif gkZ < -0.5:
						AIShootAngle = abs(AIShootAngle)
					
					accurate.z = AIShootAngle
					Arrow.look_at(accurate, Vector3(0,1.01,0))

func AI_player_angle_set() -> void:
	var AIShot:float
	var ranShot:float = 0
	if check_ball_on_player() == true:
		for unit in selected_units:
			var base = 100-(unit.statAccurate+unit.statShotPower)/2
			AIShot = remap(base,0,100,0,5)
			if Global.randomShot == true:
				ranShot = Calculate.rand_num(AIShot) + AIShootAngle
			else:
				ranShot += 0

		for unit in selected_units:
			var fixA:float = unit.FootFixL
			var fixB:float = unit.FootFixR
			if Global.gameModeCur == 3:
				if !Global.isAIState:
					fixA = Global.footFix
					fixB = Global.footFix
			var rot:Vector3
			if Arrow.rotation_degrees.y > 0:
				if unit.Foot == 1:
					rot.y = fixA+Arrow.rotation_degrees.y-90+ranShot
				else:
					rot.y = -fixA+Arrow.rotation_degrees.y-90+ranShot
			else:
				if unit.Foot == 1:
					rot.y = fixB+Arrow.rotation_degrees.y+90+ranShot
				else:
					rot.y = -fixB+Arrow.rotation_degrees.y+90+ranShot
			GlobalTween.rot(unit,rot,0.2)

func AI_player_power_set() -> void:
	if AI_mode() == true:
		change_state_AI()
		for unit in selected_units:
			var powerShot:float = AIPowerShot
			powerShot = clamp(powerShot,0,100)
			if check_ball_on_player() == true:
				var powerRange:float
				match Global.AIState:
					Global.AI_PASS:
						powerRange = remap(ball2Target,0,20,10,powerShot)
						var tar = AI_return_target().distance_to(Ball.position)
						var so = remap(tar,0,20,10,0) + (100-unit.statShotPower)/2
						powerRange += so
					Global.AI_SHOOT:
						powerRange = remap(ball2Target,0,15,50,powerShot)
				power = clamp(powerRange,0,powerShot)
				if Global.gameModeCur == 3:
					if Global.powerTest>10:
						power = Global.powerTest
					else:
						power = clamp(powerRange,0,powerShot)
			else:
				power = 100

func AI_player_shot_pos_set() -> void:
	var Foot2Ball:float = 0
	var pos:Vector3
	for unit in selected_units:
		## Xet chan sut
		AI_find_foot()
		
		## Tim vi tri sut bong
		if check_ball_on_player() == true:
			if checkFoot == 1:
				pos = unit.RightPoint.global_transform.origin
			else:
				pos = unit.LeftPoint.global_transform.origin
			
			var fix:Vector3 = Vector3(unit.position.x - pos.x,0,unit.position.z - pos.z)
			var aimPoint:Vector3 #Vi tri diem sut bong can tim
			var goalPoint:Vector3 #Vi tri khung thanh can tim
			var Ball2Goal:float #Khoang cach bong den goal, de tim aimpoit: diem sut bong
			
			## Xet vi tri chuan
			if Arrow.rotation_degrees.y > 0:
				Foot2Ball = unit.FootSizeL
			else:
				Foot2Ball = unit.FootSizeR
			
			if AI_mode() == true:
				if Global.isAIState:
					goalPoint = AI_return_target()
					Ball2Goal = Ball.position.distance_to(goalPoint)
			else:
				if isGameTime < 2:
					if Arrow.rotation_degrees.y < 0:
						goalPoint = GoalA.position
					else:
						goalPoint = GoalB.position
				else:
					if Arrow.rotation_degrees.y > 0:
						goalPoint = GoalA.position
					else:
						goalPoint = GoalB.position
				Ball2Goal = Ball.position.distance_to(goalPoint)
			
			if Global.gameModeCur == 3:
				Foot2Ball = Global.footSize/1000
			aimPoint = lerp(goalPoint, Ball.position, 1 + remap(Foot2Ball,0,Ball2Goal,0,5))
			var po:Vector3 = aimPoint+fix
			GlobalTween.pos_time(unit,po,0.5)

## Xu ly Ai cua thu mon
func _on_GkA_body_entered(body) -> void:
	if body == Ball and Replay.isPlayReplay == false:
		teamSave[1] += 1
		if teamSelect == 2:
			AI_gk_move(2)
			## MatchDetail sut bong
			if playerKick.size()>0:
				teamShot[0] += 1
				units[playerKick[0]].matchShots += 1
		else:
			if ball2Target < 20:
				AI_gk_move(2,false)

func _on_GkB_body_entered(body) -> void:
	if body == Ball and Replay.isPlayReplay == false:
		teamSave[0] += 1
		if teamSelect == 1:
			AI_gk_move(1)
			## MatchDetail sut bong
			if playerKick.size()>0:
				teamShot[1] += 1
				units[playerKick[0]].matchShots += 1
		else:
			if ball2Target < 20:
				AI_gk_move(1,false)

func AI_gk_move(GKteam:int, value:bool = true) -> void:
	AI_gk_defend_stats(GKteam,value)
	AI_gk_move_stats(GKteam,value)

# warning-ignore:unused_argument
func AI_gk_save_pos(ball,arrow,goal) -> float:
	var fix = gkBall.z/(gkDis)
	var result:float = (gkDis * tan(deg_to_rad(arrow))) - ball.z
	result = clamp(result,-3.5,3.5) - fix*3.0
	return -result

func AI_gk_move_stats(GKteam:int, value:bool = true) -> void:
	var pos:Vector3 = Vector3.ZERO
	var result:float
	pos.z = gkSave
	if value == false:
		var fix:float = gkBall.z/(gkDis)
		result = (gkDis * tan(deg_to_rad(gkArrow))) + gkBall.z
		result = clamp(result,-3,3) + fix*3.0
		pos.z = result
	for unit in units:
		if unit.team == GKteam:
			if unit.playerPositionMath == "GK":
				pos.x = unit.position.x
				var statsRef:float = (unit.statReflexes+unit.statEnergy)/2.0
				var statsSav:float = (unit.statSave+unit.statEnergy)/2.0
				var ballRangeGK = Ball.position.distance_to(unit.position+unit.AIMPOS)
				if ballRangeGK > 0.5:
					var GKDis:float = remap(gkDis,0,25,0,1)
					var save:float = remap(statsRef,40,100,1,3.5) + GKDis
					var dis:float =  abs(unit.position.z-pos.z)/5
					var time:float = remap(statsRef,40,100,0.1,0) + dis - GKDis
					time = clamp(time,0.0,1.0)
					pos.z = pos.z * save
					var s:float = statsSav/200+1.0
					pos.z = clamp(pos.z,-s,s)
					if value == false:
						if result > 0:
							pos.z = abs(pos.z)
						else:
							pos.z = -abs(pos.z)
					GlobalTween.pos_time(unit,pos,time)
					unit.matchSaves += 1
			elif (unit.playerPositionMath == "CB"
			or unit.playerPositionMath == "RB"
			or unit.playerPositionMath == "LB"
			or unit.playerPositionMath == "CM"):
				unit.matchBlocks += 1

func AI_gk_defend_stats(GKteam:int, value:bool = true) -> void:
	for unit in units:
		if unit.playerPositionMath == "GK" and unit.team == GKteam:
			if unit.playerID != playerShotID:
				unit.save_gk = remap((unit.statSave+unit.statEnergy)/2.0,40,100,2,12)
				#Bong vs Goal
				gkGoalDis = unit.position.distance_to(gkGoal.position)
				var bDis:float = remap(gkDis,0,25,1.5,12.5)
				bDis = clamp(bDis,1.5,12.5)
				#GK vs Goal
				var gDis:float = remap(gkGoalDis,1.5,10,5,25)
				if value == false:
					gDis = remap(gkGoalDis,1.5,10,15,5)
				gDis = clamp(gDis,5,25)
				#Tinh def GK
				unit.playerDefend = ((unit.save_gk - AIShoot) * bDis)/gDis
				unit.playerDefend = clamp(unit.playerDefend,1,16)
				unit.player_defend_set()

func AI_gk_check_reset() -> void:
	if check_game_has_gk(1) == true:
		var gkADis:float = get_unit_gk(1).position.distance_to(GoalB.position)
		if gkADis > 1 or  gkADis < 0.9:
			gkAReset += 1
			if gkAReset > 2:
				pos_reset_gk(1)
	
	if check_game_has_gk(2) == true:
		var gkBDis:float = get_unit_gk(2).position.distance_to(GoalA.position)
		if gkBDis > 1 or  gkBDis < 0.9:
			gkBReset += 1
			if gkBReset > 2:
				pos_reset_gk(2)

## Notification whenn change team
func notification_change_team() -> void:
	if teamSelect == 1:
		UI.update_Notification(teamA[0].teamData.icon, teamA[0].teamData.fullName)
	elif teamSelect == 2:
		UI.update_Notification(teamB[0].teamData.icon, teamB[0].teamData.fullName)

## Cac ham xu ly thong so cau thu
func player_set_physics() -> void:
	## Lay player tackle
	for unit in selected_units:
		if check_ball_on_player() == false:
			AITackle = unit.friction_tackle
			AIShoot = 0
		else:
			AITackle = 0
			AIShoot = unit.physic_shot
	
	for unit in units:
		if Global.gameModeCur == 3:
			unit.player_set_physics()
		unit.physics_material_override = unit.physics_material_override.duplicate()
		unit.linear_damp = unit.linear_base+AITackle
		unit.angular_damp = unit.angular_base+AITackle
		unit.physics_material_override.friction = unit.friction_base+AITackle
		unit.physics_material_override.bounce = unit.bounce_base+(AITackle/2.0)
		unit.mass = unit.mass_base-AITackle*10
		unit.playerDefend = unit.defend_base
		if unit.playerPositionMath == "GK":
			unit.mass = unit.mass_gk
		unit.player_defend_set()
	
	for unit in selected_units:
		unit.player_set_physics()
		unit.physics_material_override = unit.physics_material_override.duplicate()
		unit.physics_material_override.friction = unit.friction_move
		unit.linear_damp = unit.linear_base
		unit.angular_damp = unit.angular_base
		unit.POWERCONTROLLER = 3
		unit.mass = unit.mass_def
		AITackle = unit.friction_tackle
		unit.playerDefend = 1
		unit.player_defend_set()
		if check_ball_on_player() == true:
			unit.physics_material_override = unit.physics_material_override.duplicate()
			unit.POWERCONTROLLER = unit.POWERCONTROLLERSHOT
			unit.linear_damp = unit.linear_shot
			unit.angular_damp = unit.angular_shot
			unit.physics_material_override.friction = unit.friction_shot
			unit.physics_material_override.bounce = unit.bounce_shot

func player_set_shoot() -> void:
	player_set_stats()
	isStartTurn = false
#	Ball.effTrail.play()
	player_set_gk_save()
	if state != 7:
		for unit in selected_units:
			unit.direction = unit.PivotPoint.position
#			unit.playerVfx.speed = 0.3
#			unit.playerVfx.play()
			if check_ball_on_player() == true:
				playerKick = []
				playerKick.append(unit.ID)
				unit.playerColor.a = 0.6
				Ball.ball_effect_trail(unit.playerColor)
				if checkFoot == 1:
					unit.direction = unit.RightPoint.global_transform.origin-unit.position
				else:
					unit.direction = unit.LeftPoint.global_transform.origin-unit.position
				SFXMove.play()
				SFXShoot.play()
				UI.talk(unit.playerData.Name + " pass(shoot)" + ".",false)
				unit.shoot(Ball,true,Arrow.rotation.y, power, unit.direction)
				if AI_mode() == false and Global.isGuide == true:
					UI.Guide.check_guide(0)
					UI.Guide.check_guide(2)
			else:
				UI.talk(unit.playerData.Name + " move(takle)" + ".",false)
				SFXMove.play()
				unit.shoot(Ball,false,Arrow.rotation.y, power, unit.direction)
				if AI_mode() == false and Global.isGuide == true:
#					UI.Guide.check_guide(4)
					UI.Guide.check_guide(3)

func player_set_stats() -> void:
	units = get_tree().get_nodes_in_group("units")
	## MatchDetail
	for unit in units:
		unit.canGoal = false
	for unit in selected_units:
		if check_ball_on_player() == true:
			## MatchDetail pass shoot
			unit.canGoal = true
			unit.matchPasses += 1
			teamPass[teamSelect-1] += 1
			unit.canAssit = time
		else:
			## MatchDetail def
			playerKick = []
			unit.matchMoves += 1
			teamDef[teamSelect-1] += 1

func player_set_stats_goal(value:int) -> void:
	timeGoals.append([Ball.replay_data.pos.size(),time,selected_units[0]])
	## Goal
	for unit in units:
#		if unit.playerPositionMath != "GK":
			if unit.canGoal == true and unit.team == value:
				unit.matchGoals += 1
				unit.timeGoals.append(time)
				UI.update_player_goal_info(unit,"Goal")
		#print("Own Goal")
			elif unit.canGoal == true and unit.team != value:
				unit.matchOwnGoals += 1
				UI.update_player_goal_info(unit,"OwnGoal")
	
	##Assits
	for unit in units:
		if unit.canAssit == (time - 2) and unit.team == value:
			unit.matchAssits += 1
	
	##Mistakes
		elif unit.canAssit == (time - 1) and unit.team != value:
			if time > 1 or time > gameRound + timePlus + 1:
				unit.matchMistakes += 1

func player_set_gk_save() -> void:
	if isGameTime == 1:
		if teamSelect == 1:
			gkGoal = GoalA
			gkArrow = Arrow.rotation_degrees.y+90
		else:
			gkGoal = GoalB
			gkArrow = -(Arrow.rotation_degrees.y-90)
	else:
		if teamSelect == 1:
			gkGoal = GoalA
			gkArrow = -(Arrow.rotation_degrees.y+90)
		else:
			gkGoal = GoalB
			gkArrow = (Arrow.rotation_degrees.y-90)
	gkBall = Ball.position
	gkDis = gkBall.distance_to(gkGoal.position)
	gkSave = AI_gk_save_pos(gkBall,gkArrow,gkGoal)

## Cac ham xu ly tin hieu delay
func _on_Timer_timeout() -> void:
	units = get_tree().get_nodes_in_group("units")
	match timerValue:
		"GoalA":
			change_state(SET_GAME)
			set_goal_col(false)
			pos_reset_players()
			Calculate.timer(TimerStartGame,3)
			timerValue = ""
#			if Global.gameModeCur < 2 and time != gameRound:
			if Global.gameModeCur < 2:
				await get_tree().create_timer(4).timeout
				Replay.play_quick_replay()
				Replay.replayTurns = 100
		"GoalB":
			change_state(SET_GAME)
			set_goal_col(false)
			pos_reset_players()
			Calculate.timer(TimerStartGame,3)
			timerValue = ""
#			if Global.gameModeCur < 2 and time != gameRound:
			if Global.gameModeCur < 2:
				await get_tree().create_timer(4).timeout
				Replay.play_quick_replay()
				Replay.replayTurns = 100
		"KickA":
			pos_reset_gk(1)
			pos_reset_gk(2)
			Ball.linear_velocity = Vector3(0,0,0)
			Ball.angular_velocity = Vector3(0,0,0)
			GlobalTween.pos_dir(Ball,BallKickA.global_transform.origin)
			timerValue = ""
			set_goal_col(false)
			isStartGame = true
		"KickB":
			pos_reset_gk(1)
			pos_reset_gk(2)
			Ball.linear_velocity = Vector3(0,0,0)
			Ball.angular_velocity = Vector3(0,0,0)
			GlobalTween.pos_dir(Ball,BallKickB.global_transform.origin)
			timerValue = ""
			set_goal_col(false)
			isStartGame = true

## Cac ham xu ly ban thang
func _on_GoalA_body_entered(body) -> void:
	if goalCheck == true and Replay.isPlayReplay == false:
		if body == Ball:
			player_set_stats_goal(1)
			GoalA.NetSound.play()
			TimerGame.wait_time = 1
			timerValue = "GoalA"
			TimerGame.start()
			isStartGame = false
			Notification.create_achi(6,"Frist Goal Achievement", ["Your first goal in MGF"])
			goalCheck = false
			Calculate.vibrate_set()
			Cam.apply_random_shake()
			set_goal_col(true)
			TeamA_score += 1
			teamGoal[0] += 1
			teamGoalC[1] += 1
			if teamSelect == 1:
				teamSelect = 2
#			if !Global.device_is_mobile():
#				effGame.play()
			UI.update_Team_GoalA(TeamA_score)
			if Global.isGuide == true:
#				UI.Guide.check_guide(5)
				UI.Guide.check_guide(4)

func _on_GoalB_body_entered(body) -> void:
	GoalB.NetSound.play()
	if goalCheck == true and Replay.isPlayReplay == false:
		if body == Ball:
			player_set_stats_goal(2)
			TimerGame.wait_time = 1
			timerValue = "GoalB"
			TimerGame.start()
			isStartGame = false
			goalCheck = false
			Calculate.vibrate_set()
			Cam.apply_random_shake()
			set_goal_col(true)
			TeamB_score += 1
			teamGoal[1] += 1
			teamGoalC[0] += 1
			if teamSelect == 2:
				teamSelect = 1
#			if !Global.device_is_mobile():
#				effGame.play()
			UI.update_Team_GoalB(TeamB_score)

func set_goal_col(value:bool = false) -> void:
	$GoalA/CollisionShape3D.disabled = value
	$GoalB/CollisionShape3D.disabled = value
	$GoalA/KickingBall/CollisionShape3D.disabled = value
	$GoalA/KickingBall/CollisionShape2.disabled = value
	$GoalB/KickingBall/CollisionShape3D.disabled = value
	$GoalB/KickingBall/CollisionShape2.disabled = value

## Cac ham xu ly khi bong di ra ngoai
func _on_KickingBallA_body_entered(body) -> void:
	if body == Ball and Replay.isPlayReplay == false:
		isStartGame = false
		set_goal_col(true)
		timerValue = "KickA"
		TimerGame.start()

func _on_KickingBallB_body_entered(body) -> void:
	if body == Ball and Replay.isPlayReplay == false:
		isStartGame = false
		set_goal_col(true)
		timerValue = "KickB"
		TimerGame.start()

## Cac che do dieu khien
func _input(event):
	select_unit_input(event)
	cam_touch_inut(event)
	
	if (AI_mode() == false and 
	Replay.isPlayReplay == false and 
	isStartGame == true and 
	UI.newTurn.check_turn() == true and
	isStartTurn == true):
		player_swipe_shoot_input(event)

## Cac ham cam ung
func player_swipe_shoot_input(event) -> void:
	if event is InputEventSingleScreenSwipe:
		UI.newTurn.isStart = false
		isStartTurn = false
		power = 0
		player_set_physics()
		
		var relative:float = event.relative.length()
		power = remap(relative,0,600,0,100)
		power = clamp(power,0,100)
		var angle = -rad_to_deg(event.relative.angle())-90
		
		if check_ball_on_player() == true:
			for unit in selected_units:
				var stats:float = remap(unit.statAccurate,40,100,10,0)
				stats = clamp(stats,0,20)
				var powerAccurate:float = remap(power,70,100,0,5)
				powerAccurate = clamp(powerAccurate,0,10)
				var accurate:float = stats + powerAccurate
				accurate = clamp(accurate,0,20)
				AIShootAngle = Calculate.rand_num(accurate)
		else:
			AIShootAngle = 0
		
		if angle < -180:
			angle = abs(360+angle)
		
		Arrow.rotation_degrees.y = angle + AIShootAngle
		
		change_state(SET_ANGLE)
		AI_player_angle_set()
		await get_tree().create_timer(0.5).timeout
		
		change_state(SET_POWER)
		AI_player_shot_pos_set()
		if check_ball_on_player() == true:
			await get_tree().create_timer(1.0).timeout
		
		change_state(SET_SHOOT)

func cam_touch_inut(event) -> void:
	if event is InputEventScreenPinch:
		var zoom = event.relative
		var delta:float = 0.025
		var lm:float = 10
		if ((Cam.position.y > camPos.y - lm) and (Cam.position.y < camPos.y + lm)):
			Cam.position.y -= zoom*delta
		else:
			Cam.position.y = camPos.y
	elif event is InputEventMultiScreenDrag:
		var pos = event.relative
		var delta:float = 0.025
		var lm:float = 10
		if ((Cam.position.x >camPos.x -lm) and (Cam.position.x <camPos.x+lm)):
			Cam.position.x += pos.x*delta
		else:
			Cam.position.x = camPos.x
		if ((Cam.position.z>camPos.z-lm) and (Cam.position.z<camPos.z+lm)):
			Cam.position.z += pos.y*delta
		else:
			Cam.position.z = camPos.z

## Cac ham xu ly di chuyen
func target_control_input(delta) -> void:
	if Global.isAIState:
		var speedPlayer:float = 1 * delta
		var unit: = $AITest/Target
		
		## Di chuyen len xuong
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			unit.position.z = unit.position.z
		elif Input.is_action_pressed("ui_up"):
			unit.position.z -= speedPlayer
		elif Input.is_action_pressed("ui_down"):
			unit.position.z += speedPlayer
		## Di chuyen sang ngang
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			unit.position.x = unit.position.x
		elif Input.is_action_pressed("ui_left"):
			unit.position.x -= speedPlayer
		elif Input.is_action_pressed("ui_right"):
			unit.position.x += speedPlayer
		## Xoay
		if Input.is_action_pressed("cam_zoom_in") and Input.is_action_pressed("cam_zoom_out"):
			unit.rotation_degrees.y = unit.rotation_degrees.y
		elif Input.is_action_just_released("cam_zoom_in"):
			unit.rotation_degrees.y += speedPlayer
		elif Input.is_action_just_released("cam_zoom_out"):
			unit.rotation_degrees.y -= speedPlayer

##  Cac ham tinh toan chon cau thu
func select_unit_input(event) -> void:
	if event is InputEventSingleScreenTap:
		var m_pos: = get_viewport().get_mouse_position()
		unit_under_mouse_get(m_pos,false)
		if Global.isGuide == true:
			UI.Guide.check_guide(1)
	if AI_mode() == false and state == SET_PLAYER and UI.newTurn.check_turn() == true:
		if event is InputEventSingleScreenTap:
			var m_pos: = get_viewport().get_mouse_position()
			unit_select(m_pos)

func unit_select(m_pos) -> void:
	var new_selected_units: = []
	var u = await unit_under_mouse_get(m_pos)
	if u != null:
		new_selected_units.append(u)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units

func unit_under_mouse_get(m_pos:Vector2,value:bool = true):
	var result = unit_raycast_from_mouse(m_pos, 1)
	if result != {}:
		if isStartGame == true:
			if value == true:
				if result.collider.team == teamSelect:
					if result.collider.playerPositionMath != "NON":
						return result.collider
			else:
				result.collider.SelectMesh.mesh_select(0.8)
				await get_tree().create_timer(1).timeout
				result.collider.SelectMesh.mesh_select(0)
				if result.collider.team == teamSelect:
					result.collider.SelectMesh.mesh_select(0.25)
				UI.update_player_data(result.collider)
				return result.collider
		else:
			return result.collider

func unit_raycast_from_mouse(m_pos, collision_mask):
	var ray_start = Cam.project_ray_origin(m_pos)
	var ray_end = ray_start + Cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_start
	params.to = ray_end
	params.exclude = []
	params.collision_mask = collision_mask
	
	return space_state.intersect_ray(params)

## Dieu khin khac
func cam_follow_ball() -> void:
	if camFollowBall == true:
		if Ball.linear_velocity.length() > 1.0:
			Cam.position.x = Ball.transform.origin.x
			Cam.position.z = Ball.transform.origin.z

func arrow_pos(value:bool = false,obj = "") -> void:
	for unit in selected_units:
		if check_ball_on_player() == true:
			if value == false:
				Arrow.position.x = Ball.position.x
				Arrow.position.z = Ball.position.z
			else:
				Arrow.position.x = obj.position.x
				Arrow.position.z = obj.position.z
		else:
			Arrow.position.x = unit.position.x
			Arrow.position.z = unit.position.z

func _on_ButtonHome_pressed() -> void:
	if SeasonData.check_season_mode() == true:
		if isGameTime == 3 or Global.check_match_mode() == false:
			Notification.push_noti(1,"Exit Match")
			Notification.btnYes.connect("pressed", Callable(self, "finish_match"))
			Notification.btnNo.connect("pressed", Callable(self, "noti_disconnect"))
		else:
			Notification.push_noti(1,"Exit lose match and lost reward")
			Notification.btnYes.connect("pressed", Callable(self, "quit_match"))
			Notification.btnNo.connect("pressed", Callable(self, "noti_disconnect"))
	else:
		Notification.push_noti(1,"Exit Match")
		Notification.btnYes.connect("pressed", Callable(self, "leave_match"))
		Notification.btnNo.connect("pressed", Callable(self, "noti_disconnect"))
	
	FormationData.CanFormation = false

func noti_disconnect() -> void:
	Notification.btnNo.disconnect("pressed", Callable(self, "noti_disconnect"))
	if Notification.btnYes.is_connected("pressed", Callable(self, "leave_match")):
		Notification.btnYes.disconnect("pressed", Callable(self, "leave_match"))
	if Notification.btnYes.is_connected("pressed", Callable(self, "quit_match")):
		Notification.btnYes.disconnect("pressed", Callable(self, "quit_match"))
	if Notification.btnYes.is_connected("pressed", Callable(self, "finish_match")):
		Notification.btnYes.disconnect("pressed", Callable(self, "finish_match"))

func leave_match() -> void:
	if Notification.btnYes.is_connected("pressed", Callable(self, "leave_match")):
		Notification.btnYes.disconnect("pressed", Callable(self, "leave_match"))
	SoundGlobal.UI.show()
	SoundGlobal.volume_normal()
	var settingsData = GameData.get_data(GameData.setting_data_path).gameMode
	timeOutMode = settingsData
	# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/QuickMatch/QuickMatch.tscn")

func quit_match() -> void:
	if Global.gameModeCur == 1:
		Global.isQuit = true
		UI.season_match_list_active()
		if Notification.btnYes.is_connected("pressed", Callable(self, "quit_match")):
			Notification.btnYes.disconnect("pressed", Callable(self, "quit_match"))
	else:
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
		SeasonData.TabManager = 0

func finish_match() -> void:
	if Global.gameModeCur == 1:
		await get_tree().create_timer(0).timeout
		# warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
		if Notification.btnYes.is_connected("pressed", Callable(self, "finish_match")):
			Notification.btnYes.disconnect("pressed", Callable(self, "finish_match"))
	else:
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
		SeasonData.TabManager = 0

func _exit_tree():
	Global.weather_setup()
	FormationData.AI_random_tactical()
	FormationData.isSub = false
	queue_free()
	Engine.time_scale = 1.0
	get_tree().paused = false

func sub_change() -> void:
	var data = GameData.formation_load_data()
	var playerData = data.players
	units = get_tree().get_nodes_in_group("units")
	
	## Lay tat ca vi tri player
	var position: = []
	for i in FormationData.teamMain1.size():
		var main =  FormationData.teamMain1[i]
		for unit in units:
			if unit.playerID == main:
				position.append(unit.position)
	
	## Doi vi tri cho tat ca cau thu
	for i in FormationData.teamSub1.size():
		var posPlay = FormationData.teamPos1[i]
		
		var sub = FormationData.teamSub1[i]
#		var main = FormationData.teamMain1[i]
		
		for unit in units:
			unit.show()
			if unit.playerID == sub:
				unit.playerPositionMath = posPlay
				## Cau thu ra ngoai
				unit.SelectMesh.mesh_select(0)
				GlobalTween.pos_dir(unit,position[i])
				unit.position.y = 0
				unit.player_set_stop()
				
				if unit.playerID in FormationData.teamOut1 and FormationData.teamOut1.size()>0:
					playerData[unit.playerID].isSub[0] = false
					GameData.formation_save_data(data)
	
	## Ket thuc thay nguoi
	FormationData.isSub = false
	for unit in teamA:
		if playerData[unit.playerID].isSub[0] == false:
			unit.playerPositionMath = "NON"

func sub_change_start() -> void:
#	print("Pos    ",FormationData.teamPos1)
#	print("Base   ",FormationData.teamMain1)
#	print("Change ",FormationData.teamSub1)
#	print("Player in is ",FormationData.teamIn1)
#	print("Player out is ",FormationData.teamOut1)
	var checkSub:int
	var checkTac:int
	if Global.MatchPlay == 1:
		checkSub = teamAData[0]
		checkTac = teamAData[2]
	else:
		checkSub = teamBData[0]
		checkTac = teamBData[2]
	
	if FormationData.teamOut1.size()>0 and checkSub > 0:
		if FormationData.isSub == true:
			if Global.gameModeCur != 2:
				var timeOut = remap((time-FormationData.timeSub),1,4,100,0)
				UI.TeamAction.update_action(Global.MatchPlay,0,timeOut)
		
		if FormationData.isSub == true and Global.gameModeCur == 2:
			sub_change()
			pos_reset_players(true,1)
		elif FormationData.isSub == true and (time == FormationData.timeSub + 4):
			sub_change()
			if Global.MatchPlay == 1:
				teamAData[0] -= FormationData.teamOut1.size()
				UI.TeamAction.update_team_action(self,1)
			else:
				teamBData[0] -= FormationData.teamOut1.size()
				UI.TeamAction.update_team_action(self,2)
			UI.TeamAction.update_action(Global.MatchPlay,0,0)
	
	if FormationData.isTac == true and checkTac > 0:
		if Global.gameModeCur != 2:
			var timeOut = remap((time-FormationData.timeTac),1,4,100,0)
			UI.TeamAction.update_action(Global.MatchPlay,2,timeOut)
		if Global.gameModeCur == 2:
			FormationData.isTac = false
		elif time == FormationData.timeTac + 4:
			FormationData.isTac = false
			if Global.MatchPlay == 1:
				
				teamAData[2] -= 1
				UI.TeamAction.update_team_action(self,1)
			else:
				teamBData[2] -= 1
				UI.TeamAction.update_team_action(self,2)
			UI.TeamAction.update_action(Global.MatchPlay,2,0)
			pos_reset_tactic(false,Global.MatchPlay)

func pos_reset_tactic(value:bool = false, team:int = 0) -> void:
	change_state(SET_GAME)
	if isGameTime == 1:
		if team == 0 or team == 1:
			FormationData.reload_formation(1)
			playersPos = FormationData.get_formation()[FormationData.teamTac1]
			for unit in teamA:
				if unit.playerPositionMath != "NON":
					if units[find_player(3)] != unit:
						var pos = playersPos[unit.playerPositionMath]
						if value == false:
							GlobalTween.pos(unit,pos)
						else:
							unit.position = pos
		if team == 0 or team == 2:
			FormationData.reload_formation(2)
			playersPos = FormationData.get_formation()[FormationData.teamTac2]
			for unit in teamB:
				if unit.playerPositionMath != "NON":
					if units[find_player(3)] != unit:
						var pos = Vector3(-playersPos[unit.playerPositionMath].x,
						playersPos[unit.playerPositionMath].y,
						playersPos[unit.playerPositionMath].z)
						if value == false:
							GlobalTween.pos(unit,pos)
						else:
							unit.position = pos
	else:
		if team == 0 or team == 2:
			FormationData.reload_formation(2)
			playersPos = FormationData.get_formation()[FormationData.teamTac2]
			for unit in teamB:
				if unit.playerPositionMath != "NON":
					if units[find_player(3)] != unit:
						var pos = playersPos[unit.playerPositionMath]
						if value == false:
							GlobalTween.pos(unit,pos)
						else:
							unit.position = pos
			FormationData.reload_formation(1)
			playersPos = FormationData.get_formation()[FormationData.teamTac1]
		if team == 0 or team == 1:
			for unit in teamA:
				if unit.playerPositionMath != "NON":
					if units[find_player(3)] != unit:
						var pos = Vector3(-playersPos[unit.playerPositionMath].x,
						playersPos[unit.playerPositionMath].y,
						playersPos[unit.playerPositionMath].z)
						if value == false:
							GlobalTween.pos(unit,pos)
						else:
							unit.position = pos
