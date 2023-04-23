extends Control

@onready var roundLabel: = $TabBtns/VBoxContainer/LabelBase
@onready var matchRound: = $TabBtns/VBoxContainer/VBoxContainer
@onready var btnSkip: = $TabBtns/VBoxContainer/LabelBase/BtnSkipMatch

@onready var Reward: = $SeasonReward

var insmMatch: = load("res://MGF Scene/Season/MatchsItem.tscn")
var teamSelect:int = SeasonData.get_team_select()

signal save_season_match_done

var thread:Thread
var test:bool = false
var SeasonSkip:bool = true
var SkipMatch:bool = false

## Match info
var aBall = 0;var bBall = 0
var aShot = 0;var bShot = 0
var bD = 0;var aD = 0
var aMiss = 0;var bMiss = 0
var aSave = 0;var bSave = 0
var aGoal = 0;var bGoal = 0
var aPass = 0;var bPass = 0
var aBlock = 0;var bBlock = 0
var aPoint = 0;var bPoint = 0

func _ready() -> void:
	teamSelect = SeasonData.get_team_select()
	if Global.isDebug or test == true:
		btnSkip.show()
	else:
		btnSkip.hide()
	if test == true or Global.isQuit == true:
		await get_tree().create_timer(0).timeout
		show()
		load_setup(1)

func findMatch(value:int) -> void:
	SeasonData.find_match(value)
	season_create_match()

func load_setup(value:int = 0) -> void:
	findMatch(value)
	if SeasonSkip == true:
		$TabBtns/VBoxContainer/GoMatch.show()
		$TabBtns/VBoxContainer/BtnExit.hide()
	else:
		$TabBtns/VBoxContainer/GoMatch.hide()
		$TabBtns/VBoxContainer/BtnExit.show()

func _on_BtnRoundLeft_pressed() -> void:
	SeasonData.MatchDay = int(roundLabel.text)-1
	if SeasonData.MatchDay > 0:
		SeasonData.MatchDay -= 1
		season_create_match()
	else:
		SeasonData.MatchDay = 21
		season_create_match()

func _on_BtnRoundRight_pressed() -> void:
	SeasonData.MatchDay = int(roundLabel.text)-1
	if SeasonData.MatchDay < 21:
		SeasonData.MatchDay += 1
		season_create_match()
	else:
		SeasonData.MatchDay = 0
		season_create_match()

func _on_GoMatch_pressed() -> void:
	findMatch(0)
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	if SeasonData.check_season_finishing() == false:
		Global.isQuit = false
		get_parent().load_setup(1)
	else:
		Notification.push_noti(0,"You have finished this season")
		await get_tree().create_timer(0.5).timeout
		hide()

func _on_BtnClose_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	Global.isQuit = false
	if SeasonSkip == true:
		get_parent().load_setup(2)
	else:
		hide()

func _on_BtnExit_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Global.isQuit = false
	SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")

func _on_BtnSkipMatch_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	print("Skip match loading... " + str(SeasonData.MatchDay+1))
	SeasonData.find_match()
	season_create_match()
	if SeasonData.check_season_finishing() == false:
		if SeasonSkip == true:
			Notification.push_noti(1,"Skip " + roundLabel.text + ":" + "\n" + "Continue!")
			if !Notification.btnYes.is_connected("pressed", Callable(self, "create_match_data")):
				Notification.btnYes.connect("pressed", Callable(self, "create_match_data"))
		else:
			create_match_data()
	else:
		Notification.push_noti(0,"You have finished this season")
		await get_tree().create_timer(0.5).timeout
		hide()

func create_match_data(value:int = 0) -> void:
	if SeasonSkip == true or Global.isQuit == true:
		SceneTransition.start_transition()
	SkipMatch = true
	thread = Thread.new()
	thread.start(Callable(self, "_thread_create_match_data").bind(value))

