extends CanvasLayer

@onready var MainGame: = get_parent()

@onready var Guide:Popup
@onready var TestMode:Panel
@onready var PlayerInfo:Control
@onready var PlayerPerformance:Panel
@onready var MatchList:Panel
@onready var GameReward:Popup

@onready var MiniMap: = $MiniMap
@onready var TeamAction: = $MiniMap/TeamAction
@onready var ReplayPlayer: = $ReplayPlayer
@onready var MatchDetail: = $MatchDetail

@onready var formation: = $Formation
@onready var playerStats: = $MainBtn/PlayerStats

@onready var turnNotification: = $Notification
@onready var playerGameStats: = $PlayerGameStats
@onready var playerGameFouls: = $PlayerGameFouls

@onready var panelScore: = $PanelScore
@onready var panelBarInfo: = $BarInfo
@onready var gameNoti: = $Notification
@onready var goalNoti: = $PlayerGameStats/GoalInfo

@onready var UITeam:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeam.tres")
@onready var UITeamCN:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamCN.tres")
@onready var UITeamCP:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamCP.tres")
@onready var UITeamGoal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamPlayerGoal.tres")
@onready var teamAMat:Color = GlobalTheme.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = GlobalTheme.teamColor[Global.teamID2][1]

var time:int = 1

@onready var newTurn: = $BarInfo/ProgressTurn
@onready var blv: = $BlvVoice

func _init():
	Formation_setup()

func _update_team_flag():
	var flag_shader = load("res://Assets3D/Shader/Flag3D_mat.tres")
	var team
	var data = GameData.formation_load_data()
	if Global.MatchPlay == 1:
		team = Team.load_team_icon(data.teams[Global.teamID1].icon)
	else:
		team = Team.load_team_icon(data.teams[Global.teamID2].icon)
	flag_shader.set("shader_param/tex",team)
#
func _ready() -> void:
	_update_team_flag()
	FormationData.isSub = false
	FormationData.isTac = false
	MiniMap.get_node("BtnMiniMap").connect("pressed", Callable(self, "_on_formation_open_pressed"))
	formation.btnClose.connect("pressed", Callable(self, "_on_formation_close_pressed"))
	MatchDetail.get_node("ButtonClose").connect("pressed", Callable(self, "_on_ButtonClose_pressed"))
	MatchDetail.TabControl.connect("on_tab_select", Callable(self, "_on_match_details_tab_changed"))

	if Global.gameModeCur == 1:
		$MainBtn/BtnPlayReplay.hide()
	$MainBtn/BtnCamMode.hide()
	$MainBtn/BtnTestMode.hide()

	formation.btnHome.hide()
	formation.btnClose.show()
	Account.btnAccount.hide()
	Account.info.show()
	MatchDetail.hide()
	formation.hide()
	playerGameStats.hide()
	playerGameFouls.hide()
	turnNotification.hide()
	update_team_info()
	update_team_ui(teamAMat)
	update_Game("Start Game")

	guide_mode_active()

func season_match_list_active() -> void:
	MatchList = load("res://MGF Scene/Season/MatchList.tscn").instantiate()
	$MatchList.show()
	$MatchList.add_child(MatchList)
	await get_tree().create_timer(0).timeout
	MatchList.SeasonSkip = false
	MatchList.hide()
	MatchList.connect("save_season_match_done", Callable(MainGame, "end_game"))
	await get_tree().create_timer(0).timeout
	MatchList._on_BtnSkipMatch_pressed()

func game_reward_active() -> void:
	GameReward = load("res://MGF Scene/Main Game/GameReward.tscn").instantiate()
	$GameReward.show()
	$GameReward.add_child(GameReward)

func player_performance_active() -> void:
	PlayerPerformance = load("res://MGF Scene/Formation/PlayerPerformance.tscn").instantiate()
	$PlayerPerformance.show()
	$PlayerPerformance.add_child(PlayerPerformance)
	PlayerPerformance.save_player_point()
	await get_tree().create_timer(1).timeout
	if Global.MatchPlay == 1:
		PlayerPerformance.load_setup(Global.teamID1)
		PlayerPerformance.save_player_performance(Global.teamID2)
	else:
		PlayerPerformance.load_setup(Global.teamID2)
		PlayerPerformance.save_player_performance(Global.teamID1)

func _on_player_info_pressed() -> void:
	SceneTransition.transition()
	PlayerInfo = load("res://MGF Scene/Market/PlayerCard.tscn").instantiate()
	$PlayerInfo.show()
	$PlayerInfo.add_child(PlayerInfo)
	PlayerInfo.create_art(playerStats.get_node("ID").text)
	PlayerInfo.btnClose.connect("pressed", Callable(self, "player_info_close"))

func player_info_close():
	await get_tree().create_timer(Global.btntime).timeout
	Calculate.remove_children($PlayerInfo)

