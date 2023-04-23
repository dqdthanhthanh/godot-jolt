extends RigidBody3D

class_name Player

var replay_data:Dictionary = {
	"id": 0,
	"pos": [],
	"rot": []
}
var baseTransform:Transform3D

## Chi so tinh nhan vat
var ratio:float = 4.0
var POWERCONTROLLER:float = 3.0/ratio
var a:float = 2.0/ratio
var b:float = 2.8/ratio
var c:float = 3.0/ratio
var d:float = 4.0/ratio
var team:int = Global.team
var goal:Area3D
var ball:RigidBody3D
var gk_check:Area3D
var playerDefend:float = 1

## Chi so nhan vat
var playerID:int = 0
var ID:int = 0
var playerLevel:int = 20
var playerData:Dictionary
var teamData:Dictionary
@export var playerName: String = "Unknow"

var playerPosition:String
var playerPositionMath:String

var statFinishing:float
var statShotPower:float
var statTackle:float
var statAccurate:float
var statSpeed:float
var statBallControl:float
var statStamina:float
var statPower:float
var statBody:float
var statDefend:float
var statReflexes:float
var statSave:float

var statsPlay:int = -1
var statsPlayTime:int
var statEnergy:float

var timeGoals:Array = []
var matchPoints:float = 5.0
var matchGoals:int = 0
var matchAssits:int = 0
var matchShots:int = 0
var matchPasses:int = 0
var matchMoves:int = 0
var matchBlocks:int = 0
var matchTackles:int = 0
var matchSaves:int = 0
var matchSavesRatio:float = 0
var matchOwnGoals:int = 0
var matchMistakes:int = 0
var matchFouls:int = 0

## Data Match
var direction:Vector3
var isHoldBall:bool = false
var canGoal:bool = false
var canAssit:int = 0

## All Node
@onready var AIMPOS:Vector3 = $AimPoint.position
@onready var RightPoint:Node3D = $RightPoint
@onready var LeftPoint:Node3D = $LeftPoint
@onready var PivotPoint:Node3D = $PivotPoint
@onready var MeshCharacter:MeshInstance3D = $MeshInstance3D
#@onready var playerVfx:EffekseerEmitter
var SelectMesh
var Shadow
var textBox:Node3D

## Foot Data
var Foot:int = 0
var FootUse:int = 50
var FootSizeR:float = 0.06
var FootSizeL:float = 0.06
var FootFixR:float = 30.0
var FootFixL:float = 30.0

## Physics Stats
var turn_speed:float
var turn_def:float
var linear_base:float
var angular_base:float
var friction_base:float
var bounce_base:float
var mass_def:float
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

## Color Data
var playerColor:Color
var teamColor:Color
@onready var teamAMat:Color = GlobalTheme.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = GlobalTheme.teamColor[Global.teamID2][1]

func _ready() -> void:
	fix_col()
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	
	load_player_data()
	player_load_physics()
	direction = position
	MeshCharacter.position.y = 0.1
	
	#VFX
#	playerVfx = load("res://MGF Scene/AssetsScene3D/EffekseerEmitterPlayer.tscn").instantiate()
#	PivotPoint.add_child(playerVfx)
	var playerShader = load("res://Assets3D/Shader/CrowdShader.tres").duplicate(true)
	MeshCharacter.cast_shadow = 0
	MeshCharacter.set_surface_override_material(0,playerShader)
	##Fix mat
	MeshCharacter.get_surface_override_material(0).params_depth_draw_mode = StandardMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
	set_skin(playerData.Icon)
	MeshCharacter.get_surface_override_material(0).emission_enabled = true
	MeshCharacter.get_surface_override_material(0).emission_energy = 0.4
	MeshCharacter.get_surface_override_material(0).set_metallic(0)
	MeshCharacter.get_surface_override_material(0).set_roughness(0.8)
