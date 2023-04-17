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
@onready var Cam:Camera3D = $Camera3D
@onready var Target = $AITest/Target
@onready var tween:Tween = get_tree().create_tween()
@onready var SoundBg:AudioStreamPlayer = get_parent().get_node("/root/SoundBg")
@onready var SFXMove:AudioStreamPlayer = $PlayerMovingSFX
@onready var SFXShoot:AudioStreamPlayer = $PlayerShootSFX

@onready var TimerGame:Timer = $Timer
@onready var TimerStop:Timer = $TimerStop
@onready var TimerSub:Timer = $TimerSub
@onready var TimerStartGame:Timer = $TimerStartGame
@onready var TimerNewTurn:Timer = $TimerNewTurn
@onready var TimerSaveReplay:Timer = $TimerSaveReplay
@onready var TimerPlayReplay:Timer = $TimerPlayReplay
@onready var AITimer:Timer = $AITimer

#@onready var effGame:EffekseerEmitter = $EffekseerEmitter
#@onready var effGoalA:EffekseerEmitter = $GoalA/EffekseerEmitter
#@onready var effGoalB:EffekseerEmitter = $GoalB/EffekseerEmitter

# Players Unit
@onready var units:Array = get_tree().get_nodes_in_group("units")
@onready var teamA:Array = get_tree().get_nodes_in_group("team1")
@onready var teamB:Array = get_tree().get_nodes_in_group("team2")

# Global var
var time:int = 0 ## Luot dau
var teamSelect:int = 1 ##Set up luot dau doi dieu khien
var gameRound:int = Global.time[Global.SetTime]
var timePlus:int = Global.timePlus[Global.SetTime]

# Load doi hinh chien thuat
var formationMatch:Dictionary = FormationData.formationMatch
var formationBroad:Dictionary = FormationData.formationBroad

# Fouls
var teamAFoul:int = 0
var teamBFoul:int = 0
const maxFoul:int = 5

# Team Score
var goalCheck:bool = true
var TeamA_score:int = 0
var TeamB_score:int = 0

# Selection
const ray_length:int = 1000
var selected_units:Array = []
var selected_player:Array = []

# Check, data
var timeGoals:Array = []
var isSaveReplay:bool = true
var isPlayReplay:bool = false
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
var id:int = 0 #Cauthu
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

var data:Dictionary
var teamAName
var teamBName
var iconTeamA
var iconTeamB

# Timmer Value
var timerValue:String = ""
# Timmer Change Value
var timerAI:int = 0

var timePlayReplay:int
var teamPlayReplay:int
var replayCount:int = 0
var replayTurns:int = 0

# Load cau thu 2 team chuan bi tran dau
func load_team_data():
	data = GameData.formation_load_data()
	teamAName = data.teams[Global.teamID1].name
	teamBName = data.teams[Global.teamID2].name
	iconTeamA = load(data.teams[Global.teamID1].icon)
	iconTeamB = load(data.teams[Global.teamID2].icon)

func load_team_formation_data(value, number):
	data = GameData.formation_load_data()
	var teamData = data.teams[value].Fid
	var playerData
	var playerPath
	var playerIns
	if teamData.size()>0:
		playerData = teamData[0]
		playerPath = data.players[playerData].filePath
		
		## Tao team group
		Global.team = number
		## Tao cau thu
		for i in teamData.size():
			playerData = teamData[i]
			playerPath = data.players[int(playerData)].filePath
			## Load file cau thu
			playerIns = load(playerPath).instantiate()
			## Lay data cho cau thu
			playerIns.playerID = int(teamData[i])
			add_child(playerIns)

func create_player_signal():
	var x = -1
	for unit in units:
		if unit.playerPositionMath == "NON":
			unit.position.x = x
			unit.position.z = -5
			x += 0.5
			unit.player_is_collision(true)
		
		if unit.team == 1:
			unit.add_to_group("team1")
			
		elif unit.team == 2:
			unit.add_to_group("team2")
			
		teamA = get_tree().get_nodes_in_group("team1")
		teamB = get_tree().get_nodes_in_group("team2")
		
		unit.find_targets()

func load_stadium():
	$Map/Field.material_override = Global.fieldMat[Global.staCur]

func load_ball():
	var ball = preload("res://MGF Scene/AssetsScene3D/Ball.tscn")
	var ballIns = ball.instantiate()
	add_child(ballIns)
	Ball = ballIns

## Istance 2 team duoc chon vao
func _init():
	load_team_formation_data(Global.teamID1,1)
	load_team_formation_data(Global.teamID2,2)

func signal_connect():
	$TimerStartGame.connect("timeout",Callable(self,"_on_TimerStartGame_timeout"))
	$TimerNewTurn.connect("timeout",Callable(self,"_on_TimerNewTurn_timeout"))
	$TimerStop.connect("timeout",Callable(self,"_on_TimerAllStop_timeout"))
	$AITimer.connect("timeout",Callable(self,"_on_AITimer_timeout"))
	$Timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
	$TimerSub.connect("timeout",Callable(self,"_on_TimerSub_timeout"))
	
	GkA.connect("body_entered",Callable(self,"_on_GkA_body_entered"))
	GkB.connect("body_entered",Callable(self,"_on_GkB_body_entered"))
	
	GoalA.connect("body_entered",Callable(self,"_on_GoalA_body_entered"))
	GoalB.connect("body_entered",Callable(self,"_on_GoalB_body_entered"))
	
	KickingBallA.connect("body_entered",Callable(self,"_on_KickingBallA_body_entered"))
	KickingBallB.connect("body_entered",Callable(self,"_on_KickingBallB_body_entered"))
	
	$TimerPlayReplay.connect("timeout",Callable(self,"_on_TimerPlayReplay_timeout"))
	$TimerSaveReplay.connect("timeout",Callable(self,"_on_TimerSaveReplay_timeout"))
	UI.videoPlayer.btnClose.connect("pressed",Callable(self,"_on_BtnReplayClose_pressed"))
	UI.videoPlayer.btnTimeLine.connect("value_changed",Callable(self,"_on_BtnVideoReplaySlider_value_changed"))
#	UI.videoPlayer.btnNextRight
#	UI.videoPlayer.btnNextLeft
	
	UI.matchDetail.btnHome.connect("pressed",Callable(self,"_on_ButtonHome_pressed"))
	UI.matchDetail.btnClose.connect("pressed",Callable(self,"_on_ButtonExit_pressed"))
	UI.matchDetail.btnQuit.connect("pressed",Callable(self,"_on_ButtonExit_pressed"))

func _ready():
	signal_connect()
	Global.autoMode = false
	load_team_data()
#	time = Global.time[Global.SetTime] - 1
#	time = 44
	camPos = Cam.position
	Arrow.hide()
	SoundBg.stop()
	load_game_mode()
	UI.update_team_stats()
	create_player_signal()
	load_stadium()
	player_set_physics()
	change_player()
	pos_reset_players()
	Calculate.timer(TimerStartGame,1)

