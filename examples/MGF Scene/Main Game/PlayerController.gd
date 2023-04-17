extends RigidBody3D

class_name Player

var replay_data:Dictionary = {
	"id": 0,
	"pos": [],
	"rot": []
}
var baseTransform:Transform3D

## Chi so tinh nhan vat
var POWERCONTROLLER:float = 3.0
var team:int = Global.team
var goal:Area3D
var ball:RigidBody3D
var gk_check:Area3D
var playerDefend:float = 1
var playerColPos:float = 0.008

## Chi so nhan vat
var playerID:int = 0
var playerLevel:int = 20
var texturePlayerPath
var charPath
@export var playerName: String = "Unknow"
var playerNation:String
var playerTeam:int = 0

@export var playerPosition = "SUB" # (String, "GK", "CB", "WB", "CM", "DM", "AM", "WM", "WF", "SS", "CF", "FW", "SUB")
@export var playerPositionMath = "CM" # (String, "GK", "CB", "LB", "RB", "CM","LF", "RF", "NON")

var Foot:int = 0
var FootUse:int = 50
var playerAge:int = 20
var playerOverall:float = 60
var playerPotential:float = 70
var statFinishing:float = 60
var statShotPower:float = 60
var statTackle:float = 60
var statAccurate:float = 60
var statSpeed:float = 60
var statBallControl:float = 60
var statStamina:float = 60
var statPower:float = 60
var statBody:float = 60
var statDefend:float = 40
var statReflexes:float = 40
var statSave:float = 40

var Finishing:float
var ShotPower:float
var Intercept:float
var Accurate:float
var Speed:float
var BallControl:float
var Stamina:float
var Power:float
var Body:float
var Defend:float
var Reflexes:float
var Save:float

## Data Player
var statEnergy:float = 99
var statInjuryRate:float = 70
var statInjury:float = 0000
var statsPlayTime:int = 0
var timeRecovery:int = 0

var statGames:int = 0
var statGoals:int = 0
var statAssits:int = 0
var statShots:int = 0
var statPasses:int = 0
var statTackles:int = 0
var statBlocks:int = 0
var statMoves:int = 0
var statOwnGoals:int = 0
var statMistakes:int = 0
var statFouls:int = 0

## Data Match
var direction:Vector3
var isHoldBall:bool = false
var canGoal:bool = false
var canAssit:int = 0

var gameRates:float = 5
var gameGoals:int = 0
var timeGoals:Array = []
var gameAssits:int = 0
var gameShots:int = 0
var gameMisses:int = 0
var gamePasses:int = 0
var gameMoves:int = 0
var gameDefends:int = 0
var gameSaves:int = 0
var gameFouls:int = 0

## Cac Node tham chieu
@onready var AIMPOS:Vector3 = $AimPoint.position
@onready var RightPoint:Node3D = $RightPoint
@onready var LeftPoint:Node3D = $LeftPoint
@onready var PivotPoint:Node3D = $PivotPoint
@onready var MeshSelect:MeshInstance3D = $MeshInstance3D
#@onready var playerVfx:EffekseerEmitter = $PivotPoint/EffekseerEmitter

## Vi tri nhan vat so vs bong
var FootSizeR:float = 0.06
var FootSizeL:float = 0.06
var FootFixR:float = 30.0
var FootFixL:float = 30.0
var SHOTPOWG = 60 # (int, 0, 100)
var SHOTPOWTB = 80 # (int, 0, 100)
var SHOTPOWX = 100 # (int, 0, 100)

## Physics Stats
var linear_base:float
var angular_base:float
var friction_base:float
var bounce_base:float
var mass_base:float
var defend_base:float
var mass_gk:float
var defend_gk:float
var save_gk:float
var friction_move:float
var friction_tackle:float
var POWERCONTROLLERSHOT:float
var linear_shot:float
var angular_shot:float
var friction_shot:float
var physic_shot:float
var bounce_shot:float