#	if OS.get_current_video_driver() == 0:
#		MeshCharacter.get_surface_override_material(0).set_metallic(1.0)
#		MeshCharacter.get_surface_override_material(0).set_roughness(1.0)
#	else:
#		MeshCharacter.get_surface_override_material(0).set_metallic(0)
#		MeshCharacter.get_surface_override_material(0).set_roughness(0.8)
	
	## Create mesh select
	SelectMesh = load("res://Assets3D/Shader/MeshSelect.tscn").instantiate()
	add_child(SelectMesh)
	var shaderSelect: = load("res://Assets3D/Shader/SelectMat.tres")
	SelectMesh.material_override = shaderSelect.duplicate(true)
	SelectMesh.mesh_select(0)
	
	## CreateShadow
	Shadow = load("res://Assets3D/Shader/Shadow.tscn").instantiate()
	add_child(Shadow)
	var shadowShader: = load("res://Assets3D/Shader/PlayerShadowShader.tres").duplicate(true)
	shadowShader.albedo_texture = load_shadow(playerData.Icon).duplicate(true)
#	if OS.get_current_video_driver() == 0:
#		shadowShader.albedo_texture = load_shadow(playerData.Icon).duplicate(true)
#	else:
#		shadowShader.albedo_texture = load_shadow(playerData.Icon)
	Shadow.mat.material_override = shadowShader
	Shadow.mat.position.z = AIMPOS.z+0.1
	Shadow.mat.scale = MeshCharacter.scale*1.1
	Shadow.mat.scale.z = 0.3

static func load_icon(value):
	var path: = "res://Assets2D/PlayerIcon/Low/"
	return load(path + value)

static func load_high_image(value):
	var path: = "res://Assets2D/PlayerIcon/High/"
	return load(path + value)

static func load_image(value):
	var path: = "res://Assets2D/PlayerIcon/Medium/"
	return load(path + value)

static func load_shadow(value):
	var path: = "res://Assets2D/PlayerIcon/Shadow/"
	return load(path + value)

func set_skin(texture:String) -> void:
	playerData.Icon = texture
	MeshCharacter.get_surface_override_material(0).albedo_texture = load_image(texture).duplicate(true)
#	if OS.get_current_video_driver() == 0:
#		MeshCharacter.get_surface_override_material(0).albedo_texture = load_image(texture).duplicate(true)
#	else:
#		MeshCharacter.get_surface_override_material(0).albedo_texture = load_image(texture)
	MeshCharacter.get_surface_override_material(0).emission_texture = MeshCharacter.get_surface_override_material(0).albedo_texture

func find_targets() -> void:
	var MainGame = get_parent().get_parent()
	
	ball = MainGame.Ball
	if is_in_group("team1"):
		team = 1
		playerColor = teamAMat
		goal = MainGame.GoalA
		if playerPositionMath == "GK":
			gk_check = MainGame.GkA
		teamColor = teamAMat
		SelectMesh.material_override.albedo_color = get_team_color(1)
	else:
		team = 2
		playerColor = teamBMat
		goal = MainGame.GoalB
		if playerPositionMath == "GK":
			gk_check = MainGame.GkB
		teamColor = teamBMat
		SelectMesh.material_override.albedo_color = get_team_color(2)

func player_set_stop() -> void:
	rotation_degrees.y = 0
	GlobalTween.rot(self,Vector3.ZERO)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func player_set_physics() -> void:
	turn_speed = remap((statSpeed+statEnergy)/2,40,100,2.5,0)
	turn_speed = clamp(turn_speed, 0, 2.5)
	
	turn_def = remap((statTackle+statEnergy)/2,40,100,2.5,0)
	turn_def = clamp(turn_def, 0, 5.0)
	
	#Luc sut (bong bay manh)
	var powerShot = (statShotPower+statFinishing)/2.0
	POWERCONTROLLERSHOT = remap(powerShot,40,100,c,b)
	POWERCONTROLLERSHOT = clamp(POWERCONTROLLERSHOT,a,c)