## Game Mode:
func load_game_mode():
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		Global.MatchPlay = SeasonData.MatchPlay
	if !Global.device_is_mobile() and Global.gameModeCur == 3:
		$AITest/Target.position.z = 0
		$AITest/Target.show()
	UI.controller.hide()
	UI.panelStats.visible = false
	camFollowBall = true
	Arrow.hide()
	
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
					unit.hide()
		3:#Test Mode
			UI.get_node("TestMode").load_test_mode(camFollowBall,startBall,units)

func _process(delta):
	if !Global.device_is_mobile():
		target_control_input(delta)

func load_debug_log():
	if get_tree().get_root().has_node("DebugLog"):
		DebugLog.team = teamSelect
		DebugLog.state = str(state)

## Xu ly chuyen luot
func _on_TimerStartGame_timeout():
	pos_reset_hold_ball()
	change_player()
	Calculate.timer(TimerStop,3)
	await get_tree().create_timer(2).timeout
	isStartGame = true

func _on_TimerNewTurn_timeout():
	Calculate.timer(TimerStop,2)
	if teamSelect == 1:
		teamSelect = 2
	else:
		teamSelect = 1

func _on_TimerAllStop_timeout():
	for unit in units:
		unit.textBox.hide()
	change_state(SET_IDLE)
	pos_all_stop()
	goalCheck = true
	UI.newTurn.start_time()
	change_team()
	change_state(SET_PLAYER)
	change_game()

## Thay doi team duoc dieu khien
func change_game():
	## Bat dau hiep hai
	if time == gameRound:
		isStartGame = false
# warning-ignore:return_value_discarded
		## Setup hiep 2
		isGameTime = 2
		GoalA.position.x = -2.845
		GoalB.position.x = 2.845
		GoalA.rotation_degrees.y = -180
		GoalB.rotation_degrees.y = 0
		Calculate.vibrate_set()
		stamina_set(20)
		teamSelect = 2
		pos_reset_players()
		Calculate.timer(TimerStartGame,1)
		await get_tree().create_timer(3).timeout
		UI.match_detail_visible(2)
	## Het gio
	if time == (gameRound*2) or teamAFoul == maxFoul or teamBFoul == maxFoul:
		isStartGame = false
		isGameTime = 3
		UI.videoPlayer.btnClose.hide()
		play_replay(0)
		Calculate.vibrate_set()
		stamina_set(20)
		UI.update_Game("FullTime")
		await get_tree().create_timer(5).timeout
		UI.match_detail_visible(2)
		update_noti_match_results()
		if TeamA_score > TeamB_score:
			UI.update_team_ui(UI.teamAMat)
		elif TeamA_score > TeamB_score:
			UI.update_team_ui(UI.teamBMat)

func change_team():
	if isStartGame == true:
		pos_reset_y()
		AI_gk_check_reset()
		if Global.gameModeCur != 3:
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
			if Global.isShootTest and shotTime > 10:
				UI.update_Notification(null,"Result: " + str(shotGoal) +" %",0)
				UI.get_node("TestMode").show()
		
		UI.update_Times(time)
		if time == gameRound+1:
			UI.update_Game("HalfTime")
		
		for unit in units:
			if unit.playerPositionMath != "NON":
				unit.timeRecovery += 1
				unit.statsPlayTime += 1
		
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

func change_player():
	units = get_tree().get_nodes_in_group("units")
	if Global.isStamina == true:
		stamina_return()
	for unit in units:
		selected_units.clear()
		unit.deselect()
		unit.textBox.hide()
		
		var playerSelect = units[find_player(teamSelect)]
		playerSelect.select()
		selected_player.append(playerSelect)
		selected_units.append(playerSelect)
		
		update_player_stats()

## Kiem tra cau thu co giu bong
func check_ball_on_player():
	for unit in selected_units:
		if units[find_player(3)] == unit:
			return true
		else:
			return false

func check_ball_on_team():
	var value
	for unit in units:
		if units[find_player(3)] == unit:
			value = unit.team
	return value

func check_team_has_player(team):
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

func check_team_player():
	if check_team_has_player(1) == false:
		teamSelect = 2
	elif check_team_has_player(2) == false:
		teamSelect = 1

func check_game_has_gk(value):
	match value:
		0:
			units = get_tree().get_nodes_in_group("units")
		1:
			units = get_tree().get_nodes_in_group("team1")
		2:
			units = get_tree().get_nodes_in_group("team2")
	var check = false
	for unit in units:
		if unit.playerPositionMath == "GK":
			check = true
	return check

func find_player(value,obj = Ball):
	var INT_MAX = 99
	var i = 0
	var a
	var least_diff = INT_MAX
	if value == 1:
		units = get_tree().get_nodes_in_group("team1")
	elif value == 2:
		units = get_tree().get_nodes_in_group("team2")
	else:
		units = get_tree().get_nodes_in_group("units")
	for unit in units:
		i +=1
		var diff = abs(obj.position.distance_to(unit.position+unit.AIMPOS))

		if(diff < least_diff):
			least_diff = diff
			a = i
#	if units[a-1].playerPositionMath == "GK":
#		if teamSelect == 1:
#			gkAReset = 0
#		else:
#			gkBReset = 0
	return a-1

## Lay du lieu
func get_unit():
	for unit in selected_units:
		return unit

# warning-ignore:unused_argument
func get_unit_gk(value = 0,pos = 0):
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.playerPositionMath == "GK":
			if unit.team == value:
				return unit

func get_ball_to_target():
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
func pos_reset_hold_ball():
	check_team_player()
	units = get_tree().get_nodes_in_group("units")
	if Global.gameModeCur != 3:
#		print("1WTF")
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
					UI.get_node("TestMode").get_player_foot_fix(fixA)
					UI.get_node("TestMode").get_player_foot_size(unit.FootSizeR*1000)
				else:
					UI.get_node("TestMode").get_player_foot_fix(fixB)
					UI.get_node("TestMode").get_player_foot_size(-unit.FootSizeL*1000)

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

func pos_reset_players():
	change_state(SET_GAME)
	GlobalTween.pos(Ball,startBall.position)
	Ball.linear_velocity = Vector3.ZERO
	Ball.angular_velocity = Vector3.ZERO
	if isGameTime == 1:
		playersPos = formationMatch[FormationData.teamFor1]
		for unit in teamA:
			if unit.playerPositionMath != "NON":
				var pos = playersPos[unit.playerPositionMath]
				GlobalTween.pos(unit,pos)
		
		playersPos = formationMatch[FormationData.teamFor2]
		for unit in teamB:
			if unit.playerPositionMath != "NON":
				var pos = Vector3(-playersPos[unit.playerPositionMath].x,
				playersPos[unit.playerPositionMath].y,
				playersPos[unit.playerPositionMath].z)
				GlobalTween.pos(unit,pos)
	else:
		playersPos = formationMatch[FormationData.teamFor2]
		for unit in teamB:
			if unit.playerPositionMath != "NON":
				var pos = playersPos[unit.playerPositionMath]
				GlobalTween.pos(unit,pos)
		
		playersPos = formationMatch[FormationData.teamFor1]
		for unit in teamA:
			if unit.playerPositionMath != "NON":
				var pos = Vector3(-playersPos[unit.playerPositionMath].x,
				playersPos[unit.playerPositionMath].y,
				playersPos[unit.playerPositionMath].z)
				GlobalTween.pos(unit,pos)

