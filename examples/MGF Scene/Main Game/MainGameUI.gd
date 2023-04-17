extends CanvasLayer

@onready var mainGame = get_parent()
@onready var panelStats = $PlayerStats
@onready var playerStatGoal = $PlayerGameStats/GoalInfo
@onready var turnNotification = $Notification

@onready var teamAStats = $TeamStats/TeamAStats
@onready var teamBStats = $TeamStats/TeamBStats

@onready var videoPlayer = $VideoStreamPlayer
@onready var matchDetail = $MatchDetail
@onready var formation = $Formation
@onready var playerStats = $PlayerStats
@onready var playerGameStats = $PlayerGameStats
@onready var playerEdit = $PlayerEdit
@onready var teamStats = $TeamStats

@onready var panelScore = $PanelScore
@onready var panelBarInfo = $BarInfo
@onready var gameNoti = $Notification
@onready var goalNoti = $PlayerGameStats/GoalInfo
@onready var UITeam:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeam.tres")
@onready var UITeamCN:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamCN.tres")
@onready var UITeamCP:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamCP.tres")
@onready var UITeamGoal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamPlayerGoal.tres")
@onready var teamAMat:Color = Settings.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = Settings.teamColor[Global.teamID2][1]

var time:int = 1
@onready var tween:Tween = get_tree().create_tween()

@onready var newTurn = $BarInfo/ProgressTurn
@onready var controller = $Controller

func _init():
	Formation_setup()

func _ready():
	matchDetail.tabs.connect("tab_changed",Callable(self,"_on_FormationSubs_tab_changed"))
	matchDetail.btnCloseMain.connect("pressed",Callable(self,"_on_ButtonClose_pressed"))
	matchDetail.btnClose.connect("pressed",Callable(self,"_on_ButtonClose_pressed"))
	if Global.gameModeCur == 1:
		$MainBtn/BtnPlayReplay.hide()
	update_team_ui(teamAMat)
	update_Game("Start")
	matchDetail.hide()
	playerStats.hide()
	playerEdit.hide()
	teamStats.hide()
	formation.hide()
	update_team_info()
	playerGameStats.visible = false
	playerStatGoal.visible = false
	turnNotification.visible = false

func update_team_ui(mat):
	mat.a = 0.6
	mat.r -= 0.2
	mat.g -= 0.2
	mat.b -= 0.2
	Settings.color_UI(UITeam,mat,0.5)
	Settings.color_UI(UITeamCN,mat,0.5)
#	UITeam.set("bg_color",mat)
#	UITeamCN.set("bg_color",mat)
	mat.r += 0.2
	mat.g += 0.2
	mat.b += 0.2
	Settings.color_UI(UITeamCP,mat,0.5)
#	UITeamCP.set("bg_color",mat)

func debug_main_game(isM = false, ui = "",value = "",b = ""):
	if Global.isDebug == true:
		$Debug.show()
		if isM == false:
			$Debug.text = str(ui)+str(value)+str(b)
		else:
			$Debug.text += "\n" + str(ui)+str(value)+str(b)
	else:
		$Debug.text = ""
		$Debug.hide()

# warning-ignore:shadowed_variable
func update_Notification(image = null,mess="",time = 1):
	if mainGame.teamSelect == 1:
		update_team_ui(teamAMat)
	else:
		update_team_ui(teamBMat)
	turnNotification.visible = true
	$Notification/image.texture = image
	$Notification/text.text = str(mess)
	await get_tree().create_timer(time).timeout
	turnNotification.visible = false
	mainGame.isStartTurn = true

# warning-ignore:shadowed_variable
func update_player_goal_info(playerName, image, time, mess, imageTeam, count):
	if mainGame.teamSelect == 2:
		Settings.color_UI(UITeamGoal,teamAMat,1)
	else:
		Settings.color_UI(UITeamGoal,teamBMat,1)
	$PlayerGameStats.visible = true
	playerStatGoal.visible = true
	$PlayerGameStats/GoalInfo/playerName.text = playerName
	$PlayerGameStats/GoalInfo/playerTex.texture = image
	$PlayerGameStats/GoalInfo/teamTex.texture = imageTeam
	$PlayerGameStats/GoalInfo/goalInfo.text = mess + " " + str(time) + "'"
	if count > 1:
		$PlayerGameStats/GoalInfo/goalsInfo.text = str(count) + " Goals Today"
	else:
		$PlayerGameStats/GoalInfo/goalsInfo.text = str(count) + " Goal Today"
	await get_tree().create_timer(time).timeout
	$PlayerGameStats.visible = false
	playerStatGoal.visible = false

