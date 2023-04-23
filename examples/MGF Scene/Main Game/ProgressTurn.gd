extends ProgressBar

@export var gradient:Gradient

@onready var shader_bar: = preload("res://Assets2D/Theme/FormationStaminaShader.tres").duplicate()

@onready var MainGame:Node3D = get_parent().get_parent().get_parent()
@onready var UI: = get_parent().get_parent()
var isStart:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_turn()

func new_turn() -> void:
	value = 100

func start_time() -> void:
	isStart = true
	new_turn()

func count_down() -> void:
	value -= 0.6/Engine.time_scale

func when_time_is_up():
	return value <= 0

func check_turn() -> bool:
	var va:bool
	if value >= 0:
		va = true
	else:
		va = false
	return va

func _on_Timer_timeout() -> void:
	if (MainGame.isGameTime != 3 and 
	get_tree().paused == false and 
	UI.ReplayPlayer.isPlayReplay == false and
	isStart == true and Global.isGuide == false):
		count_down()
		if when_time_is_up():
			var player = MainGame.selected_units[0]
			if Global.isFoul == true:
				player_foul(player)
				UI.update_player_data(player)
				UI.update_player_fouls_info(player)
			isStart = false
			MainGame.isStartTurn = false
			MainGame.power = 0
			MainGame._on_TimerNewTurn_timeout()

# warning-ignore:unused_argument
func _on_ProgressTurn_value_changed(value) -> void:
	set("theme_override_styles/fg",shader_bar)
	shader_bar.bg_color = gradient.sample(value/100)

func player_foul(player) -> void:
	MainGame.SFXGameWhistle.play()
	player.matchFouls += 1
	
	var data = GameData.formation_load_data()
	var playerData = data.players[player.playerID]
	playerData.Foul[0] = player.matchFouls
	playerData.Foul[1] = player.matchFouls
	
	if player.matchFouls >= 2:
		player.SelectMesh.mesh_select(0)
		player.playerPositionMath = "NON"
		player_out()
		if MainGame.teamSelect == 1:
			if MainGame.teamAData[1] > 0:
				MainGame.teamAData[1] -= 1
				prints("Run",MainGame.teamAData[1])
			UI.TeamAction.update_team_action(MainGame,1)
		else:
			if MainGame.teamBData[1] > 0:
				prints("Run",MainGame.teamAData[2])
				MainGame.teamBData[1] -= 1
			UI.TeamAction.update_team_action(MainGame,2)
		
		playerData.Foul[2] = 1
		playerData.isSub[0] = false
		playerData.isSub[1] = playerData.Team[1]
	
	GameData.formation_save_data(data)

func player_out() -> void:
	var units = MainGame.units
	var team
	if MainGame.teamSelect == 1:
		team = MainGame.teamA
	else:
		team = MainGame.teamB
	var a = -3.4
	for unit in team:
		if unit.playerPositionMath == "NON":
			var pos:Vector3 = Vector3(a,0,1.8)
			GlobalTween.pos_dir_ratio(unit,pos,1.5)
			unit.linear_velocity = Vector3.ZERO
			a += 0.4
			if Global.gameModeCur > 1:
				unit.visible = false

func _exit_tree():
	queue_free()