func pos_reset_gk(value):
	if value == 1:
		gkAReset = 0
		playersPos = formationMatch[FormationData.teamFor1]
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
		playersPos = formationMatch[FormationData.teamFor2]
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

func pos_reset_y():
	if Global.isFixPosY == true:
		for unit in units:
			unit.position.y = 0

func pos_all_stop():
	units =  get_tree().get_nodes_in_group("units")
	Ball.linear_velocity = Vector3.ZERO
	Ball.angular_velocity = Vector3.ZERO
	if Global.gameModeCur == 3:
		Ball.position = startBall.position
	for unit in units:
		selected_units.clear()
		unit.deselect()
		if unit.playerPositionMath != "NON" and unit.playerPositionMath != "GK":
			unit.player_set_stop(tween)
			var pos = Ball.position - units[find_player(3)].AIMPOS
			GlobalTween.pos_dir(units[find_player(3)],pos)
		if unit.playerPositionMath == "GK":
			unit.player_set_stop(tween)

## Cac ham tinh toan
func update_powerbar(value):
	for unit in selected_units:
		unit.textBox.update_powerbar(value)

func stamina_set(value):
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.playerPositionMath != "NON":
			unit.statEnergy += value
			if unit.statEnergy > 100:
				unit.statEnergy = 100
			unit.player_set_stamina()
		else:
			unit.statEnergy += value*1.5
			if unit.statEnergy > 100:
				unit.statEnergy = 100
			unit.player_set_stamina()

func stamina_return():
	for unit in units:
		if unit.playerPositionMath != "NON":
			unit.player_set_stamina()

func player_col_active(value):
	pass
#	Ball.set_collision_mask_value(1,value)
#	for unit in units:
#		unit.set_collision_mask_value(1,value)
#		unit.set_collision_mask_value(2,value)

## Cac che do trong man choi
# Cac chuc nang trong tung che do choi
func change_state(new_state):
	state = new_state
	load_debug_log()
	player_col_active(false)
	match state:
		SET_GAME:
			replay_is_save(true)
			camFollowBall = false
		SET_IDLE:
			replay_is_save(true)
			camFollowBall = false
			player_col_active(true)
			AI_set_idle()
		SET_PLAYER:
			replay_is_save(false)
			AI_set_player()
		SET_AIM:
			replay_is_save(false)
			AI_set_aim()
		SET_ANGLE:
			replay_is_save(false)
			AI_set_angle()
		SET_POWER:
			replay_is_save(true)
			get_ball_to_target()
			AI_set_power()
		SET_SHOOT:
			UI.newTurn.isStart = false
			replay_is_save(true)
			player_col_active(true)
			update_powerbar(power)
			player_set_physics()
			player_set_stats()
			player_set_shoot()
			## NewTurn
			_on_TimerNewTurn_timeout()

## Seup AI mode
func AI_mode():
	var value = false
	match Global.gameModeCur:
		0:#Player vs Player
			show_pc_input()
		1:#Player vs AI
			if teamSelect == Global.MatchPlay:
				show_pc_input()
			else:
				value = true
				UI.controller.hide()
			if Global.autoMode == true:
				value = true
		2:#Trainng
			if teamSelect == Global.MatchPlay:
				show_pc_input()
			else:
				value = true
				UI.controller.hide()
			if Global.autoMode == true:
				value = true
		3:#Test Mode
			value = true
			UI.controller.hide()
	return value

## Tinh toan truoc khi thuc hien hanh dong cho AI
func AI_return_target():
	match Global.AIState:
		0:#AI_PASS
			if teamSelect == 1:
				units = get_tree().get_nodes_in_group("team1")
			else:
				units = get_tree().get_nodes_in_group("team2")
			Target = units[id]
		1:#AI_CREATE
			if teamSelect == 1:
				units = get_tree().get_nodes_in_group("team1")
			else:
				units = get_tree().get_nodes_in_group("team2")
			Target = units[id]
		2:#AI_SHOOT
			Target = get_unit().goal
		3:#AI_MOVE
			Target = get_unit().goal
		4:#AI_FIGHT
			Target = Ball
		5:#AI_DEF
			if teamSelect == 1:
				units = get_tree().get_nodes_in_group("team2")
			else:
				units = get_tree().get_nodes_in_group("team1")
			Target = units[id]
		6:#AI_CELEBRATE
			Target = Ball
	if Global.isDebug == true and Global.gameModeCur == 3:
		$AITest/Area3D.show()
		Target = $AITest/Target
	else:
		$AITest/Area3D.hide()
	return Target.position

func AI_check_target():
#	enum {AI_DEF, AI_MID, AI_ATK}
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

func AI_action():
	"""
	1 Check team
	2 Check player2goal: max: move2goal min: skip
	3 Check HoldBall:
	true:
		check ball2goal: max: pass,move2goal min: shot
	false:
		check ball2goal: max: move2goal move2ball min: move2ball
	"""
	if AI_mode() == true:
		Global.isAIState = true
		var b2g = 0
		var p2g = 0
		var goal
		
		## Check Team
		if teamSelect == 1:
			goal = GoalA
		else:
			goal = GoalB
		
		p2g = units[find_player(teamSelect,goal)].position.distance_to(goal.position)
		b2g = Ball.position.distance_to(goal.position)
		
		## Check player2goal
		#{AI_PASS, AI_CREATE, AI_SHOT, AI_MOVE, AI_FIGHT, AI_GOAL, AI_CELEBRATE}
		if Global.gameModeCur != 3:
			if p2g > 3:
				Global.AIState = 2
			else:
				if check_ball_on_player() == true:
					if b2g > 3:
						Global.AIState = 0
					else:
						Global.AIState = 2
				else:
					if b2g > 3:
						Global.AIState = 4
					else:
						Global.AIState = 4
		change_player()
		change_state_AI()
		id = Calculate.rand_a_num(4,7)

# AIState = {AI_PASS, AI_CREATE, AI_SHOOT, AI_MOVE, AI_FIGHT, AI_DEF, AI_CELEBRATE}
func change_state_AI():
	match Global.AIState:
		Global.AI_PASS:
			for unit in selected_units:
				unit.POWERCONTROLLER = remap(unit.statShotPower,40,100,2,4)
				AIPowerShot = remap(unit.statShotPower,40,100,100,70)
		Global.AI_CREATE:
			var tg = AI_return_target().z
			var ballPos = 0
			
			if tg<0:
				ballPos = remap(tg,1.5,-0.5,-1,0.5)
			elif tg>=0:
				ballPos = remap(tg,-1.5,0.3,-1.5,0)
			
			var newTarget = Vector3(AI_return_target().x,0,ballPos)
			Arrow.look_at(newTarget, transform.basis.y)
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

func _on_AITimer_timeout():
	if isPlayReplay == false and isStartGame == true:
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