func update_Times(value):
	$BarInfo/Margin/Time.text = str(value) + "/" + str(Global.time[Global.SetTime]*2)
	matchDetail.time.text = str(value) + "'"

func update_Game(value):
	matchDetail.time.text = str(value)

## Game Update
func return_team_goal(team):
	var goal
	match team:
		1:
			goal = int($PanelScore/Score/teamGoal1.text)
			return goal
		2:
			goal = int($PanelScore/Score/teamGoal2.text)
			return goal

func update_team_info():
	var data = GameData.formation_load_data()
	$PanelScore/Score/Teamselect1.texture = load(data.teams[Global.teamID1].icon)
	$PanelScore/Score/Teamselect2.texture = load(data.teams[Global.teamID2].icon)
	matchDetail.main.get_node("logoA").texture = load(data.teams[Global.teamID1].icon)
	matchDetail.main.get_node("logoB").texture = load(data.teams[Global.teamID2].icon)

func update_Team_GoalA(value):
	$PanelScore/Score/teamGoal1.text = '%s' % + value
	matchDetail.main.get_node("goalA").text = '%s' % + value

func update_Team_GoalB(value):
	$PanelScore/Score/teamGoal2.text = '%s' % + value
	matchDetail.main.get_node("goalB").text = '%s' % + value

## Player Update
func update_player_data(value):
	playerStats.get_node("TexturePlayer0").texture = value.texturePlayerPath
	$PlayerStats/namePlayer.text = "%s" % value.playerName
	$PlayerStats/playerPosition.text = "%s" % value.playerPosition
	Calculate.position_color($PlayerStats/playerPosition)
	$PlayerStats/playerOverall.text = "%s" % value.playerOverall
	Calculate.stat_color($PlayerStats/playerOverall)
	$PlayerStats/playerPotential.text = "%s" % value.playerPotential
	Calculate.stat_color($PlayerStats/playerPotential)
	$PlayerStats/playerFinishing.text = "%s" % value.statFinishing
	Calculate.stat_color($PlayerStats/playerFinishing)
	$PlayerStats/playerShotPower.text = "%s" % value.statShotPower
	Calculate.stat_color($PlayerStats/playerShotPower)
	$PlayerStats/playerInterception.text = "%s" % value.statTackle
	Calculate.stat_color($PlayerStats/playerInterception)
	$PlayerStats/playerPass.text = "%s" % value.statAccurate
	Calculate.stat_color($PlayerStats/playerPass)
	$PlayerStats/playerSpeed.text = "%s" % value.statSpeed
	Calculate.stat_color($PlayerStats/playerSpeed)
	$PlayerStats/playerControll.text = "%s" % value.statBallControl
	Calculate.stat_color($PlayerStats/playerControll)
	$PlayerStats/playerStamina.text = "%s" % value.statStamina
	Calculate.stat_color($PlayerStats/playerStamina)
	$PlayerStats/playerPower.text = "%s" % value.statPower
	Calculate.stat_color($PlayerStats/playerPower)
	$PlayerStats/playerBody.text = "%s" % value.statBody
	Calculate.stat_color($PlayerStats/playerBody)
	$PlayerStats/playerReflexes.text = "%s" % value.statReflexes
	Calculate.stat_color($PlayerStats/playerReflexes)
	$PlayerStats/playerDefend.text = "%s" % value.statDefend
	Calculate.stat_color($PlayerStats/playerDefend)
	$PlayerStats/playerPenSave.text = "%s" % value.statSave
	Calculate.stat_color($PlayerStats/playerPenSave)
	$PlayerStats/nameGoals.text = "%s" % value.gameGoals
	$PlayerStats/playerAssits.text = "%s" % value.gameAssits
	$PlayerStats/playerPasses.text = "%s" % value.gamePasses
	$PlayerStats/playerMoves.text = "%s" % value.gameMoves
	$PlayerStats/playerStatGames.text = "%s" % value.statGames
	$PlayerStats/playerStatGoals.text = "%s" % value.statGoals
	$PlayerStats/playerStatAssits.text = "%s" % value.statAssits