func test_mode_active():
	if Global.gameModeCur == 3:
		TestMode = load("res://MGF Scene/Main Game/TestMode.tscn").instantiate()
		$TestMode.show()
		$TestMode.add_child(TestMode)
		TestMode.load_test_mode(MainGame.camFollowBall,MainGame.startBall,MainGame.units)
		$MainBtn/BtnTestMode.show()

func guide_mode_active():
	if Global.isGuide == true:
		Guide = load("res://MGF Scene/Main Game/GuideMode.tscn").instantiate()
		$GuideMode.show()
		$GuideMode.add_child(Guide)
		Guide.show()
		ui_visible(false)

func ui_visible(value) -> void:
	panelScore.visible = value
	panelBarInfo.visible = value
	$BlvVoice.visible = value
	$MainBtn.visible = value
	$MiniMap.visible = value

func update_team_ui(mat) -> void:
	mat.a = 0.4
	mat.r -= 0.2
	mat.g -= 0.2
	mat.b -= 0.2
	GlobalTheme.color_UI(UITeam,mat,0.5)
	GlobalTheme.color_UI(UITeamCN,mat,0.5)
	mat.r += 0.2
	mat.g += 0.2
	mat.b += 0.2
	GlobalTheme.color_UI(UITeamCP,mat,0.5)

func debug_main_game(isM = false, ui:String = "",value:String = "",b:String = "") -> void:
	if Global.isDebug == true:
		$Debug.show()
		if isM == false:
			$Debug.text = str(ui)+str(value)+str(b)
		else:
			$Debug.text += "\n" + str(ui)+str(value)+str(b)
	else:
		$Debug.text = ""
		$Debug.hide()

func update_Notification(image = null,mess:String = "",time:float = 1) -> void:
	if MainGame.teamSelect == 1:
		update_team_ui(teamAMat)
	else:
		update_team_ui(teamBMat)
	turnNotification.visible = true
	if image != null:
		$Notification/image.texture = Team.load_team_icon(image)
	else:
		$Notification/image.texture = null
	$Notification/text.text = str(mess)
	await get_tree().create_timer(time).timeout
	turnNotification.visible = false
	MainGame.isStartTurn = true

# warning-ignore:shadowed_variablesss
func update_player_goal_info(unit, mess:String,value:bool = true) -> void:
	var playerName:String = str(unit.playerData.Name)
	var image = Player.load_image(unit.playerData.Icon)
	var count:int = unit.matchGoals
	var imageTeam = Team.load_team_icon(unit.teamData.icon)
	var time:String
	if value == true:
		time = str(MainGame.time) + "'"
	else:
		time = str(MainGame.shotTime)
	
	update_player_data(unit)
	
	var rand_value = blv.goal[randi() % blv.goal.size()]
	if value == true:
		talk(rand_value)
	
	if MainGame.teamSelect == 2:
		teamAMat.a = 0.6
		GlobalTheme.color_UI(UITeamGoal,teamAMat,1)
	else:
		teamBMat.a = 0.6
		GlobalTheme.color_UI(UITeamGoal,teamBMat,1)
	playerGameStats.show()
	$PlayerGameStats/GoalInfo/playerName.text = playerName
	$PlayerGameStats/GoalInfo/playerTex.texture = image
	$PlayerGameStats/GoalInfo/teamTex.texture = imageTeam
	$PlayerGameStats/GoalInfo/goalInfo.text = mess + " " + str(time)
	if count > 1:
		$PlayerGameStats/GoalInfo/goalsInfo.text = str(count) + " Goals Today"
	else:
		$PlayerGameStats/GoalInfo/goalsInfo.text = str(count) + " Goal Today"
	await get_tree().create_timer(3).timeout
	if value == true:
		talk(playerName + " " + NumberToWords.to_words(count) + " goal today!")
	await get_tree().create_timer(3).timeout
	playerGameStats.hide()
	if value == true:
		score_voice()

# warning-ignore:shadowed_variable
func update_player_fouls_info(unit) -> void:
	var playerName = unit.playerData.Name
	var image = Player.load_image(unit.playerData.Icon)
	var count = unit.matchFouls
	var imageTeam = Team.load_team_icon(unit.teamData.icon)
	var color:Color
	
	if count >= 2:
		talk(playerName + " " + "get Red Card.")
		color = Color.RED
		color.a = 0.6
		playerGameFouls.get_node("FoulsInfo/foulInfo").text = "Red Card"
		playerGameFouls.get_node("FoulsInfo").get_stylebox("panel").bg_color = color
	else:
		talk(playerName + " " + "get Yellow Card.")
		color = Color.YELLOW
		color.a = 0.6
		playerGameFouls.get_node("FoulsInfo/foulInfo").text = "Yellow Card"
		playerGameFouls.get_node("FoulsInfo").get_stylebox("panel").bg_color = color
	
	playerGameFouls.show()
	playerGameFouls.get_node("FoulsInfo/playerName").text = playerName
	playerGameFouls.get_node("FoulsInfo/playerTex").texture = image
	playerGameFouls.get_node("FoulsInfo/teamTex").texture = imageTeam
	if count > 1:
		playerGameFouls.get_node("FoulsInfo/foulsInfo").text = str(count) + " Fouls Today"
	else:
		playerGameFouls.get_node("FoulsInfo/foulsInfo").text = str(count) + " Foul Today"
	await get_tree().create_timer(3).timeout
	playerGameFouls.hide()