## Var Instance node textbox
var textins:PackedScene = preload("res://MGF Scene/AssetsScene3D/TextBox.tscn")
var textBox = textins.instantiate()

var playerMat:BaseMaterial3D
var shader:Material = preload("res://Assets3D/Mat/M_red.tres")

var meshOutLineSize:float = 0.015
@onready var teamAMat:Color = Settings.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = Settings.teamColor[Global.teamID2][1]

func _ready():
	physics_material_override.rough = false
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	## Create outline mesh
	MeshSelect.show()
	MeshSelect.mesh = get_child(0).mesh.create_outline(meshOutLineSize)
	MeshSelect.position.y = -0.01
	MeshSelect.material_override = shader.duplicate(true)
	
	## Create base collision
#	$CollisionShape3D.queue_free()
#	$CollisionShape3D.shape = get_child(0).mesh.create_convex_shape()
	$CollisionShape3D.shape.margin = 0.01
	
	playerMat = get_child(0).mesh.surface_get_material(0)
	playerMat.set_shading_mode(0)
	playerMat.set_specular_mode(1)
	
	MeshSelect.material_override.set_shading_mode(0)
	MeshSelect.material_override.set_specular_mode(1)
	
	load_player_data()
	player_load_physics()
	direction = position
	
func find_targets():
	add_child(textBox)
	textBox.powerBar.value = statEnergy
	textBox.powerBar.get_theme_stylebox("fg").bg_color = textBox.change_color(statEnergy)
	textBox.hide()
	
	ball = get_parent().Ball
	if is_in_group("team1"):
		textBox.set_team_color(teamAMat)
		team = 1
		goal = get_parent().GoalA
		if playerPositionMath == "GK":
			gk_check = get_parent().GkA
	else:
		textBox.set_team_color(teamBMat)
		team = 2
		goal = get_parent().GoalB
		if playerPositionMath == "GK":
			gk_check = get_parent().GkB

func player_set_stop(t):
	rotation_degrees.y = 0
	GlobalTween.rot(self,Vector3.ZERO)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func player_set_physics():
#Luc sut (bong bay manh)
	var fixFric = 0
	var powerShot = (statShotPower+statFinishing)/2.0
	POWERCONTROLLERSHOT = remap(powerShot,40,100,3,2.8)
	POWERCONTROLLERSHOT = clamp(POWERCONTROLLERSHOT,2,3)
	friction_shot = 0.5
#	friction_shot = range_lerp(powerShot,0,100,0.6,0.3)
	
	#Kha nang dut diem (bong bay cao)
	physic_shot = remap(statFinishing,40,100,0,3)
	bounce_shot = 0.7
#	bounce_shot = range_lerp(statFinishing,0,100,0.1,1)
	
	#Di chuyen len 1 doan khi sut bong
	linear_shot = remap(((Body+Power)/2.0),40,100,0.8,1)
	angular_shot = remap(((Body+Power)/2.0),40,100,3,4)
	
	# Toc do cau thu di chuyen
	var moveSpeed =  remap(statSpeed,40,100,0.3,0.2)
	friction_move =  moveSpeed
	
	#Tranh lay bong
	var tackle = statTackle
	friction_tackle = remap(tackle,40,100,0,0.8)
#	prints(playerName,"tackle",friction_tackle,statTackle)
	
	#Giu bong (chiu tac dong)
	var strength = (statBody+statPower*2)/3
	linear_base = remap(strength,40,100,-1,0)
	angular_base = remap(strength,40,100,4,5)
	mass_base = remap((strength),40,100,5,15)
	bounce_base = remap(strength,40,100,0.3,0.2)
	friction_base = remap(strength,40,100,0.2,0.1)
	
	## Kha nang can bong
	defend_base = remap(100,40,100,0.5,2.0)
	mass_gk = remap(((statPower+statDefend*2.0)/3.0),40,100,5,30)
	defend_gk = defend_base
	save_gk = remap(statSave,40,100,1,30)

