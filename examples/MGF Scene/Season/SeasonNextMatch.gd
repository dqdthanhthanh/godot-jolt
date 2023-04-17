extends TabBar

var test:bool = false

var thread

var rng = RandomNumberGenerator.new()
var teamA
## Match info
var aBall = 0
var bBall = 0
var elseBall = 0
var aShot = 0
var bShot = 0
var bD = 0
var aD = 0
var aMiss = 0
var bMiss = 0
var aSave = 0
var bSave = 0
var aGoal = 0
var bGoal = 0
var aPass = 0
var bPass = 0
var aBlock = 0
var bBlock = 0
var aPoint = 0
var bPoint = 0

#var teamB
var insmMatch = load("res://MGF Scene/Season/Match.tscn")
@onready var roundLabel = $TabBtns/VBoxContainer/LabelBase
@onready var matchRound = $TabBtns/VBoxContainer/VBoxContainer
@onready var settings = get_parent().get_node("Settings")
@onready var ssMenu = get_parent().get_parent().get_parent()
@onready var matchInfo = ssMenu.get_node("MatchInfo")
@onready var disable = ssMenu.disable
var swipeCount = 0
var swipePos:Vector2
var swipeSpeed = 0
var _pressed:bool = true


func _ready():
	matchInfo.get_node("ButtonClose").connect("pressed",Callable(self,"_on_match_info_btn_close_pressed"))

# Swipe change match
func _input(event):
	if get_parent().current_tab == 1 and ssMenu.ssMatch.visible == false:
		if event is InputEventScreenTouch:
			swipePos = event.position
			swipeCount = 0
		if event is InputEventScreenDrag:
			swipeSpeed = 0
			swipeCount += 1
			swipeSpeed += event.position.length()
#			prints(swipeSpeed/count,count)
			if swipeSpeed/swipeCount>600:
				if swipePos.length() < event.position.length():
					_on_NextRight_pressed()
				elif swipePos.length() > event.position.length():
					_on_NextLeft_pressed()

func load_setup():
	SeasonData.find_match()
	if SeasonData.isLoad == true:
		if SeasonData.check_season_finishing() == false:
			SeasonData.MatchDay -= 1
			save_league_results()
			if SeasonData.check_season_match_finishing() == true:
				SeasonData.MatchDay += 1
		else:
			season_finishing()
		SeasonData.isLoad = false
	SeasonData.isLoad = false
	teamA = SeasonData.get_team_select()
	
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)
	round_robin_gen()
	season_create_match()
	
func get_player_resuts(teamID,matchID):
	var matchR = SeasonData.MatchDay
	
	var asi = 0
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	var matchData = leagueResults[matchR][matchID]
	
	var team = matchData[0][teamID]
	var shot = matchData[2][teamID]
	var pas = matchData[3][teamID]
	var block = matchData[4][teamID]
	var save = matchData[5][teamID]
	var goal = matchData[6][teamID]
#	var point = matchData[7][teamID]
	
	var teamData = data.teams[team].Fid
	var player = data.players
	
	## Match
	for i in teamData.size():
		var playerID = teamData[i]
		for j in player[playerID].Match.size():
			player[playerID].Match[j] = 0
	
	## So lan cuu thua
	var gk =  player[teamData[0]]
	if gk.Team[1] == "GK":
		gk.Match[9] = save
		gk.Season[9] = int(gk.Season[9]) + save
#		print("Save: ",gk.Name," ",gk.statSaves)
	
	## Assits
	for i in goal:
		var a = rand_num(15)
		var b = rand_num(10)
		if a > b:
			asi += 1