func AI_draw_force_line(value:bool=true):
	if value:
		var m_pos = Cam.unproject_position(Ball.position)
		var target = Cam.unproject_position(AI_return_target())
		if check_ball_on_player() == false:
			for unit in selected_units:
				m_pos = Cam.unproject_position(unit.position)
		ClickEffect.drawForceAI.draw_line_force(m_pos,target,50,1.5)

## Chuyen hanh dong cho AI
func AI_set_idle():
	if AI_mode() == true:
		$AITimer.wait_time = 0.5
		timerAI = 0
		$AITimer.start()

func AI_set_player():
	if AI_mode() == true:
		$AITimer.wait_time = 2
		timerAI = 1
		$AITimer.start()

func AI_set_aim():
	if AI_mode() == true:
		change_state(SET_POWER)
		$AITimer.wait_time = 0.5
		timerAI = 2
		$AITimer.start()

func AI_set_angle():
	if AI_mode() == true:
		$AITimer.wait_time = 0.5
		timerAI = 3
		$AITimer.start()

func AI_set_power():
	if AI_mode() == true:
		$AITimer.wait_time = 1.5
		timerAI = 4
		$AITimer.start()

## Cac ham thuc hien hanh dong cho AI
func AI_find_foot():
#	if AI_mode() == true:
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

func AI_player_angle_start_set():
	for unit in selected_units:
		if Global.isAIState:
			Arrow.look_at(AI_return_target(), transform.basis.y)
			match Global.AIState:
				0:
					var dis = Ball.position.distance_to(AI_return_target())
					var stats = remap(unit.statAccurate,40,100,5,10)
					AIShootAngle = Calculate.rand_num(dis/stats)
					var accurate = AI_return_target()
					accurate.z += AIShootAngle
					Arrow.look_at(accurate, transform.basis.y)
				2:
# warning-ignore:shadowed_variable
					var gkDis:float = 0
					var gkZ:float = 0
					if teamSelect == 1:
						if check_game_has_gk(2):
							gkDis = get_unit_gk(2,0).position.distance_to(GoalA.position)
							gkZ = get_unit_gk(2,0).position.z
					else:
						if check_game_has_gk(1):
							gkDis = get_unit_gk(1,0).position.distance_to(GoalB.position)
							gkZ = get_unit_gk(1,0).position.z
					
					var angle = 0
					if Calculate.rand_num(1)>Calculate.rand_num(1):
						angle = 0.4
					else:
						angle = -0.4
					var rangeAngle = remap(ball2Target,0,5,0.1,0.2)
					var rangeAngleRan = Calculate.rand_num(rangeAngle)
					var accuAngle = remap(unit.statAccurate,40,100,0.1,0)
					var accuAngleRan = Calculate.rand_num(accuAngle)
					var accurate = AI_return_target()
					AIShootAngle = angle + accuAngleRan + rangeAngleRan
					
					if gkDis > 0.4:
						AIShootAngle = AIShootAngle/2
					if gkZ > 0.1:
						AIShootAngle = -abs(AIShootAngle)
					elif gkZ < -0.1:
						AIShootAngle = abs(AIShootAngle)
					
					accurate.z = AIShootAngle
					Arrow.look_at(accurate, transform.basis.y)

func AI_player_angle_set():
#	if AI_mode() == true:
# warning-ignore:shadowed_variable
		var AIShot
		var ranShot = 0
		if check_ball_on_player() == true:
			for unit in selected_units:
				var base = 100-(unit.statAccurate+unit.statShotPower)/2
				AIShot = remap(base,0,100,0,5)
				if Global.randomShot == true:
					ranShot = Calculate.rand_num(AIShot) + AIShootAngle
				else:
					ranShot += 0
			
			for unit in selected_units:
				var fixA = unit.FootFixR
				var fixB = unit.FootFixL
				if Global.gameModeCur == 3:
					if !Global.isAIState:
						fixA = Global.footFix
						fixB = Global.footFix
				var rot = Vector3.ZERO
				if isGameTime == 1:
					if unit.team == 1:
						if unit.Foot == 1:
							rot.y = fixA+(Arrow.rotation_degrees.y+90+ranShot)
						else:
							rot.y = -fixA+(Arrow.rotation_degrees.y+90+ranShot)
					elif unit.team == 2:
						if unit.Foot == 1:
							rot.y = fixB+(Arrow.rotation_degrees.y-90+ranShot)
						else:
							rot.y = -fixB+(Arrow.rotation_degrees.y-90+ranShot)
				else:
					if unit.team == 2:
						if unit.Foot == 1:
							rot.y = fixA+(Arrow.rotation_degrees.y+90+ranShot)
						else:
							rot.y = -fixA+(Arrow.rotation_degrees.y+90+ranShot)
					elif unit.team == 1:
						if unit.Foot == 1:
							rot.y = fixB+(Arrow.rotation_degrees.y-90+ranShot)
						else:
							rot.y = -fixB+(Arrow.rotation_degrees.y-90+ranShot)
				GlobalTween.rot_time(unit,rot,0.2)

func AI_player_power_set():
	if AI_mode() == true:
		change_state_AI()
		for unit in selected_units:
			var powerShot = AIPowerShot
			powerShot = clamp(powerShot,0,100)
			if check_ball_on_player() == true:
				var powerRange
				match Global.AIState:
					Global.AI_PASS:
						powerRange = remap(ball2Target,0,4,10,powerShot)
						var tar = AI_return_target().distance_to(Ball.position)
						var so = remap(tar,0,4,10,0) + (100-unit.statShotPower)/2
						powerRange += so
					Global.AI_SHOOT:
						powerRange = remap(ball2Target,0,3,50,powerShot)
				power = clamp(powerRange,0,powerShot)
				if Global.gameModeCur == 3:
					if Global.powerTest>10:
						power = Global.powerTest
					else:
						power = clamp(powerRange,0,powerShot)
			else:
				power = unit.SHOTPOWX

func AI_player_shot_pos_set():
#	if AI_mode() == true:
		var Foot2Ball #Khoang cach giua chan den bong
		for unit in selected_units:
			## Xet chan sut
			AI_find_foot()
			## Xet vi tri chuan
			if Global.gameModeCur != 3:
				if isGameTime == 1:
					if unit.team == 1:
						Foot2Ball = unit.FootSizeR
					else:
						Foot2Ball = -unit.FootSizeL
				else:
					if unit.team == 1:
						Foot2Ball = unit.FootSizeL
					else:
						Foot2Ball = -unit.FootSizeR
			else:
				Foot2Ball = Global.footSize/1000
			## Tim vi tri sut bong
			if check_ball_on_player() == true:
#				$DebugPoint.show()
				var pos = Vector3.ZERO
				if checkFoot == 1:
					pos = unit.RightPoint.global_transform.origin
				else:
					pos = unit.LeftPoint.global_transform.origin
				
				var fix = Vector3(unit.position.x - pos.x,0,unit.position.z - pos.z)
				var aimPoint = Vector3() #Vi tri diem sut bong can tim
				var goalPoint = Vector3() #Vi tri khung thanh can tim
				var Ball2Goal #Khoang cach bong den goal, de tim aimpoit: diem sut bong
				
				if unit.team == 1:
					goalPoint = GoalA.position
					Foot2Ball = Foot2Ball
				else:
					goalPoint = GoalB.position
					Foot2Ball = -Foot2Ball
				Ball2Goal = Ball.position.distance_to(goalPoint)
				
				if AI_mode() == true:
					if Global.isAIState:
						if Target.position.distance_to(GoalA.position)<checkRange:
							Foot2Ball = unit.FootSizeR
						else:
							Foot2Ball = unit.FootSizeL
						goalPoint = AI_return_target()
						Ball2Goal = Ball.position.distance_to(goalPoint)
				
				aimPoint = lerp(goalPoint, Ball.position, 1 + remap(Foot2Ball,0,Ball2Goal,0,1))
				var po = aimPoint+fix
				GlobalTween.pos_time(unit,po,0.5)

## Xu ly Ai cua thu mon
func _on_GkA_body_entered(body):
	if body == Ball and teamSelect == 2 and isPlayReplay == false:
		AI_gk_move(2)

func _on_GkB_body_entered(body):
	if body == Ball and teamSelect == 1 and isPlayReplay == false:
		AI_gk_move(1)

func AI_gk_move(GKteam):
	AI_gk_defend_stats(GKteam)
	AI_gk_move_stats(GKteam)

func AI_gk_move_stats(GKteam):
	var pos:Vector3 = Vector3.ZERO
	pos.z = gkSave
#	pos.x = 0
	for unit in units:
		if unit.playerPositionMath == "GK" and unit.team == GKteam:
			pos.x = unit.position.x
			var ballRangeGK = Ball.position.distance_to(unit.position+unit.AIMPOS)
			if ballRangeGK > 0.2:
				var GKDis = remap(gkDis,0,5,0,0.2)
				var save = remap(unit.statReflexes,40,100,0.2,0.7) + GKDis
# warning-ignore:shadowed_variable
				var dis =  abs(unit.position.z-pos.z)/5
				var time = remap(unit.statReflexes,40,100,0.2,0) + dis - GKDis
				time = clamp(time,0.0,1.0)
#				prints(gkDis,dis,time)
				pos.z = pos.z * save
				var s = unit.statSave/200+0.2
				pos.z = clamp(pos.z,-s,s)
#				print(save," ",Ball.position.z," ",pos.z)
				GlobalTween.pos_time(unit,pos,time)

func AI_gk_defend_stats(GKteam):
	for unit in units:
		if unit.playerPositionMath == "GK" and unit.team == GKteam:
			if unit.playerID != playerShotID:
				#Bong vs Goal
				gkGoalDis = unit.position.distance_to(gkGoal.position)
				var bDis = remap(gkDis,0,5,0.3,2.5)
				bDis = clamp(bDis,0.3,2.5)
				#GK vs Goal
				var gDis = remap(gkGoalDis,0.3,2,1,5)
				gDis = clamp(gDis,1,5)
				#Tinh def GK
				unit.playerDefend = ((unit.save_gk - AIShoot) * bDis)/gDis
				unit.playerDefend = clamp(unit.playerDefend,1,16)
				unit.player_defend_set()

# warning-ignore:unused_argument
func AI_gk_save_pos(ball,arrow,goal):
	var fix = gkBall.z/(gkDis)
	var result = (gkDis * tan(deg_to_rad(arrow))) - ball.z
	result = clamp(result,-0.6,0.6) - fix
	return -result

func AI_gk_check_reset():
	if check_game_has_gk(1) == true:
		var gkADis = get_unit_gk(1).position.distance_to(GoalB.position)
		if gkADis > 0.2 or  gkADis < 0.19:
			gkAReset += 1
			if gkAReset > 2:
				pos_reset_gk(1)
	if check_game_has_gk(2) == true:
		var gkBDis = get_unit_gk(2).position.distance_to(GoalA.position)
		if gkBDis > 0.2 or  gkBDis < 0.19:
			gkBReset += 1
			if gkBReset > 2:
				pos_reset_gk(2)

## Notification whenn change team
func notification_change_team():
	if teamSelect == 1:
		UI.update_Notification(iconTeamA, teamAName + " Turn")
	elif teamSelect == 2:
		UI.update_Notification(iconTeamB, teamBName + " Turn")

## Cac ham xu ly thong so cau thu
func player_set_physics():
	## Lay player tackle
	for unit in selected_units:
#		prints("shot",unit.physic_shot)
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
		unit.mass = 10
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

func player_set_shoot():
	isStartTurn = false
#	Ball.effTrail.play()
	player_set_gk_save()
	if state != 7:
		for unit in selected_units:
			unit.direction = unit.PivotPoint.position
#			unit.playerVfx.speed = 0.3
#			unit.playerVfx.play()
			if check_ball_on_player() == true:
				if checkFoot == 1:
					unit.direction = unit.RightPoint.global_transform.origin-unit.position
	#				unit.direction = unit.RightPoint.position
				else:
					unit.direction = unit.LeftPoint.global_transform.origin-unit.position
	#				unit.direction = unit.LeftPoint.position
				SFXMove.play()
				SFXShoot.play()
				unit.shoot(Ball,true,Arrow.rotation.y, power, unit.direction)
			else:
				SFXMove.play()
				unit.shoot(Ball,false,Arrow.rotation.y, power, unit.direction)

func player_set_stats():
	units = get_tree().get_nodes_in_group("units")
	## Tinh chi so matchdetail
	for unit in units:
		unit.canGoal = false
	for unit in selected_units:
		if check_ball_on_player() == true:
			unit.canGoal = true
	if check_ball_on_player() == true:
		for unit in selected_units:
			unit.gamePasses += 1
			unit.canAssit = time
	else:
		for unit in selected_units:
			unit.gameMoves += 1

func player_set_goals(value):
	timeGoals.append(Ball.replay_data.pos.size())
	var teamData = data.teams
	## Goal
	for unit in units:
		if unit.canGoal == true and unit.team == value:
			unit.statGoals += 1
			unit.gameGoals += 1
			unit.timeGoals.append(time)
			UI.update_player_goal_info(unit.playerName,unit.texturePlayerPath,4,"Goal",load(teamData[int(unit.playerTeam)].icon),unit.gameGoals)
	
	#print("Own Goal")
		elif unit.canGoal == true and unit.team != value:
			unit.statOwnGoals -= 1
			UI.update_player_goal_info(unit.playerName,unit.texturePlayerPath,4,"OwnGoal",load(teamData[int(unit.playerTeam)].icon),unit.gameGoals)
	
	##Assits
	for unit in units:
		if unit.canAssit == (time - 2) and unit.team == value:
			unit.statAssits += 1
			unit.gameAssits += 1
	
	##Mistakes
		elif unit.canAssit == (time - 1) and unit.team != value:
			if time > 1 or time > gameRound + timePlus + 1:
				unit.statMistakes -= 1