func shoot(obj, value, angle, power, dir):
	power = clamp(power,0,100)
	if power<=80:
		bounce_shot = remap(power,0,80,0,bounce_shot)
	var force = Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), angle)
	var forceBall = Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), angle)
	var shootPower = force * (power / POWERCONTROLLER)
	var ballPower = forceBall * ((statShotPower*power)/100 / POWERCONTROLLER)
	var vecShoot = Vector3(dir.x,0,dir.z)
#	print(rotation_degrees.y,shootPower)
	await get_tree().process_frame
	if Global.isSimulateShoot == true:
		if value == false:
			apply_impulse(shootPower, vecShoot)
		else:
			obj.position.y = (power/150)*(bounce_shot)
			obj.apply_central_impulse(ballPower*0.6)
			await get_tree().process_frame
			apply_impulse(shootPower*0.5, vecShoot)
	else:
		apply_impulse(shootPower, vecShoot)

func load_player_data():
	var game_Data = GameData.formation_load_data()
	var playerData = game_Data.players[playerID]
	
	playerID = int(playerData.PlayerID)
	playerName = playerData.Name

	texturePlayerPath = load(playerData.texturePath)
	charPath = load(playerData.filePath)
	
	playerNation = playerData.Team[3]
	playerTeam = playerData.Team[0]
	
	playerPosition = playerData.Team[2]
	playerPositionMath = playerData.Team[1]
	
	playerAge = int(playerData.Age)
	
	statFinishing = float(playerData.Stat[0])
	statShotPower = float(playerData.Stat[1])
	statTackle = float(playerData.Stat[8])
	statAccurate = float(playerData.Stat[2])
	statSpeed = float(playerData.Stat[5])
	statBallControl = float(playerData.Stat[3])
	statStamina = float(playerData.Stat[4])
	statPower = float(playerData.Stat[6])
	statBody = float(playerData.Stat[7])
	statReflexes = float(playerData.Stat[11])
	statDefend = float(playerData.Stat[9])
	statSave = float(playerData.Stat[10])
		
	Finishing = statFinishing
	ShotPower = statShotPower
	Intercept = statTackle
	Accurate = statAccurate
	Speed = statSpeed
	BallControl = statBallControl
	Stamina = statStamina
	Power = statPower
	Body = statBody
	Reflexes = statReflexes
	Defend = statDefend
	Save = statSave
	
	statGames = int(playerData.Career[0])
	statGoals = int(playerData.Career[2])
	statAssits = int(playerData.Career[3])
#	statShots
	statPasses = int(playerData.Season[5])
#	statTackles
#	statBlocks
	statMoves = int(playerData.Season[6])
	statOwnGoals = int(playerData.Season[11])
	statMistakes = int(playerData.Season[12])
	
	statsPlayTime = int(playerData.Health[0])
	statEnergy = float(playerData.Health[1])
	statInjuryRate = float(playerData.Health[2])
	statInjury = float(playerData.Health[3])
	timeRecovery = int(playerData.Health[4])
	
	Foot = int(playerData.Foot[0])
	FootUse = int(playerData.Foot[1])
	FootSizeR = float(playerData.Foot[2])/1000
	FootSizeL = float(playerData.Foot[4])/1000
	FootFixR = float(playerData.Foot[3])
	FootFixL = float(playerData.Foot[5])
	
	playerOverall = Calculate.return_Overall(
		playerPosition,
		playerPositionMath,
		statFinishing,
		statShotPower,
		statTackle,
		statAccurate,
		statSpeed,
		statBallControl,
		statStamina,
		statPower,
		statBody,
		statReflexes,
		statDefend,
		statSave)
	
	playerPotential = Calculate.return_Potential(playerData.Age,playerOverall)
	
#	if playerLevel != float(playerData.Class[0]):
#		player_stats_level(playerLevel-float(playerData.Class[0])+20)
#		playerData.Class[0] = playerLevel
	
	player_set_physics()