func _thread_create_match_data(value) -> void:
	SeasonData.isLoad = true
	SeasonData.find_match()
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	
	if leagueResults.size() != SeasonData.MatchDay:
		if leagueResults.size() != 22:
			SeasonData.MatchDay += 1
	
	if SeasonData.check_teams_count() == true:
		if leagueResults.size() == SeasonData.MatchDay:
			SeasonData.isSkip = true
			season_create_match()
			## Save player data
			if test == false:
				for i in 6:
					save_player_match(i)
	SeasonData.isSkip = false
	SeasonData.find_match()
	if SeasonSkip == false:
		SeasonData.find_match(1)
		await get_tree().create_timer(1).timeout
		save_match_data()
		await get_tree().create_timer(2).timeout
		
	call_deferred("create_match_load_done",value)

func create_match_load_done(value:int) -> void:
	thread.call_deferred("wait_to_finish")
	SkipMatch = false
	SeasonData.find_match(1)
	save_league_results()
	load_setup(1)
	if Global.isQuit == true:
		await get_tree().create_timer(1).timeout
		# warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
		print("Save Match Quit Done " + str(SeasonData.MatchDay+1))
	else:
		if SeasonSkip == true:
			await get_tree().create_timer(2).timeout
			SceneTransition.end_transition()
			print("Skip Match Done " + str(SeasonData.MatchDay+1))
		else:
			await get_tree().create_timer(0).timeout
			emit_signal("save_season_match_done")
			print("Save Match Done " + str(SeasonData.MatchDay+1))
	if SeasonSkip == true:
		get_parent().seasonTab.load_setup()
	
	SeasonData.season_finshing_noti()

	if SeasonData.check_season_finishing() == true:
		await get_tree().create_timer(0.2).timeout
		Reward.reward()
	else:
		pass

## Cac ham xu ly tran dau ket thuc
func save_match_data() -> void:
	var MainGame = get_parent().get_parent().get_parent()
	var UI = get_parent().get_parent()
	
	var ssData = GameData.season_load_data()
	var leagueResults = ssData.leagueResults
	var stats = leagueResults[SeasonData.MatchDay][SeasonData.MatchID].match
	var players = leagueResults[SeasonData.MatchDay][SeasonData.MatchID].player
	var playerSS = ssData.players
	#MatchData
	for i in stats.size():
		stats[i][0] = get_team_data_match(i,0)
		stats[i][1] = get_team_data_match(i,1)
	print("_____")
	prints(players[0].size(),players[0])
	print("_____")
	prints(players[1].size(),players[1])
	print("_____")
	#PlayerMatchData
	players[0] = []
	players[1] = []
	for i in get_tree().get_nodes_in_group("team1").size():
		players[0].append(get_player_data_match(1,i))
	for i in get_tree().get_nodes_in_group("team2").size():
		players[1].append(get_player_data_match(2,i))
	#playerData
	for i in players[0].size():
		var statSS = ssData.players[players[0][i][0]].Season
		if players[0][i][2] > 1:
			statSS[0] += 1
			for n in statSS.size():
				if n > 0:
					statSS[n] += players[0][i][n+1]
	for i in players[1].size():
		var statSS = ssData.players[players[1][i][0]].Season
		if players[1][i][2] > 1:
			statSS[0] += 1
			for n in statSS.size():
				if n > 0:
					statSS[n] += players[1][i][n+1]
	#quit game
	if MainGame.isGameTime < 3:
		var lost = -1000 + int(Calculate.rand_num(100))
		Account.diamond(lost)
		if Global.MatchPlay == 1:
			stats[1][0] = 0
			stats[1][1] = 3
		else:
			stats[1][0] = 3
			stats[1][1] = 0
	GameData.season_save_data(ssData)