#	print(asi)
	
	## Tinh so chuyen bong
	while asi > 0 or pas > 0:
		for i in range(6,-1,-1):
			var playerID = teamData[i]
			var stats = player[playerID].Overall[2]
			## Mid
			if player[playerID].Team[1] == "CM":
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(100):
					if asi > 0:
						player[playerID].Match[3] += 1
						asi -= 1
					if pas > 0:
						player[playerID].Match[5] += 1
						pas -= 1
			## Atk
			elif (player[playerID].Team[1] == "LF"
			or player[playerID].Team[1] == "RF"):
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(150):
					if asi > 0:
						asi -= 1
						player[playerID].Match[3] += 1
					if pas > 0:
						player[playerID].Match[5] += 1
						pas -= 1
			## DEF
			elif (player[playerID].Team[1] == "GK"
			or player[playerID].Team[1] == "CB"
			or player[playerID].Team[1] == "LB"
			or player[playerID].Team[1] == "RB"):
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(200):
					if asi > 0:
						player[playerID].Match[3] += 1
						asi -= 1
					if pas > 0:
						player[playerID].Match[5] += 1
						pas -= 1
#			print("Assits: ",player[playerID].Name," ",player[playerID].Match[3])
#			print("Pass: ",player[playerID].Name," ",player[playerID].Match[5])
	
	## Tinh so ban thang
	while goal > 0 or shot > 0:
		for i in range(6,-1,-1):
			var playerID = teamData[i]
			var stats = player[playerID].Overall[1]
			## ATK
			if (player[playerID].Team[1] == "LF"
			or player[playerID].Team[1] == "RF"):
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(80):
					if goal > 0:
						player[playerID].Match[2] += 1
						goal -= 1
					if shot > 0:
						player[playerID].Match[4] += 1
						shot -= 1
			## MID
			elif (player[playerID].Team[1] == "CM"):
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(150):
					if goal > 0:
						goal -= 1
						player[playerID].Match[2] += 1
					if shot > 0:
						player[playerID].Match[4] += 1
						shot -= 1
			## DEF
			elif  (player[playerID].Team[1] == "CB"
			or player[playerID].Team[1] == "LB"
			or player[playerID].Team[1] == "RB"):
#				print(player[playerID].Name)
				if rand_num(int(stats)) > rand_num(500):
					if goal > 0:
						player[playerID].Match[2] += 1
						goal -= 1
					if shot > 0:
						player[playerID].Match[4] += 1
						shot -= 1
#			print("Goal: ",player[playerID].Name," ",player[playerID].Match[2])
#			print("Shot: ",player[playerID].Name," ",player[playerID].Match[4])

#	## Tinh so can pha
	while block > 0:
		for i in 7:
			var playerID = teamData[i]
			var stats = player[playerID].Overall[3]
			## ATK
			if (player[playerID].Team[1] == "CB"
			or player[playerID].Team[1] == "LB"
			or player[playerID].Team[1] == "RB"):
				if block >0:
#					print(player[playerID].Name," ",player[playerID].Match[8])
					if rand_num(int(stats)) > rand_num(100):
						player[playerID].Match[8] += 1
						block -= 1
			## MID
			elif (player[playerID].Team[1] == "CM"):
				if block > 0:
#					print(player[playerID].Name," ",player[playerID].Match[8])
					if rand_num(int(stats)) > rand_num(120):
						player[playerID].Match[8] += 1
						block -= 1
			## DEF
			elif (player[playerID].Team[1] == "LF"
			or player[playerID].Team[1] == "RF"):
				if block > 0:
#					print(player[playerID].Name," ",player[playerID].Match[8])
					if rand_num(int(stats)) > rand_num(300):
						player[playerID].Match[8] += 1
						block -= 1