func save_player_data():
	var data = GameData.formation_load_data()
	var playerData = data.players[playerID]

	playerData.Name = playerName
	
	playerData.Age = playerAge
	playerData.Nation = playerNation
	playerData.Team[0] = playerTeam
	
	playerData.Team[2] = playerPosition
	playerData.Team[1] = playerPositionMath

	playerData.playerData.Class[0] = playerLevel

#	playerData.Stat[0] = Stat[0]
#	playerData.Stat[1] = Stat[1]
#	playerData.Stat[8] = Stat[8]
#	playerData.Stat[2] = Stat[2]
#	playerData.Stat[5] = Stat[5]
#	playerData.Stat[3] = Stat[3]
#	playerData.Stat[4] = Stat[4]
#	playerData.Stat[6] = Stat[6]
#	playerData.Stat[7] = Stat[7]
#	playerData.Stat[11] = Stat[11]
#	playerData.Stat[9] = Stat[9]
#	playerData.Stat[10] = Stat[10]

	playerData.Health[0] = statsPlayTime
	playerData.Health[1] = statEnergy
	playerData.Health[2] = statInjuryRate
	playerData.Health[3] = statInjury
	playerData.Health[4] = timeRecovery

	playerData.Season[0] = statGames+1
	playerData.Season[2] = statGoals
	playerData.Season[3] = statAssits
	
	playerData.Season[5] = statPasses+gamePasses
	playerData.Season[6] = statMoves+gameMoves
	playerData.Season[11] = statOwnGoals
	playerData.Season[12] = statMistakes
	
	GameData.formation_save_data(data)

func player_stats_level(value):
	var setValue = 0
	
	value = value - 20
	
	statFinishing = calculate_player_stats_level(statFinishing, value, setValue)
	statShotPower = calculate_player_stats_level(statShotPower, value, setValue)
	statTackle = calculate_player_stats_level(statTackle, value, setValue)
	statAccurate = calculate_player_stats_level(statAccurate, value, setValue)
	statSpeed = calculate_player_stats_level(statSpeed, value, setValue)
	statBallControl = calculate_player_stats_level(statBallControl, value, setValue)
	statStamina = calculate_player_stats_level(statStamina, value, setValue)
	statPower = calculate_player_stats_level(statPower, value, setValue)
	statBody = calculate_player_stats_level(statBody, value, setValue)
	if playerPosition == "GK":
		statReflexes = calculate_player_stats_level(statReflexes, value, setValue)
		statDefend = calculate_player_stats_level(statDefend, value, setValue)
		statSave = calculate_player_stats_level(statSave, value, setValue)
	else:
		statReflexes = calculate_player_stats_level(statReflexes, value/2.0, setValue)
		statDefend = calculate_player_stats_level(statDefend, value/2.0, setValue)
		statSave = calculate_player_stats_level(statSave, value/2.0, setValue)

func calculate_player_stats_level(obj, value, setValue):
	if obj > setValue:
		obj += value
	if obj < 50:
		obj = 50
	return obj

func player_set_stamina():
	var decreaseTime = remap(statStamina,50,100,0.6,0.3)
#	decreaseTime = remap(statStamina,50,100,10,5)
	if statEnergy > 0:
		statEnergy -= decreaseTime
	elif statEnergy >= 0:
		statEnergy = 0
	textBox.powerBar.value = statEnergy
#	print(statEnergy, " ",SHOTPOWX)
	player_set_all_stats()
	
	if statEnergy < 80:
		SHOTPOWG = remap(statEnergy,0,100,40,60)
		SHOTPOWTB = remap(statEnergy,0,100,60,80)
		SHOTPOWX = remap(float(statEnergy),0.0,100.0,70.0,100.0)
	elif statEnergy <=0:
		SHOTPOWG = 40
		SHOTPOWTB = 60
		SHOTPOWX = 70
#	SHOTPOWG = 60
#	SHOTPOWTB = 80
#	SHOTPOWX = 80
#	print(SHOTPOWX)