## Update Team Stat:
func update_team_stats():
	GameData.load_teamStats_data(teamAStats,Global.teamID1)
	GameData.load_teamStats_data(teamBStats,Global.teamID2)

## Phim chuc nang trong menu game
func match_detail_visible(value):
	update_match_details()
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		matchDetail.btnClose.show()
		matchDetail.btnHome.hide()
	else:
		matchDetail.btnClose.hide()
		matchDetail.btnHome.show()
	if mainGame.isGameTime == 3:
		matchDetail.btnClose.hide()
		matchDetail.btnHome.show()
	matchDetail.position = matchDetail.closePos
	matchDetail.show()
	GlobalTween.show_out(matchDetail,value)
	GlobalTween.pos_UI(matchDetail,matchDetail.openPos,value)
#	get_tree().paused = true

## Thay nguoi
func Formation_setup():
	# Set team sub
	if Global.MatchPlay == 1:
		FormationData.teamForm = Global.teamID1
	else:
		FormationData.teamForm = Global.teamID2

## Formation Subs
func _on_FormationSubs_tab_changed(tab):
	if tab == 1:
		formation.modulate = Color(1,1,1,0)
		formation.show()
		GlobalTween.show_out(formation,1)
		formation.get_node("GroupSlots").formation_check_team()
		FormationData.isSub = true

func _on_ButtonTeamSelect_pressed():
	matchDetail.tabs.current_tab = 0
	GlobalTween.fade_out(formation,1)
	await get_tree().create_timer(1).timeout
	formation.hide()

func _on_ButtonClose_pressed():
	$MainBtn/BtnMatchDetail.disabled = false
	time = 1
	matchDetail.tabs.current_tab = 0
	matchDetail.position = matchDetail.openPos
	GlobalTween.fade_out(matchDetail,1)
	GlobalTween.pos_UI(matchDetail,matchDetail.closePos,1)
	await get_tree().create_timer(2).timeout
	matchDetail.hide()
	get_tree().paused = false

func _on_BtnMatchDetail_pressed():
	match_detail_visible(1)
#	$BtnMatchDetail.disabled = true

func update_match_details():
	if matchDetail.goalA.get_child_count()>0:
		for i in matchDetail.goalA.get_children():
			i.queue_free()
	if matchDetail.goalB.get_child_count()>0:
		for i in matchDetail.goalB.get_children():
			i.queue_free()
	
	var count = 1
	for unit in get_tree().get_nodes_in_group("team1"):
		matchDetail.update_player_stats(1,unit,count)
		count += 1
		if unit.gameGoals > 0:
			var ins = matchDetail.playerGoals.instantiate()
			ins.get_node("Name").text = unit.playerName + " "
			for i in unit.timeGoals.size():
				ins.get_node("Time").text += str(unit.timeGoals[i]) + "'"
			matchDetail.goalA.add_child(ins)
	count = 1
	for unit in get_tree().get_nodes_in_group("team2"):
		matchDetail.update_player_stats(2,unit,count)
		count += 1
		if unit.gameGoals > 0:
			var ins = matchDetail.playerGoals.instantiate()
			ins.get_node("Name").text = unit.playerName + " "
			for i in unit.timeGoals.size():
				ins.get_node("Time").text += str(unit.timeGoals[i]) + "'"
			matchDetail.goalB.add_child(ins)
	count = 1

func _on_BtnCamMode_pressed():
	mainGame.Cam.position = Vector3(0,Global.camHeight,0)

func _on_BtnTestMode_pressed():
	if $TestMode.visible == true:
		$TestMode.visible = false
#		$BtnTestMode.modulate = Color.WHITE
	else:
		$TestMode.visible = true
#		$BtnTestMode.modulate = Color.AQUA

func _on_BtnChangeMode_pressed():
	Global.autoMode = $MainBtn/BtnChangeMode.isToggle

func _on_BtnPlayReplay_pressed():
	mainGame.play_quick_replay()