func player_set_gk_save():
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
func _on_Timer_timeout():
	units = get_tree().get_nodes_in_group("units")
	match timerValue:
		"GoalA":
			change_state(SET_GAME)
			player_set_goals(1)
			set_goal_col(false)
			pos_reset_players()
			Calculate.timer(TimerStartGame,1)
			timerValue = ""
			if Global.gameModeCur == 1:
				await get_tree().create_timer(3).timeout
				play_quick_replay()
				replayTurns = 100
		"GoalB":
			change_state(SET_GAME)
			player_set_goals(2)
			set_goal_col(false)
			pos_reset_players()
			Calculate.timer(TimerStartGame,1)
			timerValue = ""
			if Global.gameModeCur == 1:
				await get_tree().create_timer(3).timeout
				play_quick_replay()
				replayTurns = 100
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
func _on_GoalA_body_entered(body):
	if goalCheck == true and isPlayReplay == false:
		if body == Ball:
			TimerGame.wait_time = 1
			timerValue = "GoalA"
			TimerGame.start()
			isStartGame = false
			NotiData.create_achi(2,"Frist Goal Achievement", "Your first goal in MGF")
			goalCheck = false
			Calculate.vibrate_set()
			Cam.apply_random_shake()
#			if !Global.device_is_mobile():
#				effGoalA.play()
			set_goal_col(true)
			TeamA_score += 1
			if teamSelect == 1:
				teamSelect = 2
#			if !Global.device_is_mobile():
#				effGame.play()
			UI.update_Team_GoalA(TeamA_score)

func _on_GoalB_body_entered(body):
	if goalCheck == true and isPlayReplay == false:
		if body == Ball:
			TimerGame.wait_time = 1
			timerValue = "GoalB"
			TimerGame.start()
			isStartGame = false
			goalCheck = false
			Calculate.vibrate_set()
			Cam.apply_random_shake()
#			if !Global.device_is_mobile():
#				effGoalB.play()
			set_goal_col(true)
			TeamB_score += 1
			if teamSelect == 2:
				teamSelect = 1
#			if !Global.device_is_mobile():
#				effGame.play()
			UI.update_Team_GoalB(TeamB_score)

func set_goal_col(value:bool = false):
	$GoalA/CollisionShape3D.disabled = value
	$GoalB/CollisionShape3D.disabled = value
	$GoalA/KickingBall/CollisionShape3D.disabled = value
	$GoalA/KickingBall/CollisionShape2.disabled = value
	$GoalB/KickingBall/CollisionShape3D.disabled = value
	$GoalB/KickingBall/CollisionShape2.disabled = value

## Cac ham xu ly khi bong di ra ngoai
func _on_KickingBallA_body_entered(body):
	if body == Ball and isPlayReplay == false:
		isStartGame = false
		set_goal_col(true)
		timerValue = "KickA"
		TimerGame.start()

func _on_KickingBallB_body_entered(body):
	if body == Ball and isPlayReplay == false:
		isStartGame = false
		set_goal_col(true)
		timerValue = "KickB"
		TimerGame.start()

## Cac update player unit stats
func _on_BtnPlayerDetail_pressed():
	if UI.playerStats.visible == true:
		UI.playerStats.visible = false
		UI.teamStats.visible = false
	else:
		update_player_stats()
		UI.playerStats.visible = true
		UI.teamStats.visible = true

func update_player_stats():
	if UI.playerStats.visible == true:
		update_player_change_stats_on_ready()
		for unit in selected_units:
			UI.update_player_data(unit)

func update_player_change_stats_on_ready():
	if UI.playerEdit.visible == true:
		for unit in selected_units:
			UI.panelStats.get_node("Finishing/HSlider").value = unit.statFinishing
			UI.panelStats.get_node("Finishing/Label").text = str(unit.statFinishing)
			
			UI.panelStats.get_node("ShotPower/HSlider").value = unit.statShotPower
			UI.panelStats.get_node("ShotPower/Label").text = str(unit.statShotPower)

			UI.panelStats.get_node("Intercept/HSlider").value = unit.statTackle
			UI.panelStats.get_node("Intercept/Label").text = str(unit.statTackle)

			UI.panelStats.get_node("Pass/HSlider").value = unit.statAccurate
			UI.panelStats.get_node("Pass/Label").text = str(unit.statAccurate)

			UI.panelStats.get_node("Speed/HSlider").value = unit.statSpeed
			UI.panelStats.get_node("Speed/Label").text = str(unit.statSpeed)

			UI.panelStats.get_node("Ball Control/HSlider").value = unit.statBallControl
			UI.panelStats.get_node("Ball Control/Label").text = str(unit.statBallControl)

			UI.panelStats.get_node("Stamina/HSlider").value = unit.statStamina
			UI.panelStats.get_node("Stamina/Label").text = str(unit.statStamina)

			UI.panelStats.get_node("Power/HSlider").value = unit.statPower
			UI.panelStats.get_node("Power/Label").text = str(unit.statPower)

			UI.panelStats.get_node("Body/HSlider").value = unit.statBody
			UI.panelStats.get_node("Body/Label").text = str(unit.statBody)

			UI.panelStats.get_node("Reflexes/HSlider").value = unit.statReflexes
			UI.panelStats.get_node("Reflexes/Label").text = str(unit.statReflexes)

			UI.panelStats.get_node("Defend/HSlider").value = unit.statDefend
			UI.panelStats.get_node("Defend/Label").text = str(unit.statDefend)

			UI.panelStats.get_node("PenSave/HSlider").value = unit.statSave
			UI.panelStats.get_node("PenSave/Label").text = str(unit.statSave)

func update_player_change_stats():
	for unit in selected_units:
		unit.statFinishing = UI.panelStats.get_node("Finishing/HSlider").value
		UI.panelStats.get_node("Finishing/Label").text = str(unit.statFinishing)
		
		unit.statShotPower = UI.panelStats.get_node("ShotPower/HSlider").value
		UI.panelStats.get_node("ShotPower/Label").text = str(unit.statShotPower)

		unit.statIntercep = UI.panelStats.get_node("Intercept/HSlider").value
		UI.panelStats.get_node("Intercept/Label").text = str(unit.statIntercep)

		unit.statAccurate = UI.panelStats.get_node("Pass/HSlider").value
		UI.panelStats.get_node("Pass/Label").text = str(unit.statAccurate)

		unit.statSpeed = UI.panelStats.get_node("Speed/HSlider").value
		UI.panelStats.get_node("Speed/Label").text = str(unit.statSpeed)

		unit.statBallControl = UI.panelStats.get_node("Ball Control/HSlider").value
		UI.panelStats.get_node("Ball Control/Label").text = str(unit.statBallControl)

		unit.statStamina = UI.panelStats.get_node("Stamina/HSlider").value
		UI.panelStats.get_node("Stamina/Label").text = str(unit.statStamina)

		unit.statPower = UI.panelStats.get_node("Power/HSlider").value
		UI.panelStats.get_node("Power/Label").text = str(unit.statPower)

		unit.statBody = UI.panelStats.get_node("Body/HSlider").value
		UI.panelStats.get_node("Body/Label").text = str(unit.statBody)

		unit.statReflexes = UI.panelStats.get_node("Reflexes/HSlider").value
		UI.panelStats.get_node("Reflexes/Label").text = str(unit.statReflexes)

		unit.statDefend = UI.panelStats.get_node("Defend/HSlider").value
		UI.panelStats.get_node("Defend/Label").text = str(unit.statDefend)

		unit.statSave = UI.panelStats.get_node("PenSave/HSlider").value
		UI.panelStats.get_node("PenSave/Label").text = str(unit.statSave)