func player_set_all_stats():
	statFinishing = player_set_stats(statFinishing,Finishing)
	statShotPower = player_set_stats(statShotPower,ShotPower)
	statTackle = player_set_stats(statTackle,Intercept)
	statAccurate = player_set_stats(statAccurate,Accurate)
	statSpeed = player_set_stats(statSpeed,Speed)
	statBallControl = player_set_stats(statBallControl,BallControl)
#	statStamina = player_set_stats(statStamina,Stamina)
	statPower = player_set_stats(statPower,Power)
	statBody = player_set_stats(statBody,Body)
	statReflexes = player_set_stats(statReflexes,Reflexes)
	statDefend = player_set_stats(statDefend,Defend)
	statSave = player_set_stats(statSave,Save)

func player_set_stats(stats,maxData):
	var maxStats = float(maxData)
	var setValue = 60
	if maxStats <= setValue:
		stats = maxStats
		return stats
	elif statEnergy > 0 and statEnergy < 80:
		stats = remap(statEnergy,0,80,setValue,maxStats)
	elif statEnergy <= 0:
		stats = 60
	return stats

## Cac Ham xu ly cau thu
func player_load_physics():
	physics_material_override = physics_material_override.duplicate()
	position.y = 0
	continuous_cd = true
	axis_lock_linear_y = false
	RightPoint.hide()
	LeftPoint.hide()
	PivotPoint.hide()
	RightPoint.position.y = 0.5
	LeftPoint.position.y = 0.5
	PivotPoint.position.y = 0
#	SelectionRing.position.y = 0.016

func get_team_color(t,alpha):
	teamAMat.a = alpha
	teamBMat.a = alpha
	if t == 1: 
		return teamAMat*1.4
	else:
		return teamBMat*1.4

func select():
	textBox.powerBar.value = statEnergy
	textBox.powerBar.get_theme_stylebox("fg").bg_color = textBox.change_color(statEnergy)
	textBox.player_talk()
	textBox.show()
	if team == 1:
		MeshSelect.material_override.albedo_color = get_team_color(1,0.5)
#		MeshSelect.material_override.emission = get_team_color(1,1)
	else:
		MeshSelect.material_override.albedo_color = get_team_color(2,0.5)
#		MeshSelect.material_override.emission = get_team_color(2,1)

func deselect():
	textBox.powerBar.value = statEnergy
	textBox.powerBar.get_theme_stylebox("fg").bg_color = textBox.change_color(statEnergy)
	if team == 1:
		MeshSelect.material_override.albedo_color = get_team_color(1,0.5)
#		MeshSelect.material_override.emission = get_team_color(1,0.5)
	else:
		MeshSelect.material_override.albedo_color = get_team_color(2,0.5)
#		MeshSelect.material_override.emission = get_team_color(2,0.5)

func player_is_collision(value):
	$CollisionShape2.disabled = value
	$CollisionShape3.disabled = value
	$CollisionShape4.disabled = value
	$CollisionShape5.disabled = value
	$CollisionShape6.disabled = value
	$CollisionShape7.disabled = value
	$CollisionShape8.disabled = value

func player_defend_set():
#	for i in $CollisionShape3D.shape.points.size():
#		if  $CollisionShape3D.shape.points[i].y > 0:
#			 $CollisionShape3D.shape.points[i].y = playerColPos * playerDefend * 10
	var size = (playerColPos * playerDefend)
	var pos = (playerColPos * playerDefend)/2
	$CollisionShape2.shape.size.y = size
	$CollisionShape3.shape.size.y = size
	$CollisionShape4.shape.size.y = size
	$CollisionShape5.shape.size.y = size
	$CollisionShape6.shape.size.y = size
	$CollisionShape7.shape.size.y = size
	$CollisionShape8.shape.size.y = size
	$CollisionShape2.position.y = pos
	$CollisionShape3.position.y = pos
	$CollisionShape4.position.y = pos
	$CollisionShape5.position.y = pos
	$CollisionShape6.position.y = pos
	$CollisionShape7.position.y = pos
	$CollisionShape8.position.y = pos
	