#	friction_shot = 0.5
	friction_shot = remap(powerShot,0,100,0.4,0.6)
	
	#Kha nang dut diem (bong bay cao)
	physic_shot = remap(statFinishing,40,100,1,3)
	bounce_shot = remap(statFinishing,0,100,0.5,1)*3.0
	
	#Di chuyen len 1 doan khi sut bong
	linear_shot = remap(((statBody+statPower)/2.0),40,100,0.5,1)
	angular_shot = remap(((statBody+statPower)/2.0),40,100,0,1)
	
	# Toc do cau thu di chuyen
	var moveSpeed =  remap(statSpeed,40,100,0.3,0.2)
	friction_move =  moveSpeed
	
	#Tranh lay bong
	friction_tackle = remap(statTackle,40,100,0,1)
	
	#Giu bong (chiu tac dong)
	var strength = (statBody+statPower*2)/3
	linear_base = remap(strength,0,100,-1,1)
	angular_base = linear_base+friction_tackle
	mass_def = 7.5
	mass_base = remap((strength),40,100,mass_def,mass_def*2.0)
	bounce_base = remap(strength,40,100,0.2,0.1)
	friction_base = remap(strength,40,100,0.2,0.1)
	
	## Kha nang can bong
	defend_base = remap(statDefend,40,100,1.0,5.0)
	mass_gk = remap(((statPower+statDefend*2.0)/3.0),40,100,mass_def,mass_def*3.0)
	defend_gk = defend_base
	save_gk = remap(statSave,40,100,2,12)

func player_play_time(time:int) -> void:
	if time > 0:
		if playerPositionMath != "NON":
			if statsPlay == -1:
				statsPlay = time
			statsPlayTime += 1
			statsPlayTime = clamp(statsPlayTime,-1,time)
			if statsPlayTime > 10:
				var stamina:float = remap(statStamina,40,100,80,0)/80.0+((matchPasses*2+matchMoves)/300)
				stamina = clamp(stamina,0,1.0)
				statEnergy -= stamina
				statEnergy = clamp(statEnergy,0,99)
				
				turn_speed = remap((statSpeed+statEnergy)/2,40,100,0.5,0)
				turn_speed = clamp(turn_speed,0,0.5)
				
				var strength = (statBody+statPower*2)/3
				mass_base = remap((strength+statEnergy)/2,40,100,5,22)
				mass_gk = remap((((statPower+statDefend*2.0)/3.0)+statEnergy)/2,40,100,5,40)

func shoot(obj, value, angle, power, dir) -> void:
	POWERCONTROLLER = remap(statEnergy,0,90,d,c)
	POWERCONTROLLER = clamp(POWERCONTROLLER,c,d)
	
	power = clamp(power,0,100)
	if power<=80:
		bounce_shot = remap(power,0,80,0,bounce_shot)
	var force = Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), angle)
	var forceBall = Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), angle)
	var shootPower = force * (power / POWERCONTROLLER)
	var ballPower = forceBall * ((statShotPower*power)/100 / POWERCONTROLLER)
	var vecShoot = Vector3(dir.x,0,dir.z)
	
	if value == false:
		self.apply_impulse(shootPower, vecShoot)
	else:
		obj.position.y = (power/150)*(bounce_shot)
		obj.apply_central_impulse(ballPower*0.6)
		await get_tree().create_timer(0).timeout
		self.apply_impulse(shootPower*0.5, vecShoot)

func updates_data(playerData):
	var fileData:FileData = FileData.new()
	var player = fileData.players[playerData.ID]
	playerData.Name = player.Name
	playerData.Foot = player.Foot
	playerData.Voice = player.Voice
	playerData.FilePath = player.FilePath
	playerData.Art = player.Art
	playerData.Price = player.Price
	playerData.Max = player.Max
#	playerData.Icon = player.Icon
	
	return playerData

func load_player_data() -> void:
	var data = GameData.formation_load_data()
	var fileData:FileData = FileData.new()
	
	playerData = data.players[playerID]
	playerData = updates_data(playerData)
	
	teamData = data.teams[playerData.Team[0]]
	var team = fileData.teams[playerData.Team[0]]
	teamData.name = team.name
	teamData.fullName = team.fullName
	teamData.icon = team.icon
	
	playerPosition = playerData.Team[2]
	playerPositionMath = playerData.Team[1]
	
	statsPlayTime = playerData.Health[0]
	statEnergy = playerData.Health[1]
	
	statFinishing = float(playerData.Stat[0])
	statShotPower = float(playerData.Stat[1])
	statTackle = float(playerData.Stat[8])
	statSpeed = float(playerData.Stat[2])
	statAccurate = float(playerData.Stat[3])
	statBallControl = float(playerData.Stat[4])
	statStamina = float(playerData.Stat[5])
	statPower = float(playerData.Stat[6])
	statBody = float(playerData.Stat[7])
	statReflexes = float(playerData.Stat[11])
	statDefend = float(playerData.Stat[9])
	statSave = float(playerData.Stat[10])
	
	Foot = int(playerData.Foot[0])
	FootUse = int(playerData.Foot[1])
	FootSizeR = float(playerData.Foot[2])/1000
	FootSizeL = float(playerData.Foot[4])/1000
	FootFixR = float(playerData.Foot[3])
	FootFixL = float(playerData.Foot[5])
	