func get_player_data_match(team:int,id:int):
	var MainGame = get_parent().get_parent().get_parent()
	var UI = get_parent().get_parent()
	var player:Array
	if team == 1:
		player = get_tree().get_nodes_in_group("team1")
	else:
		player = get_tree().get_nodes_in_group("team2")
	var stats:Array = []
	stats.append(player[id].playerID)
	stats.append(player[id].team)
	if player[id].statsPlayTime > 0:
		stats.append(UI.MatchDetail.get_player_point(player[id],team,MainGame))
	else:
		stats.append(0)
	stats.append(player[id].matchGoals)
	stats.append(player[id].matchAssits)
	stats.append(player[id].matchShots)
	stats.append(abs(player[id].matchShots-player[id].matchPasses))
	stats.append(player[id].matchMoves)
	stats.append(player[id].matchMoves)
	if player[id].playerPositionMath == "LF" or player[id].playerPositionMath == "RF":
		stats.append(round(player[id].matchMoves/4))
	elif player[id].playerPositionMath == "CM":
		stats.append(round(player[id].matchMoves/2))
	else:
		stats.append(player[id].matchMoves + round(player[id].matchBlocks*1.0/3.0))
	stats.append(player[id].matchSaves)
	if player[id].playerPositionMath == "GK" or player[id].matchSaves > 0:
		var opShot:int
		var opGoal:int = MainGame.teamGoalC[team-1]
		if team == 1:
			opShot = MainGame.teamShot[1]
		else:
			opShot = MainGame.teamShot[0]
		if opGoal == 0:
			stats.append(100)
		else:
			stats.append(round(((opShot-opGoal)*1.0/opShot)*100))
	else:
		stats.append(0)
	stats.append(player[id].matchOwnGoals)
	stats.append(player[id].matchMistakes)
	return stats

func get_team_data_match(type:int,index:int):
	var MainGame = get_parent().get_parent().get_parent()
	var UI = get_parent().get_parent()
	
	var ball:int = MainGame.teamBall[0] + MainGame.teamBall[1]
	if ball == 0:
		ball = 1
	
	match type:
		0:
			if index == 0:
				return Global.teamID1
			else:
				return Global.teamID2
		1:
			if index == 0:
				return MainGame.TeamA_score
			else:
				return MainGame.TeamB_score
		2:
			return round(MainGame.teamBall[index]*1.0/ball*100)
		3:
			return MainGame.teamShot[index]
		4:
			return abs(MainGame.teamPass[index]-MainGame.teamShot[index])
		5:
			return MainGame.teamDef[index]
		6:
			return MainGame.teamMiss[index]
		7:
			return MainGame.teamSave[index]

func season_create_match() -> void:
	if matchRound.get_child_count() > 0:
		for unit in matchRound.get_children():
			unit.queue_free()
	
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	var teamData = data.teams
	
	SeasonData.allResults = []
	
	var allRound = data.leagueMatchs
	for i in allRound[SeasonData.MatchDay].size():
		var couple = allRound[SeasonData.MatchDay][i]
		var ins = insmMatch.instantiate()
		ins.team = [couple[0],couple[1]]
		
		## Find match
		var findMatch = []
		if couple[0] == teamSelect:
			SeasonData.MatchID = i
			SeasonData.MatchPlay = 1
			Global.teamID1 = couple[0]
			Global.teamID2 = couple[1]
			SeasonData.teamB = couple[1]
			findMatch.append(couple[0])
			findMatch.append(couple[1])
			SeasonData.teamA = couple[0]
			SeasonData.teamB = couple[1]
			ins.get_node("bg").show()
			ins.get_node("Main/teamA/bg").show()
		if couple[1] == teamSelect:
			SeasonData.MatchID = i
			SeasonData.MatchPlay = 2
			Global.teamID1 = couple[0]
			Global.teamID2 = couple[1]
			findMatch.append(couple[0])
			findMatch.append(couple[1])
			SeasonData.teamA = couple[1]
			SeasonData.teamB = couple[0]
			ins.get_node("bg").show()
			ins.get_node("Main/teamB/bg").show()
		if findMatch.size()>0:
			findMatch.append(i)
			SeasonData.Match = findMatch
