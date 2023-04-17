extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	load_test_mode_ui()

func load_test_mode_ui():
	if Global.gameModeCur == 3:
		show()
		load_test_mode_settings()
		get_parent().get_node("MainBtn/BtnTestMode").show()
	else:
		hide()
		get_parent().get_node("MainBtn/BtnTestMode").hide()

func load_test_mode(_isCam,startBall,units):
	_isCam = true
	get_parent().get_node("PlayerStats").show()
	startBall.position.x = Global.BallStart.x
	startBall.position.z = Global.BallStart.z
	for unit in units:
		if unit.team == Global.team1:
			if unit.playerPositionMath != Global.TeamAPlay:
				unit.playerPositionMath = "NON"
			if unit.playerPositionMath != "NON":
				unit.playerPositionMath = Global.TeamAPos
#				unit.playerPosition = "LF"
				
		if unit.team == Global.team2:
			if unit.playerPositionMath != Global.TeamBPlay:
				unit.playerPositionMath = "NON"
			if unit.playerPositionMath != "NON":
				unit.playerPositionMath = Global.TeamBPos
#				unit.playerPosition = "GK"

func load_test_mode_fix(_isCam,startBall,units):
	_isCam = true
	get_parent().get_node("PlayerStats").show()
	startBall.position.x = Global.BallStart.x
	startBall.position.z = Global.BallStart.z
	for unit in units:
		if unit.team == Global.team2:
			if unit.playerPositionMath != Global.TeamBPlay:
				unit.playerPositionMath = "NON"
			if unit.playerPositionMath != "NON":
				unit.playerPositionMath = Global.TeamBPos
#				unit.playerPosition = "GK"

func _on_ButtonClose_pressed():
	hide()

func _on_ButtonApply_pressed():
	Global.gameModeCur = 3
	Global.maxS = float($GKS/max.text)
	
	SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")

func load_player_team(team):
	var data = GameData.get_data(GameData.data_path)
	if team == 1:
		$TeamA/OptionAPlay.clear()
		var teamData = data.teams[Global.teamID1].Fid
		var playerData = data.players
		for i in teamData.size():
			var id = teamData[i]
			var player = playerData[id].Name
	#		var playerIcon = load(playerData[id].texturePath)
	#		$TeamA/OptionAPlay.add_icon_item(playerIcon,player)
			$TeamA/OptionAPlay.add_item(player)
	if team == 2:
		$TeamB/OptionBPlay.clear()
		var teamData = data.teams[Global.teamID2].Fid
		var playerData = data.players
		for i in teamData.size():
			var id = teamData[i]
			var player = playerData[id].Name
			$TeamB/OptionBPlay.add_item(player)

func load_test_mode_settings():
	var data = GameData.get_data(GameData.data_path)
	var players = data.players
	var teamData = data.teams
	$CreatPlayer.clear()
	
	for i in players.size():
		var state = data.players[i].Name
		$CreatPlayer.add_item(state)
	
	$AIState.clear()
	for i in Global.State.size():
		var state = Global.State[i]
		$AIState.add_item(state)
	
	$TeamA/OptionATeam.clear()
	$TeamB/OptionBTeam.clear()
	for i in teamData.size():
		var team = teamData[i].name
		$TeamA/OptionATeam.add_item(team)
		$TeamB/OptionBTeam.add_item(team)
	
	load_player_team(1)
	load_player_team(2)
	
	$TeamA/OptionATeam.selected = Global.teamID1
	$TeamB/OptionBTeam.selected = Global.teamID2
	
	$BallStart/xIput.text = str(Global.BallStart.x)
	$BallStart/yIput.text = str(Global.BallStart.y)
	$BallStart/zIput.text = str(Global.BallStart.z)
	
	$TeamA/OptionAPlay.selected = Global.PosName[Global.TeamAPlay]
	$TeamA/OptionAPos.selected = Global.PosName[Global.TeamAPos]

	$TeamB/OptionBPlay.selected = Global.PosName[Global.TeamBPlay]
	$TeamB/OptionBPos.selected = Global.PosName[Global.TeamBPos]
	
	$GKS/max.text = str(Global.maxS)
	$GKH/min.text = str(Global.minH)
	$GKH/max.text = str(Global.maxH)
	$GKD/min.text = str(Global.minD)
	$GKD/max.text = str(Global.maxD)
	
	$Power/max.text = str(Global.powerTest)
	
	$BallStart/ChangeGoal.button_pressed = Global.isChange
	$ShootTest.button_pressed = Global.isShootTest
	$Power/CheckButton.button_pressed = Global.randomShot
	$Foot/FootAngle.text = str(Global.footAngle)
	$AIState.selected = Global.AIState
	$AIActive.button_pressed = Global.isAIState