func update_Times(value:int) -> void:
	if Global.gameModeCur < 2:
		$BarInfo/Margin/Time.text = str(value) + "/" + str(MainGame.gameRound*2)
		if value == MainGame.gameRound:
			MatchDetail.time.text = "HalfTime"
		elif value == MainGame.gameRound*2:
			MatchDetail.time.text = "FullTime"
		else:
			MatchDetail.time.text = "Time " + str(value) + "'"
	else:
		$BarInfo/Margin/Time.text = str(value) + "/∞"
		MatchDetail.time.text = "Time " + str(value) + "'"
	
func update_Game(value) -> void:
	MatchDetail.time.text = str(value)

## Game Update
func return_team_goal(team) -> int:
	var goal:int
	match team:
		1:
			goal = int($PanelScore/Score/teamGoal1.text)
		2:
			goal = int($PanelScore/Score/teamGoal2.text)
	return goal

func update_team_info() -> void:
	var data = GameData.formation_load_data()
	$PanelScore/Score/Teamselect1.texture = Team.load_team_icon(data.teams[Global.teamID1].icon)
	$PanelScore/Score/Teamselect2.texture = Team.load_team_icon(data.teams[Global.teamID2].icon)
	MatchDetail.main.get_node("logoA").texture = Team.load_team_icon(data.teams[Global.teamID1].icon)
	MatchDetail.main.get_node("logoB").texture = Team.load_team_icon(data.teams[Global.teamID2].icon)

func update_Team_GoalA(value) -> void:
	$PanelScore/Score/teamGoal1.text = '%s' % + value
	MatchDetail.main.get_node("goalA").text = '%s' % + value

func update_Team_GoalB(value) -> void:
	$PanelScore/Score/teamGoal2.text = '%s' % + value
	MatchDetail.main.get_node("goalB").text = '%s' % + value

## Player Update
func update_player_data(value) -> void:
	playerStats.get_node("ID").text = str(value.playerID)
	playerStats.get_node("Icon").texture = Player.load_icon(value.playerData.Icon)
	playerStats.get_node("Name").text = "%s" % value.playerData.Name
	playerStats.get_node("Goal").text = "%s" % value.matchGoals
	if value.matchFouls < 2:
		playerStats.get_node("Foul").text = "%s" % value.matchFouls
		playerStats.get_node("Foul").modulate = Color.YELLOW
	else:
		value.playerPositionMath = "NON"
		value.SelectMesh.mesh_select(0)
		playerStats.get_node("Foul").text = "1"
		playerStats.get_node("Foul").modulate = Color.RED

## Thay nguoi
func Formation_setup() -> void:
	if SeasonData.check_season_mode() == true:
		Global.MatchPlay = SeasonData.MatchPlay
	# Set team sub
	if Global.MatchPlay == 1:
		FormationData.teamForm = Global.teamID1
	else:
		FormationData.teamForm = Global.teamID2

## Formation Subs
func _on_match_details_tab_changed(tab) -> void:
	SceneTransition.transition()
	if tab == 1:
		_on_formation_open_pressed()
	if tab == 2:
		MatchDetail.set_up()

func _on_formation_open_pressed() -> void:
	SceneTransition.transition()
	formation.disabled(false)
	FormationData.CanFormation = true
	Account.info.hide()
	formation.update_player_data_MainGame()
	formation.formation_check_team()
	formation.show()
	FormationData.timeSub = MainGame.time
	FormationData.timeTac = MainGame.time
	FormationData.isSub = true
	if FormationData.teamFor == 1:
		FormationData.tacData = [FormationData.teamTac1,FormationData.teamV1,FormationData.teamH1]
	else:
		FormationData.tacData = [FormationData.teamTac2,FormationData.teamV2,FormationData.teamH2]
	get_tree().paused = true

func _on_formation_close_pressed() -> void:
	if FormationData.isSub == true:
		formation.hide()
	_on_ButtonClose_pressed()

## Phim chuc nang trong menu game
func match_detail_visible(value) -> void:
	SceneTransition.transition()
	MatchDetail.TabControl.tab_select(0)
	turnNotification.hide()
	playerGameStats.hide()
	playerGameFouls.hide()
	
	Account.btnAccount.show()
	MatchDetail.update_team_stats(1,MainGame)
	MatchDetail.update_team_stats(2,MainGame)
	MatchDetail.show()
	get_tree().paused = true