#			prints(SeasonData.teamA,SeasonData.Match)
		
		## Load match
		if leagueResults.size() > SeasonData.MatchDay:
			var tdata = leagueResults[SeasonData.MatchDay][i]
			ins.get_node("Main/goalA").text = str(tdata.match[1][0])
			ins.get_node("Main/goalB").text = str(tdata.match[1][1])
		ins.id = i
		ins.get_node("Main/id").text = str(i+1)
		ins.get_node("Main/teamA").texture = Team.load_team_icon(teamData[couple[0]].icon)
		ins.get_node("Main/teamB").texture = Team.load_team_icon(teamData[couple[1]].icon)
		ins.get_node("Main/nameA").text = teamData[couple[0]].fullName
		ins.get_node("Main/nameB").text = teamData[couple[1]].fullName
		matchRound.add_child(ins)
		ins.type = 1
		
		## Create match data
		if (SkipMatch == true
		and leagueResults.size() <= SeasonData.MatchDay):
			var tA = couple[0]
			var tB = couple[1]
			get_result_match(tA,tB)
		
			if test == false:
				GameData.save_data(GameData.season_get_file_path(),data)
		
			## Save all match data
			var matchID = {"id":i,"match":[],"player":[]}
			if SeasonSkip == false and i == SeasonData.Match[2]:
				for n in range(8):
					matchID.match.append([0,0])
			else:
				matchID.match.append([tA,tB])
				matchID.match.append([aGoal,bGoal])
				matchID.match.append([aBall,bBall])
				matchID.match.append([aShot,bShot])
				matchID.match.append([aPass,bPass])
				matchID.match.append([aBlock,bBlock])
				matchID.match.append([aMiss,bMiss])
				matchID.match.append([aSave,bSave])
			SeasonData.allResults.append(matchID)
			if SeasonData.isLoad == false:
				ins.get_node("Main/goalA").text = str(aGoal)
				ins.get_node("Main/goalB").text = str(bGoal)
	
	if (SkipMatch == true
	and leagueResults.size() <= SeasonData.MatchDay):
		var resuls = SeasonData.allResults
		leagueResults.append(resuls)
		
		GameData.save_data(GameData.season_get_file_path(),data)
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)

func save_league_results() -> void:
	var data = GameData.season_load_data()
	var teamData = data.teams
	var leagueResults = data.leagueResults
	var stats = leagueResults[SeasonData.MatchDay]
	
	var allRound = data.leagueMatchs
	for i in allRound[SeasonData.MatchDay].size():
		var couple = allRound[SeasonData.MatchDay][i]
		
		aGoal = stats[i].match[1][0]
		bGoal = stats[i].match[1][1]
		## Goal
		teamData[couple[0]].statS[5] = int(teamData[couple[0]].statS[5]) + aGoal
		teamData[couple[1]].statS[5] = int(teamData[couple[1]].statS[5]) + bGoal
		teamData[couple[0]].statS[6] = int(teamData[couple[0]].statS[6]) + bGoal
		teamData[couple[1]].statS[6] = int(teamData[couple[1]].statS[6]) + aGoal
		
		## Match
		teamData[couple[0]].statS[0] = int(teamData[couple[0]].statS[0]) + 1
		teamData[couple[1]].statS[0] = int(teamData[couple[1]].statS[0]) + 1
		
		## Point Team
		if aGoal > bGoal:
			teamData[couple[0]].statS[2] = int(teamData[couple[0]].statS[2]) + 1
			teamData[couple[0]].statS[1] = int(teamData[couple[0]].statS[1]) + 3
			teamData[couple[1]].statS[4] = int(teamData[couple[1]].statS[4]) + 1
		elif aGoal < bGoal:
			teamData[couple[0]].statS[4] = int(teamData[couple[0]].statS[4]) + 1
			teamData[couple[1]].statS[2] = int(teamData[couple[1]].statS[2]) + 1
			teamData[couple[1]].statS[1] = int(teamData[couple[1]].statS[1]) + 3
		else:
			teamData[couple[0]].statS[3] = int(teamData[couple[0]].statS[3]) + 1
			teamData[couple[0]].statS[1] = int(teamData[couple[0]].statS[1]) + 1
			teamData[couple[1]].statS[3] = int(teamData[couple[1]].statS[3]) + 1
			teamData[couple[1]].statS[1] = int(teamData[couple[1]].statS[1]) + 1
		await get_tree().create_timer(0).timeout
	
	teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_goal"))
	teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_point"))
	
	for i in teamData.size():
		teamData[i].index = i+1
	teamData.sort_custom(Callable(MyCustomSorter, "sort_ascending_id"))
	
	GameData.season_save_data(data)

func get_result_match(A,B) -> void:
	## Chi so tong quat
	var aOv = GameData.return_teamStats_data(A,0)
	var aDef = GameData.return_teamStats_data(A,1)
	var aMid = GameData.return_teamStats_data(A,2)
	var aAtk = GameData.return_teamStats_data(A,3)
	var aGK = GameData.return_teamStats_data(A,4)