func get_player_foot_size(size):
	Global.footSize = float(size)
	$Foot/FootSize.text = str(size)

func get_player_foot_fix(fix):
	Global.footFix = float(fix)
	$Foot/FootFix.text = str(fix)

func _on_OptionAPlay_item_selected(index):
	Global.TeamAPlay = Global.Pos[index]

func _on_OptionAPos_item_selected(index):
	Global.TeamAPos = Global.Pos[index]

func _on_OptionBPlay_item_selected(index):
	Global.TeamBPlay = Global.Pos[index]

func _on_OptionBPos_item_selected(index):
	Global.TeamBPos = Global.Pos[index]

func _on_FootSize_text_changed(new_text):
	Global.footSize = float(new_text)

func _on_FootFix_text_changed(new_text):
	Global.footFix = float(new_text)

func _on_FootAngle_text_changed(new_text):
	Global.footAngle = float(new_text)

func _on_PowerMax_text_changed(new_text):
	Global.powerTest = float(new_text)

func _on_GkHandMin_text_changed(new_text):
	Global.minH = float(new_text)

func _on_GkMax_text_changed(new_text):
	Global.maxH = float(new_text)

func _on_GkDefMin_text_changed(new_text):
	Global.minD = float(new_text)

func _on_GkDefMax_text_changed(new_text):
	Global.maxD = float(new_text)

func _on_BallxIput_text_changed(new_text):
	Global.BallStart.x = float(new_text)

func _on_BallzIput_text_changed(new_text):
	Global.BallStart.z = float(new_text)

func _on_CheckButton_toggled(button_pressed):
	Global.randomShot = button_pressed

func _on_OptionATeam_item_selected(index):
	Global.teamID1 = Global.teamIndex[index]
	load_player_team(1)

func _on_OptionBTeam_item_selected(index):
	Global.teamID2 = Global.teamIndex[index]
	load_player_team(2)

func _on_ChangeGoal_toggled(button_pressed):
	Global.isChange = button_pressed

func _on_ChangeGoal_pressed():
	var A = Global.TeamAPos
	var B = Global.TeamBPos
	Global.TeamAPos = B
	Global.TeamBPos = A
	
	A = Global.TeamAPlay
	B = Global.TeamBPlay
	Global.TeamAPlay = B
	Global.TeamBPlay = A
	
	A = Global.teamID1
	B = Global.teamID2
	Global.teamID1 = B
	Global.teamID2 = A

	Global.BallStart.x = -Global.BallStart.x
	
	_on_ButtonApply_pressed()

func _on_ShootTest_toggled(button_pressed):
	Global.isShootTest = button_pressed

func _on_ShootTest_pressed():
	_on_ButtonApply_pressed()

func _on_AIState_item_selected(index):
	Global.AIState = index

func _on_AIActive_toggled(button_pressed):
	Global.isAIState = button_pressed

func _on_AIActive_pressed():
	_on_ButtonApply_pressed()

func _on_CreatPlayer_item_selected(index):
	Global.team = 1
	var data = GameData.get_data(GameData.data_path)
	var players = data.players
	var ins = load(players[index].filePath).instantiate()
	ins.add_to_group("team1")
	get_parent().get_parent().call_deferred("add_child", ins)
	ins.name = players[index].Name
	ins.position.y = 0.1