#			print(player[playerID].Name," ",player[playerID].Match[8])
	
	## Tinh diem cau thu
	for i in 7:
		var playerID = teamData[i]
		if (player[playerID].Team[1] == "GK"
			or player[playerID].Team[1] == "CB"
			or player[playerID].Team[1] == "LB"
			or player[playerID].Team[1] == "RB"
			or player[playerID].Team[1] == "CM"
			or player[playerID].Team[1] == "RF"
			or player[playerID].Team[1] == "LF"):
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
			var aG = matchData[6][0]
			var bG = matchData[6][1]
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
			if (player[playerID].Team[1] == "GK"):
				if teamID == 0:
					# goal 6, shoot 2, miss 7, save 5
					# save/shot
					if bG == 0:
						player[playerID].Match[10] = 100.0
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[10] = float(matchData[5][0])/float(matchData[5][0]+matchData[6][1])*100.0
						player[playerID].Match[1] -= bG/2.0
				else:
					if aG == 0:
						player[playerID].Match[10] = 100.0
						player[playerID].Match[1] += 1
					else:
						player[playerID].Match[10] = float(matchData[5][1])/float(matchData[5][1]+matchData[6][0])*100.0
						if player[playerID].Match[10] > 100:
							player[playerID].Match[10] = 100.0
						player[playerID].Match[1] -= aG/2.0
			## Def point
			elif (player[playerID].Team[1] == "GK"):
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
			elif (player[playerID].Team[1] == "CB"
				or player[playerID].Team[1] == "LB"
				or player[playerID].Team[1] == "RB"):
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
			elif player[playerID].Team[1] == "CM":
				if teamID == 0:
					if bG != 0:
						player[playerID].Match[1] -= bG/4
				else:
					if aG != 0:
						player[playerID].Match[1] -= aG/4
			
			player[playerID].Match[1] = clamp(player[playerID].Match[1],0.0,10.0)
			
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
			Calculate.player_point_up(playerID,point)

func save_player_match(matchID):
	get_player_resuts(0,matchID)
	get_player_resuts(1,matchID)
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	var playerTeam = []
	
	## Lua du lieu cau thu trong tran
	var matchR = SeasonData.MatchDay
	var matchData = leagueResults[matchR][matchID]
	
# warning-ignore:shadowed_variable
	var teamA = matchData[0][0]
	var teamB = matchData[0][1]
	var teamData
	var player = data.players
	teamData = data.teams[teamA].Fid
	var playerTeamA = []
	var playerTeamB = []
	for n in teamData.size():
		var playerID = teamData[n]
		var playerStats = []
		playerStats.append(player[playerID].PlayerID)
		playerStats.append(player[playerID].Match[0])
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
		playerStats.append(player[playerID].Match[0])
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
	SeasonData.playerResults.append(playerTeam)

func min_arr(arr):
	var min_val = arr[0]

	for i in range(1, arr.size()):
		min_val = min(min_val, arr[i])

	return min_val

func max_arr(arr):
	var max_val = arr[0]

	for i in range(1, arr.size()):
		max_val = max(max_val, arr[i])

	return max_val

func get_result_match(A,B):
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
		
	aBall = 0
	bBall = 0
	aShot = 0
	bShot = 0
	bD = 0
	aD = 0
	aPass = 0
	bPass = 0
	aBlock = 0
	bBlock = 0
	aMiss = 0
	bMiss = 0
	aGoal = 0
	bGoal = 0
	aSave = 0
	bSave = 0
	
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
	pass

func rand_num(value):
	rng.randomize()
	var number = rng.randf_range(0, value)
	return number

func season_create_match():
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	var teamData = data.teams
	
	SeasonData.allResults = []
	
	if matchRound.get_child_count() > 0:
		for unit in matchRound.get_children():
			unit.queue_free()
# warning-ignore:unused_variable
	var allRound = SeasonData.allMatch.size()
	for i in SeasonData.allMatch[SeasonData.MatchDay].size():
		var couple = SeasonData.allMatch[SeasonData.MatchDay][i]
		var ins = insmMatch.instantiate()
		
		## Find match
		var findMatch = []
		if couple[0] == teamA:
			SeasonData.MatchID = i
			SeasonData.MatchPlay = 1
			Global.teamID1 = couple[0]
			Global.teamID2 = couple[1]
			SeasonData.teamB = couple[1]
			findMatch.append(couple[0])
			findMatch.append(couple[1])
			SeasonData.teamA = couple[0]
			SeasonData.teamB = couple[1]
			ins.get_node("panel").show()
			ins.get_node("bgA").show()
		if couple[1] == teamA:
			SeasonData.MatchID = i
			SeasonData.MatchPlay = 2
			Global.teamID1 = couple[0]
			Global.teamID2 = couple[1]
			findMatch.append(couple[0])
			findMatch.append(couple[1])
			SeasonData.teamA = couple[1]
			SeasonData.teamB = couple[0]
			ins.get_node("panel").show()
			ins.get_node("bgB").show()
		if findMatch.size()>0:
			findMatch.append(i)
			SeasonData.matchPlay = findMatch
		
		## Load match
		if leagueResults.size() > SeasonData.MatchDay:
#			if i != SeasonData.matchPlay[2]:
			var tdata = leagueResults[SeasonData.MatchDay][i]
			ins.get_node("goalA").text = str(tdata[6][0])
			ins.get_node("goalB").text = str(tdata[6][1])
		ins.id = i
		ins.get_node("Match").text = str(i+1)
		ins.get_node("teamA").texture = load(teamData[couple[0]].icon)
		ins.get_node("teamB").texture = load(teamData[couple[1]].icon)
		matchRound.add_child(ins)
		
		## Create match data
		if (SeasonData.isSkip == true
		and leagueResults.size() <= SeasonData.MatchDay):
#			if i != SeasonData.matchPlay[2]:
				var tA = couple[0]
				var tB = couple[1]
				get_result_match(tA,tB)
			
				if test == false:
					GameData.save_data(GameData.season_get_file_path(),data)
			
				## Save all match data
				var matchI = []
				var matchTeam = [tA,tB]
				var matchBall = [aBall,bBall]
				var matchShot = [aShot,bShot]
				var matchPass = [aPass,bPass]
				var matchBlock = [aBlock,bBlock]
				var matchMiss = [aMiss,bMiss]
				var matchKeeper = [aSave,bSave]
				var matchGoal = [aGoal,bGoal]
				matchI.append(matchTeam)
				matchI.append(matchBall)
				matchI.append(matchShot)
				matchI.append(matchPass)
				matchI.append(matchBlock)
				matchI.append(matchKeeper)
				matchI.append(matchGoal)
				matchI.append(matchMiss)
				SeasonData.allResults.append(matchI)
				if SeasonData.isLoad == false:
					ins.get_node("goalA").text = str(aGoal)
					ins.get_node("goalB").text = str(bGoal)
	
	if (SeasonData.isSkip == true
	and leagueResults.size() <= SeasonData.MatchDay):
		var resuls = SeasonData.allResults
		leagueResults.append(resuls)
#		print("___")
#		for i in resuls.size():
#			print(i," ",resuls[i])
	
		if test == false:
			GameData.save_data(GameData.season_get_file_path(),data)

func round_robin_gen():
	var data = GameData.season_load_data()
	var teamData = data.teams
	var teams = []
	for i in teamData.size():
		var teamId = teamData[i].id
		teams.append(int(teamId))
		
	var fixtures = []
	if len(teams) % 2:
		teams.append('Day unchecked')
	var n = len(teams)
	var matchs = []
	var return_matchs = []

	for _fixture in range(1, n):
		for i in range(n/2):
# warning-ignore:shadowed_variable
			var teamA = teams[i]
			var teamB = teams[n - 1 - i]
			matchs += [[teamA,teamB]]
			return_matchs += [[teamB, teamA]]
		teams.insert(1, teams.pop_back())

		fixtures.insert(len(fixtures)/2.0, matchs)
		fixtures.append(return_matchs)
		matchs = []
		return_matchs = []

	SeasonData.allMatch = []
	for _fixture in fixtures:
		SeasonData.allMatch.append(_fixture)

func save_league_results():
	var data = GameData.season_load_data()
	var teamData = data.teams
	var leagueResults = data.season.leagueResults
	var stats = leagueResults[SeasonData.MatchDay]
#	print("____")
#	print(stats)
	
	for i in SeasonData.allMatch[SeasonData.MatchDay].size():
		var couple = SeasonData.allMatch[SeasonData.MatchDay][i]