## Cac che do dieu khien
func _input(event):
	cam_touch_inut(event)
	
	if AI_mode() == false and isStartGame == true and UI.newTurn.check_turn() == true:
		if isStartTurn == true:
			select_unit_input(event)
			player_swipe_shot_input(event)
	
	if Input.is_action_just_pressed("ui_right"):
		play_quick_replay()
	
	if Input.is_action_just_pressed("ui_down"):
		play_replay(0)

func play_quick_replay():
	var frameMax = Ball.replay_data.pos.size()*1.0
	var frame = 0
	var ratio = 0
	if frameMax >= 300:
		frame = frameMax - 300
	ratio = frame/frameMax*100.0
	play_replay(ratio)

func play_replay(value):
	if isPlayReplay == false:
		UI.videoPlayer.set_up()
		timePlayReplay = time
		teamPlayReplay = teamSelect
		replayTurns = UI.newTurn.value
		
		replayCount = conver_frame_value(value)
		
		isPlayReplay = true
		UI.videoPlayer.show()
		
		Ball.baseTransform = Ball.transform
		units = get_tree().get_nodes_in_group("units")
		for unit in units:
			unit.baseTransform = unit.transform
		for unit in units:
			selected_units.clear()
			unit.deselect()
			unit.textBox.hide()

func _on_TimerPlayReplay_timeout():
	if UI.videoPlayer.btnPlay_pressed == true:
		if isPlayReplay == true:
			player_col_active(false)
			var posData = Ball.replay_data
			var size = posData.pos.size()-1
			UI.videoPlayer.replayTime.value += 100.0/size
			if isGameTime == 3:
				if UI.videoPlayer.replayTime.value == 100:
					conver_frame_value(0)

func replay_stop():
		isPlayReplay = false
		replayCount = 0
		Ball.transform = Ball.baseTransform
		for unit in units:
			unit.transform = unit.baseTransform
		player_col_active(true)
		isSaveReplay = true
		UI.videoPlayer.replayTime.value = 0
		UI.videoPlayer.hide()
		change_state(SET_PLAYER)
		time -= 1
		if teamPlayReplay == 1:
			teamSelect = 1
		else:
			teamSelect = 2
		_on_TimerAllStop_timeout()
		UI.newTurn.value = replayTurns

func _on_TimerSaveReplay_timeout():
	if isSaveReplay == true and isGameTime != 3:
		Ball.replay_data.pos.append(Ball.position)
		Ball.replay_data.rot.append(Ball.rotation_degrees.y)
		units = get_tree().get_nodes_in_group("units")
		for unit in units:
			if unit.playerPositionMath != "NON":
				unit.replay_data.id = unit.playerID
				unit.replay_data.pos.append(unit.position)
				unit.replay_data.rot.append(unit.rotation_degrees.y)

func replay_is_save(value):
	if isPlayReplay == true or get_tree().paused == true or isGameTime == 3:
		isSaveReplay = false
	else:
		isSaveReplay = value

# warning-ignore:unused_argument
func _on_BtnVideoReplaySlider_value_changed(value_changed):
	if isPlayReplay == true:
		replayCount = conver_frame_value(UI.videoPlayer.replayTime.value)
		player_col_active(false)
		var posData = Ball.replay_data
		var size = posData.pos.size()-1
		Ball.position = posData.pos[replayCount]
		Ball.rotation_degrees.y = posData.rot[replayCount]
		units = get_tree().get_nodes_in_group("units")
		for unit in units:
			if unit.playerPositionMath != "NON":
				var pdata = unit.replay_data
				if replayCount < pdata.pos.size()-1:
					unit.position = pdata.pos[replayCount]
					unit.rotation_degrees.y = pdata.rot[replayCount]
	if value_changed == 100 and isGameTime != 3:
		replay_stop()

func conver_frame_value(value):
	UI.videoPlayer.replayTime.value = value
	var replayData = Ball.replay_data
	var size = replayData.pos.size()-1
	var fix = round(remap(value,0,100,0,size))
	fix = clamp(fix,0,size)
	return fix

func save_replay():
	var path = "user://save/dataMatch.json"
	var allData = []
	var ballData = []
	var playerData = []
	for unit in units:
		if unit.playerPositionMath != "NON":
			var pdata = unit.replay_data
			playerData.append(pdata)
	ballData.append(Ball.replay_data)
	allData.append(ballData)
	allData.append(playerData)
	GameData.save_data(path,allData)

func _on_BtnReplayClose_pressed():
# warning-ignore:standalone_expression
	UI.videoPlayer.btnPlay_pressed = true
	replay_stop()

## Cac ham cam ung
func player_swipe_shot_input(event):
	if event is InputEventSingleScreenSwipe:
		UI.newTurn.isStart = false
		isStartTurn = false
		power = 0
		player_set_physics()
		
		var relative = event.relative.length()
		power = remap(relative,0,600,0,100)
		power = clamp(power,0,100)
		var angle = -rad_to_deg(event.relative.angle())-90
		
		if check_ball_on_player() == true:
			for unit in selected_units:
				var stats = remap(unit.statAccurate,40,100,10,0)
				stats = clamp(stats,0,20)
				var powerAccurate = remap(power,70,100,0,5)
				powerAccurate = clamp(powerAccurate,0,10)
				var accurate = stats + powerAccurate
				accurate = clamp(accurate,0,20)
				AIShootAngle = Calculate.rand_num(accurate)
		else:
			AIShootAngle = 0
		Arrow.rotation_degrees.y = angle + AIShootAngle

		change_state(SET_ANGLE)
		AI_player_angle_set()
		await get_tree().create_timer(0.5).timeout
		
		change_state(SET_POWER)
		AI_player_shot_pos_set()
		if check_ball_on_player() == true:
			await get_tree().create_timer(1.0).timeout
		
		change_state(SET_SHOOT)

func cam_touch_inut(event):
	if event is InputEventScreenPinch:
		var zoom = event.relative
		var delta = 0.01
		var lm = 2.5
		if ((Cam.position.y > camPos.y - lm) and (Cam.position.y < camPos.y + lm)):
			Cam.position.y -= zoom*delta
		else:
			Cam.position.y = camPos.y
	elif event is InputEventMultiScreenDrag:
		var pos = event.relative
		var delta = 0.01
		var lm = 2
		if ((Cam.position.x >camPos.x -lm) and (Cam.position.x <camPos.x+lm)):
			Cam.position.x += pos.x*delta
		else:
			Cam.position.x = camPos.x
		if ((Cam.position.z>camPos.z-lm) and (Cam.position.z<camPos.z+lm)):
			Cam.position.z += pos.y*delta
		else:
			Cam.position.z = camPos.z

## Cac ham xu ly di chuyen
func target_control_input(delta):
	if Global.isAIState:
		var speedPlayer = 1 * delta
		var unit = $AITest/Target
		
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
			print("cam_zoom_out")
			unit.rotation_degrees.y = unit.rotation_degrees.y
		elif Input.is_action_just_released("cam_zoom_in"):
			unit.rotation_degrees.y += speedPlayer
		elif Input.is_action_just_released("cam_zoom_out"):
			unit.rotation_degrees.y -= speedPlayer