#	update_match_details()

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	Account.btnAccount.hide()
	if MainGame.isGameTime < 3:
		SoundGlobal.volume_low()
	$MainBtn/BtnMatchDetail.disabled = false
	time = 1
	MatchDetail.hide()
	get_tree().paused = false

func _on_BtnMatchDetail_pressed() -> void:
	SceneTransition.transition()
	if MainGame.isGameTime < 3:
		SoundGlobal.volume_normal()
	match_detail_visible(1)
	Account.btnAccount.show()

func update_match_details() -> void:
	if MatchDetail.goalA.get_child_count()>0:
		for i in MatchDetail.goalA.get_children():
			i.queue_free()
	if MatchDetail.goalB.get_child_count()>0:
		for i in MatchDetail.goalB.get_children():
			i.queue_free()
	
	var count:int = 1
	for unit in get_tree().get_nodes_in_group("team1"):
		MatchDetail.update_player_stats(1,unit,count,MainGame)
		count += 1
		if unit.matchGoals > 0:
			var ins = MatchDetail.playerGoals.instantiate()
			ins.get_node("Name").text = unit.playerData.Name + " "
			for i in unit.timeGoals.size():
				ins.get_node("Time").text += str(unit.timeGoals[i]) + "'"
			MatchDetail.goalA.add_child(ins)
	count = 1
	for unit in get_tree().get_nodes_in_group("team2"):
		MatchDetail.update_player_stats(2,unit,count,MainGame)
		count += 1
		if unit.matchGoals > 0:
			var ins = MatchDetail.playerGoals.instantiate()
			ins.get_node("Name").text = unit.playerData.Name + " "
			for i in unit.timeGoals.size():
				ins.get_node("Time").text += str(unit.timeGoals[i]) + "'"
			MatchDetail.goalB.add_child(ins)
	count = 1

func _on_BtnCamMode_pressed() -> void:
	SceneTransition.transition()
	MainGame.Cam.position = Vector3(0,Global.camHeight,-0.1)

func _on_BtnTestMode_pressed() -> void:
	SceneTransition.transition()
	if TestMode.visible == true:
		TestMode.visible = false
	else:
		TestMode.visible = true

func _on_BtnChangeMode_pressed() -> void:
	Global.autoMode = $MainBtn/BtnChangeMode.isToggle
	if MainGame.check_team_selected() == true:
		MainGame.change_state(MainGame.SET_IDLE)
		MainGame.AI_action()
	if Global.autoMode == true:
		Notification.push_noti(0,"Auto mode: active")
	else:
		Notification.push_noti(0,"Auto mode: unactive")

func _on_BtnPlayReplay_pressed() -> void:
	SceneTransition.transition()
	ReplayPlayer.play_quick_replay()

func score_voice() -> void:
	var data = GameData.formation_load_data()
	var teamData = data.teams
	var _teamA = teamData[Global.teamID1].fullName + " "
	var _teamB =  " " + teamData[Global.teamID2].fullName
	var AScore = MainGame.TeamA_score
	var BScore = MainGame.TeamB_score
	var text:String
	
	if AScore > BScore:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
	elif AScore == BScore:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
	else:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
	talk(text)

func update_noti_match_results() -> void:
	game_reward_active()
	
	var data = GameData.formation_load_data()
	var teamData = data.teams
	var _teamA = teamData[Global.teamID1].fullName + " "
	var _teamB =  " " + teamData[Global.teamID2].fullName
	var AScore = MainGame.TeamA_score
	var BScore = MainGame.TeamB_score
	var text:String
	
	if MainGame.teamAData[1] == 0:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
		if Global.MatchPlay == 1:
			GameReward.return_result_match(1,text)
		else:
			GameReward.return_result_match(0,text)
	elif MainGame.teamBData[1] == 0:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
		if Global.MatchPlay == 1:
			GameReward.return_result_match(0,text)
		else:
			GameReward.return_result_match(1,text)
	else:
		text = _teamA + str(AScore) + ' - ' + str(BScore) + _teamB
		if AScore > BScore:
			if Global.MatchPlay == 1:
				GameReward.return_result_match(0,text)
			else:
				GameReward.return_result_match(1,text)
		elif AScore < BScore:
			if Global.MatchPlay == 1:
				GameReward.return_result_match(1,text)
			else:
				GameReward.return_result_match(0,text)
		else:
			GameReward.return_result_match(2,text)
	
	Notification.create_achi(5,"Frist Match Achievement", [text])

func talk(value:String, type:bool = true) -> void:
	blv.talk(value,type)
	if type == true:
		Voice.talk(value)

func _exit_tree():
	queue_free()