#	matchPoints = playerData.Match[1]
#	matchGoals = playerData.Match[2]
#	matchAssits = playerData.Match[3]
#	matchShots = playerData.Match[4]
#	matchPasses = playerData.Match[5]
#	matchMoves = playerData.Match[6]
#	matchBlocks = playerData.Match[7]
#	matchTackles = playerData.Match[8]
#	matchSaves = playerData.Match[9]
#	matchSavesRatio = playerData.Match[10]
#	matchOwnGoals = playerData.Match[11]
#	matchMistakes = playerData.Match[12]
#	matchFouls = 0
	
	player_set_physics()

func save_player_data() -> void:
	var data = GameData.formation_load_data()
	data.players[playerID] = playerData
	
	GameData.formation_save_data(data)

## Cac Ham xu ly cau thu
func player_load_physics() -> void:
	physics_material_override = physics_material_override.duplicate()
	position.y = 0
	continuous_cd = true
	axis_lock_linear_y = false
	axis_lock_angular_x = false
	axis_lock_angular_z = false
	RightPoint.hide()
	LeftPoint.hide()
	PivotPoint.hide()
	RightPoint.position.y = 0.5
	LeftPoint.position.y = 0.5
	PivotPoint.position.y = 0

func get_team_color(t) -> Color:
	var alpha:float = 0.4
	var color:Color
	teamAMat.a = alpha
	teamBMat.a = alpha
	if t == 1: 
		color = teamAMat
	else:
		color = teamBMat
	return color

func select() -> void:
	if !has_node("TextBox"):
		textBox = load("res://MGF Scene/AssetsScene3D/TextBox.tscn").instantiate()
		add_child(textBox)
		textBox.show()
		textBox.powerBar.value = statEnergy
		textBox.set_team_color(teamColor)
	else:
		textBox.set_team_color(teamColor)
		textBox.powerBar.value = statEnergy

func deselect() -> void:
	if has_node("TextBox"):
		get_node("TextBox").queue_free()

func player_is_collision(value) -> void:
	$CollisionShape3D.disabled = value
	$CollisionShape2.disabled = value
	$CollisionShape3.disabled = value
	$CollisionShape4.disabled = value

func player_defend_set() -> void:
	var playerColPos:float = 0.05
	var size:float = (playerColPos * playerDefend)*2
	var pos:float = (playerColPos * playerDefend)
#
	$CollisionShape3D.shape.size.y = size
	$CollisionShape2.shape.size.y = size
	$CollisionShape3.shape.size.y = size
	$CollisionShape4.shape.size.y = size
#
	$CollisionShape3D.position.y = pos
	$CollisionShape2.position.y = pos
	$CollisionShape3.position.y = pos
	$CollisionShape4.position.y = pos

func fix_col():
	$CollisionShape3D.shape.size.x = $CollisionShape3D.shape.size.x *2
	$CollisionShape2.shape.size.x = $CollisionShape2.shape.size.x *2
	$CollisionShape3.shape.size.x = $CollisionShape3.shape.size.x *2
	$CollisionShape4.shape.size.x = $CollisionShape4.shape.size.x *2
	
	$CollisionShape3D.shape.size.z = $CollisionShape3D.shape.size.z *2
	$CollisionShape2.shape.size.z = $CollisionShape2.shape.size.z *2
	$CollisionShape3.shape.size.z = $CollisionShape3.shape.size.z *2
	$CollisionShape4.shape.size.z = $CollisionShape4.shape.size.z *2

func _exit_tree():
	queue_free()