#	print(A," ",aOv," ",aDef," ",aMid," ",aAtk," ",aGK)
	var bOv = GameData.return_teamStats_data(B,0)
	var bDef = GameData.return_teamStats_data(B,1)
	var bMid = GameData.return_teamStats_data(B,2)
	var bAtk = GameData.return_teamStats_data(B,3)
	var bGK = GameData.return_teamStats_data(B,4)
#	print(B," ",bOv," ",bDef," ",bMid," ",bAtk," ",bGK)
		
	aBall = 0;bBall = 0;aShot = 0;bShot = 0
	bD = 0;aD = 0;aPass = 0;bPass = 0
	aBlock = 0;bBlock = 0;aMiss = 0;bMiss = 0
	aGoal = 0;bGoal = 0;aSave = 0;bSave = 0
	
	## Gianh duoc bong
	for i in 90:
		var a = rand_num((aMid+aOv)/2.0)
		var b = rand_num((bMid+bOv)/2.0)
		if a > b:
			aBall += 1
		elif a < b:
			bBall += 1
#	print("Mid ",aBall," ",bBall," ")
	
	## Team A tan cong ghi ban
	for i in aBall:
		var a = rand_num(aAtk/2.5)
		var b = rand_num(bDef)
		if a > b:
			aShot += 1
		elif a < b:
			bD += 1
#	print("AShot ",aShot," ",bD)
	
	if aOv > bOv:
		aShot += round((aOv-bOv)/4.0)
	elif aOv < bOv:
		bShot += round((bOv-aOv)/4.0)
	
	## Team b tan cong ghi ban
	for i in bBall:
		var a = rand_num(bAtk/2.5)
		var b = rand_num(aDef)
		if a > b:
			bShot += 1
		elif a < b:
			aD += 1
#	print("BShot ",bShot," ",aD)
	
	## Thong so chuyen bong, chan bong
	for i in aBall:
		var a = rand_num((aMid+aOv)/9.0)
		var b = rand_num(bDef/5)
		if a > b:
			aPass += 1
	
	for i in bBall:
		var a = rand_num((aMid+aOv)/9.0)
		var b = rand_num(aDef/5)
		if a > b:
			bPass += 1
	
	## Thong so phong thu
	for i in aD:
		var a = rand_num((aDef+aOv)/14.0)
		var b = rand_num(bAtk/5)
		if a > b:
			aBlock += 1
	
	for i in bD:
		var a = rand_num((bDef+aOv)/14.0)
		var b = rand_num(aAtk/5)
		if a > b:
			bBlock += 1
	## Sut truot
	for i in aShot:
		if rand_num(bDef/2.0) > rand_num(aAtk):
			aMiss += 1
	for i in bShot:
		if rand_num(aDef/2.0) > rand_num(bAtk):
			bMiss += 1
#	print("Miss ",aMiss," ",bMiss)
	
	## Ban thang team A
	for i in (aShot-aMiss):
		var a = rand_num((aAtk)/14.0)
		var b = rand_num(bGK/5.0)
		if a > b:
			aGoal += 1
		elif a < b:
			bSave += 1
#	print("AGoal ",aGoal," ",bSave)
	## Ban thang team B
	for i in (bShot-aMiss):
		var a = rand_num((bAtk)/14.0)
		var b = rand_num(aGK/5.0)
		if a > b:
			bGoal += 1
		elif a < b:
			aSave += 1
#	print("BGoal ",bGoal," ",aSave)
	
	## Ket qua
#	print("_____")
#	print(A," ",aGoal," - ",bGoal," ",B)
#	print("_____")

func save_player_match(matchID) -> void:
	get_player_resuts(0,matchID)
	get_player_resuts(1,matchID)
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	var playerTeam = []
	
	## Lua du lieu cau thu trong tran
	var matchR = SeasonData.MatchDay
	var matchData = leagueResults[matchR][matchID]
	