##  Cac ham tinh toan chon cau thu
func select_unit_input(event):
	if AI_mode() == false:
		match state:
			SET_PLAYER:
				if event is InputEventSingleScreenTap:
					var m_pos = get_viewport().get_mouse_position()
					unit_select(m_pos)

func unit_select(m_pos):
	var new_selected_units = []
	var u = unit_under_mouse_get(m_pos)
	if u != null:
		new_selected_units.append(u)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
			unit.textBox.hide()
		for unit in new_selected_units:
			unit.select()
#			AI_find_foot()
			unit.textBox.powerBar.value = 100
		selected_units = new_selected_units

func unit_under_mouse_get(m_pos):
	var result = unit_raycast_from_mouse(m_pos, 3)
	## Fix Ball Select
	if result and result.collider.team != 11:
		if isStartGame == true:
			if result.collider.team == teamSelect:
				if result.collider.playerPositionMath != "NON":
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
func cam_follow_ball():
	if camFollowBall == true:
		if Ball.linear_velocity.length() > 1.0:
			Cam.position.x = Ball.transform.origin.x
			Cam.position.z = Ball.transform.origin.z

func show_pc_input():
	if Global.device_is_mobile():
		UI.controller.hide()
	else:
		UI.controller.show()

func arrow_pos(value:bool=false,obj = ""):
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

func _on_Button_pressed():
#	isActive = !isActive
#	if isActive == true:
#		UI.panelGameSpeed.get_node("HSlider").value = 0
#	else:
#		UI.panelGameSpeed.get_node("HSlider").value = 1.5
#		update_player_change_stats()
#		for unit in selected_units:
#			unit.return_Overall()
#			unit.return_Potential()
	pass

## Cac ham xu ly tran dau ket thuc
func save_match_data(value:bool = true):
	get_parent().get_node("/root/SoundBg").play()
	get_tree().paused = false
	Engine.time_scale = 1
	var ssData = GameData.season_load_data()
	var leagueResults = ssData.season.leagueResults
	var playerResults = ssData.season.playerResults
#	print(leagueResults[SeasonData.MatchDay-1][SeasonData.MatchID])
	var stats = leagueResults[SeasonData.MatchDay-1][SeasonData.MatchID]
	var players = playerResults[SeasonData.MatchDay-1][SeasonData.MatchID]
	
	if value == true:
		stats[6][0] = int(TeamA_score)
		stats[6][1] = int(TeamB_score)
	else:
		for i in players.size():
#			prints("team",players[i])
			for j in players[i].size():
#				prints("players",players[i][j])
				for n in players[i][j].size():
					if n > 0:
						players[i][j][n] = 0
		for i in stats.size():
			stats[i] = [0,0]
		if Global.MatchPlay == 1:
			stats[6][0] = 0
			stats[6][1] = 3
		else:
			stats[6][0] = 3
			stats[6][1] = 0
	GameData.season_save_data(ssData)

func save_player_data():
	if (Global.gameModeCur == 0
	or Global.gameModeCur == 1):
		units = get_tree().get_nodes_in_group("units")
		for unit in units:
			unit.save_player_data()

func quit_match_go_home():
	Messenger.btnYes.disconnect("pressed",Callable(self,"quit_match_go_home"))
	if Global.MGFMode != Global.Season:
		leave_match()
	else:
		finish_match()
	FormationData.CanFormation = false

func _on_ButtonHome_pressed():
	Messenger.push_notification(1,"Exit and Finish match")
	Messenger.btnYes.connect("pressed",Callable(self,"quit_match_go_home"))

func _on_ButtonExit_pressed():
	if Global.MGFMode != Global.Season:
		Messenger.push_notification(1,"Exit and Finish match")
		Messenger.btnYes.connect("pressed",Callable(self,"leave_match"))
	else:
		Messenger.push_notification(1,"Exit ?, you will lose the match")
		Messenger.btnYes.connect("pressed",Callable(self,"quit_match"))
	FormationData.CanFormation = false

func leave_match():
	Messenger.btnYes.disconnect("pressed",Callable(self,"leave_match"))
	get_parent().get_node("/root/SoundBg").play()
	get_tree().paused = false
	Engine.time_scale = 1
	var settingsData = GameData.formation_load_data().settings.gameMode
	timeOutMode = settingsData
	# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/ConfigController/ConfigController.tscn")

func quit_match():
	save_match_data(false)
	await get_tree().create_timer(0.1).timeout
	# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	Messenger.btnYes.disconnect("pressed",Callable(self,"quit_match"))

func finish_match():
	save_match_data(true)
	await get_tree().create_timer(0.1).timeout
	# warning-ignore:return_value_discarded
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")

func update_noti_match_results():
	if Global.MGFMode != Global.Season and Global.MGFMode != Global.SeasonMatch:
		var teamData = data.teams
		var _teamA = teamData[Global.teamID1].name + " "
		var _teamB =  " " + teamData[Global.teamID2].name
		var text:String
		if teamAFoul == maxFoul:
			text = _teamA + str(TeamA_score) + ' - ' + str(TeamB_score) + _teamB
			NotiData.create_noti("Loose Match",text)
			NotiData.create_achi(6,"Frist Loose Achievement", text)
		elif teamBFoul == maxFoul:
			text = _teamA + str(TeamA_score) + ' - ' + str(TeamB_score) + _teamB
			NotiData.create_noti("Win Match",text)
			NotiData.create_achi(4,"Frist Win Achievement", text)
		else:
			if TeamA_score > TeamB_score:
				text = _teamA + str(TeamA_score) + ' - ' + str(TeamB_score) + _teamB
				NotiData.create_noti("Win Match",text)
				NotiData.create_achi(4,"Frist Win Achievement", text)
			elif TeamA_score == TeamB_score:
				text = _teamA + str(TeamA_score) + ' - ' + str(TeamB_score) + _teamB
				NotiData.create_noti("Draw Match",text)
				NotiData.create_achi(5,"Frist Draw Achievement", text)
			else:
				text = _teamA + str(TeamA_score) + ' - ' + str(TeamB_score) + _teamB
				NotiData.create_noti("Loose Match",text)
				NotiData.create_achi(6,"Frist Loose Achievement", text)
		
		NotiData.create_achi(3,"Frist Match Achievement", text)

## Thay doi cau thu, chien thuat
func _on_TimerSub_timeout():
	FormationData.isSub = false
	print("SubDone")

func sub_change():
	units = get_tree().get_nodes_in_group("units")
	## Lay tat ca vi tri player
	var position = []
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
#				if sub != main:
				GlobalTween.pos_dir(unit,position[i])
				unit.position.y = 0
				unit.player_set_stop(tween)
				print(unit.playerName," ",unit.playerPositionMath)
	FormationData.isSub = false

func sub_change_start():
	if FormationData.isSub == true and (time == FormationData.timeSub + 1):
		Calculate.timer(TimerSub,1)