#		print(couple)
		aGoal = stats[i][6][0]
		bGoal = stats[i][6][1]
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

		if test == false:
			GameData.save_data(GameData.season_get_file_path(),data)

func _on_NextRight_pressed():
	SeasonData.MatchDay = int(roundLabel.text)-1
	matchInfo.hide()
	var allRound = SeasonData.allMatch.size()
	if SeasonData.MatchDay < allRound-1:
		SeasonData.MatchDay += 1
		season_create_match()
	else:
		SeasonData.MatchDay = 0
		season_create_match()
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)

func _on_NextLeft_pressed():
	SeasonData.MatchDay = int(roundLabel.text)-1
	matchInfo.hide()
# warning-ignore:unused_variable
	var allRound = SeasonData.allMatch.size()
	if SeasonData.MatchDay > 0:
		SeasonData.MatchDay -= 1
		season_create_match()
	else:
		SeasonData.MatchDay = 21
		season_create_match()
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)

func _on_NextMatch_pressed():
	SeasonData.find_match()
	season_create_match()
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	if leagueResults.size() == SeasonData.MatchDay:
		go_match()
	else:
		Messenger.push_notification(1,"You have finished this season" + "\n" + "Continue to Next Season")
		Messenger.btnYes.connect("pressed",Callable(settings,"btn_next_season"))

func go_match():
	matchInfo.hide()
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	if leagueResults.size() == SeasonData.MatchDay:
		ssMenu.ssMatch.load_setup()
	else:
		season_finishing()

func _on_match_info_btn_close_pressed():
	matchInfo.hide()

func _on_SkipMatch_pressed():
	SeasonData.find_match()
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	if leagueResults.size() == SeasonData.MatchDay:
		Messenger.push_notification(1,"Skip match " + str(SeasonData.MatchDay+1)+":" + "\n" + "Continue!")
		Messenger.btnYes.connect("pressed",Callable(self,"create_match_data").bind(0))
	else:
		season_finishing()

func season_finishing():
	Messenger.push_notification(1,"You have finished this season" + "\n" + "Continue to Next Season")
	Messenger.btnYes.connect("pressed",Callable(settings,"btn_next_season"))

func create_match_data(value):
	thread = Thread.new()
	thread.start(Callable(self,"_thread_create_match_data").bind(value))
	if ssMenu.ssMatch.visible == false:
		Messenger.btnYes.disconnect("pressed",Callable(self,"create_match_data"))

func _thread_create_match_data(value):
#	disable.show()
	SeasonData.isLoad = true
	SeasonData.find_match()
	var data = GameData.season_load_data()
	var leagueResults = data.season.leagueResults
	
	if leagueResults.size() != SeasonData.MatchDay:
		if leagueResults.size() != 22:
			SeasonData.MatchDay += 1
	
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)
	
	if SeasonData.check_teams_count() == true:
		Messenger.push_notification(2,"Loading!")
		if leagueResults.size() == SeasonData.MatchDay:
			SeasonData.isSkip = true
			season_create_match()
			## Save player data
			if test == false:
				for i in 6:
#					if i != SeasonData.matchPlay[2]:
						save_player_match(i)
			
			data = GameData.season_load_data()
			var playerResults = data.season.playerResults
			var resuls = SeasonData.playerResults
			playerResults.append(resuls)
			SeasonData.playerResults = []
			
			if test == false:
				GameData.save_data(GameData.season_get_file_path(),data)
	
	SeasonData.isSkip = false
	SeasonData.find_match()
	SeasonData.noti_season_finshing()
	call_deferred("create_match_load_done",value)

func create_match_load_done(value):
	thread.call_deferred("wait_to_finish")
	if value == 0:
# warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	elif value == 1:
# warning-ignore:return_value_discarded
		SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")
	Messenger.panel.hide()

func _exit_tree():
	# Thoat scence, chuyen scene
	pass