# warning-ignore:shadowed_variable
	var teamA = matchData.match[0][0]
	var teamB = matchData.match[0][1]
	var teamData
	var player = data.players
	teamData = data.teams[teamA].Fid
	var playerTeamA = []
	var playerTeamB = []
	for n in teamData.size():
		var playerID = teamData[n]
		var playerStats = []
		playerStats.append(player[playerID].PlayerID)
		playerStats.append(teamA)
		playerStats.append(player[playerID].Match[1])
		playerStats.append(player[playerID].Match[2])
		playerStats.append(player[playerID].Match[3])
		playerStats.append(player[playerID].Match[4])
		playerStats.append(player[playerID].Match[5])
		playerStats.append(player[playerID].Match[6])
		playerStats.append(player[playerID].Match[7])
		playerStats.append(player[playerID].Match[8])
		playerStats.append(player[playerID].Match[9])
		playerStats.append(player[playerID].Match[10])
		playerStats.append(player[playerID].Match[11])
		playerStats.append(player[playerID].Match[12])
		playerTeamA.append(playerStats)
	teamData = data.teams[teamB].Fid
	for n in teamData.size():
		var playerID = teamData[n]
		var playerStats = []
		playerStats.append(player[playerID].PlayerID)
		playerStats.append(teamB)
		playerStats.append(player[playerID].Match[1])
		playerStats.append(player[playerID].Match[2])
		playerStats.append(player[playerID].Match[3])
		playerStats.append(player[playerID].Match[4])
		playerStats.append(player[playerID].Match[5])
		playerStats.append(player[playerID].Match[6])
		playerStats.append(player[playerID].Match[7])
		playerStats.append(player[playerID].Match[8])
		playerStats.append(player[playerID].Match[9])
		playerStats.append(player[playerID].Match[10])
		playerStats.append(player[playerID].Match[11])
		playerStats.append(player[playerID].Match[12])
		playerTeamB.append(playerStats)
	
	playerTeam.append(playerTeamA)
	playerTeam.append(playerTeamB)
	matchData.player = playerTeam
	GameData.season_save_data(data)

func get_player_resuts(teamID,matchID) -> void:
	var matchR = SeasonData.MatchDay
	
	var asi = 0
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	var matchData = leagueResults[matchR][matchID].match
	
	var team = matchData[0][teamID]
	var shot = matchData[3][teamID]
	var pas = matchData[4][teamID]
	var block = matchData[5][teamID]
	var save = matchData[7][teamID]
	var goal = matchData[1][teamID]
	
	var teamData = data.teams[team].Fid
	var player = data.players
	
	var Max:int
	
	## Match = 0
	for i in teamData.size():
		var playerID = teamData[i]
		for j in player[playerID].Match.size():
			player[playerID].Match[j] = 0
	
	## So lan cuu thua
	var gk =  player[teamData[0]]
	if gk.Team[1] == "GK":
		gk.Match[9] = save
		gk.Season[9] = int(gk.Season[9]) + save
#		prints("Save:",gk.Name,gk.statSaves)
	
	## Assits
	for i in goal:
		var a = rand_num(15)
		var b = rand_num(10)
		if a > b:
			asi += 1
	
	## Tinh so chuyen bong
	while asi > 0 or pas > 0:
		for i in range(6,-1,-1):
			var playerID = teamData[i]
			var pos = player[playerID].Team[1]
			var stats = player[playerID].Overall[2]
			## Mid
			if pos == "CM":
				Max = 80
			## Atk
			elif (pos == "LF"
			or pos == "RF"):
				Max = 120
			## DEF
			elif (pos == "CB"
			or pos == "LB"
			or pos == "RB"):
				Max = 150
			elif pos == "GK":
				Max = 200
			if rand_num(int(stats)) > rand_num(Max):
				if asi > 0:
					player[playerID].Match[3] += 1
					asi -= 1
				if pas > 0:
					player[playerID].Match[5] += 1
					pas -= 1
	
	## Tinh so ban thang
	while goal > 0 or shot > 0:
		for i in range(6,-1,-1):
			var playerID = teamData[i]
			var pos = player[playerID].Team[1]
			var stats = player[playerID].Overall[1]
			## ATK
			if (pos == "LF"
			or pos == "RF"):
				Max = 80
			## MID
			elif (pos == "CM"):
				Max = 150
			## DEF
			elif (pos == "LB"
			or pos == "RB"):
				Max = 500
			elif pos == "CB":
				Max = 600
			## Tim so ban thang
			if rand_num(int(stats)) > rand_num(Max):
				if goal > 0:
					player[playerID].Match[2] += 1
					goal -= 1
				if shot > 0:
					player[playerID].Match[4] += 1
					shot -= 1
	
	## Tinh so can pha
	while block > 0:
		for i in 7:
			var playerID = teamData[i]
			var pos = player[playerID].Team[1]
			var stats = player[playerID].Overall[3]
			## ATK
			if (pos == "CB"
			or pos == "LB"
			or pos == "RB"):
				Max = 80
			## MID
			elif (pos == "CM"):
				Max = 120
			## DEF
			elif (pos == "LF"
			or pos == "RF"):
				Max = 200
			if block > 0:
				if rand_num(int(stats)) > rand_num(Max):
					player[playerID].Match[8] += 1
					block -= 1
	
	## Tinh diem cau thu
	for i in 7:
		var playerID = teamData[i]
		var pos = player[playerID].Team[1]
		if (pos != "NON"):
			player[playerID].Match[1] = (
				6 + (player[playerID].Match[2]) +
				(player[playerID].Match[3]/2.0) +
				(player[playerID].Match[5]/10.0) +
				(player[playerID].Match[7]/4.5) +
				(player[playerID].Match[8]/4.5) +
				(player[playerID].Match[9]/5.0) -
				(player[playerID].Match[11]) -
				(player[playerID].Match[12]/2.0)
			)
			var aG = matchData[1][0]
			var bG = matchData[1][1]
			if teamID == 0:
				if aG>bG:
					player[playerID].Match[1] += 0.2
				else:
					player[playerID].Match[1] -= 0.1
			else:
				if bG>aG:
					player[playerID].Match[1] += 0.2
				else:
					player[playerID].Match[1] -= 0.1
			## GK point
			if (pos == "GK"):
				if teamID == 0:
					# goal 6, shoot 2, miss 7, save 5
					# save/shot
					if bG == 0:
						player[playerID].Match[10] = 100.0
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[10] = float(matchData[7][0])/float(matchData[7][0]+matchData[1][1])*100.0
						player[playerID].Match[1] -= bG/2.0
				else:
					if aG == 0:
						player[playerID].Match[10] = 100.0
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[10] = float(matchData[7][1])/float(matchData[7][1]+matchData[1][0])*100.0
						if player[playerID].Match[10] > 100:
							player[playerID].Match[10] = 100.0
						player[playerID].Match[1] -= aG/2.0
			## Def point
			elif (pos == "GK"):
				if teamID == 0:
					if bG == 0:
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[1] -= bG/5
				else:
					if aG == 0:
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[1] -= aG/5
			elif (pos == "CB"
				or pos == "LB"
				or pos == "RB"):
				if teamID == 0:
					if bG == 0:
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[1] -= bG/8
				else:
					if aG == 0:
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[1] -= aG/8
			elif pos == "CM":
				if teamID == 0:
					if bG != 0:
						player[playerID].Match[1] -= bG/4
				else:
					if aG != 0:
						player[playerID].Match[1] -= aG/4
			player[playerID].Match[1] = clamp(player[playerID].Match[1],0.0,10.0)
			
			if SeasonSkip == false and matchID == SeasonData.Match[2]:
				for n in player[playerID].Match.size():
					player[playerID].Match[n] = 0
			else:
				player[playerID].Season[0] = int(player[playerID].Season[0]) + 1
				player[playerID].Season[1] = float(player[playerID].Season[1]) + float(player[playerID].Match[1])
				player[playerID].Season[2] = int(player[playerID].Season[2]) + int(player[playerID].Match[2])
				player[playerID].Season[3] = int(player[playerID].Season[3]) + int(player[playerID].Match[3])
				player[playerID].Season[4] = int(player[playerID].Season[4]) + int(player[playerID].Match[4])
				player[playerID].Season[5] = int(player[playerID].Season[5]) + int(player[playerID].Match[5])
				player[playerID].Season[8] = int(player[playerID].Season[8]) + int(player[playerID].Match[8])
				player[playerID].Season[9] = int(player[playerID].Season[9]) + int(player[playerID].Match[9])
				player[playerID].Season[10] = int(player[playerID].Season[10]) + int(player[playerID].Match[10])
	
	if test == false:
		GameData.season_save_data(data)
		for i in 7:
			var playerID = teamData[i]
			var point = player[playerID].Match[1]
			player_point_up(playerID,point)

static func player_point_up(id,point) -> void:
#	var pData:String
	if point > 0:
		var all = 0
		var po = 7-float(point)
		all -= float(po)
		point = all
	var data = GameData.season_load_data()
	var playerData = data.players[int(id)]
	var playerPos = playerData.Team[1]
#		pData = str(playerData.Name) + " "
	var o = playerData.Overall
	var oD = []
	for i in o.size():
		var a = o[i]
		oD.append(float(a))
#		pData += str(oD)
	var nD = []
	var n = 0
	for i in o.size():
#		var O = 100
		var O = o[0]
		var g = 22
		var p = point
		if p>0:
			if O < 60:
				n = remap(O,0,60,20*p,15*p)/g
			elif O >=60 and O < 80:
				n = remap(O,60,80,15*p,8*p)/g
			elif O >=80 and O < 90:
				n = remap(O,80,100,8*p,5*p)/g
			elif O >=90 and O < 100:
				n = remap(O,80,100,5*p,1*p)/g
			else:
				n = 0
		else:
			if O < 60:
				n = remap(O,0,60,2*p,3*p)/g
			elif O >=60 and O < 80:
				n = remap(O,60,80,3*p,5*p)/g
			elif O >=80 and O < 90:
				n = remap(O,60,80,8*p,12*p)/g
			elif O >=90 and O < 100:
				n = remap(O,10,100,12*p,15*p)/g
		n = float("%.2f" % n)
		n = clamp(n,-10.0,100.0)
		
		var a = o[i]
		
		if i == 0:
			a += n
		## Tinh theo vt
		if playerPos == "GK":
			if i == 1:
				a += n/4
			elif i == 2:
				a += n/3
			elif i == 3:
				a += n/2
			elif i == 4:
				a += n
		elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
			if i == 1:
				a += n/4
			elif i == 2:
				a += n/2
			elif i == 3:
				a += n
		elif playerPos == "CM":
			if i == 1:
				a += n/2
			elif i == 2:
				a += n
			elif i == 3:
				a += n/4
		elif playerPos == "RF" or playerPos == "LF":
			if i == 1:
				a += n
			elif i == 2:
				a += n/2
			elif i == 3:
				a += n/4
		a = clamp(a,0.0,99.0)
		nD.append(a)
	data.players[id].Overall = nD
	
	## All Stats
	var S = playerData.Stat
	var stats = []
	
	for i in S.size():
		if i < 13:
			var s = S[i]
			if i == 4 or i == 5 or i == 6 or i == 7:
				s += n/2
			elif i == 12:
				s += n/2
			## Tinh theo vt
			if playerPos == "GK":
				if i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n/2
				elif i == 10 or i == 11:
					s += n
			elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
				if i == 0 or i == 1:
					s += n/4
				elif i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n
			elif playerPos == "CM":
				if i == 0 or i == 1:
					s += n/2
				elif i == 2 or i == 3:
					s += n
				elif i == 8 or i == 9:
					s += n/2
			elif playerPos == "RF" or playerPos == "LF":
				if i == 0 or i == 1:
					s += n
				elif i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n/4
			s = clamp(s,0.0,99.0)
			stats.append(s)
	data.players[id].Stat = stats
	
	GameData.season_save_data(data)

#var playerStats = {
#	"Finishing": 0,"ShotPower": 1,
#
#	"Accurate": 2,"BallControl": 3,
#
#	"Stamina": 4,"Speed": 5,"Power": 6,"Body": 7,
#
#	"Tackle": 8,"Defend": 9,
#
#	"Save": 10,"Reflexes": 11}

static func rand_num(value) -> float:
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	var number:float = rng.randf_range(0, value)
	return number

class MyCustomSorter:
	static func sort_ascending_id(a, b):
		if int(a.id) < int(b.id):
			return true
		return false
	static func sort_ascending_point(a, b):
		if int(a.statS[1]) > int(b.statS[1]):
			return true
		return false

	static func sort_ascending_goal(a, b):
		if int(a.statS[5])-int(a.statS[6]) > int(b.statS[5])-int(b.statS[6]):
			return true
		return false

func _exit_tree():
	Global.MGFMode = Global.Season
	queue_free()
