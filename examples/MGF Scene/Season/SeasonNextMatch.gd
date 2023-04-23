extends Control


var teamSelect:int = SeasonData.get_team_select()
var insmMatch: = load("res://MGF Scene/Season/Match.tscn")

@onready var roundLabel: = $TabBtns/VBoxContainer/LabelBase
@onready var matchRound: = $TabBtns/VBoxContainer/VBoxContainer
@onready var settings: = get_parent().get_node("Settings")
@onready var ssMenu: = get_parent().get_parent()
@onready var matchInfo: = ssMenu.get_node("MatchInfo")

func load_setup() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	round_robin_gen()
	SeasonData.find_match()
	season_create_match()

func round_robin_gen() -> void:
	var data = GameData.season_load_data()
	SeasonData.allMatch = data.leagueMatchs
	if data.leagueMatchs.size() == 0:
		var teamData = data.teams
		var teams = []
		for i in teamData.size():
			var teamId = teamData[i].id
			teams.append(int(teamId))
		
		var fixtures = []
		if len(teams) % 2:
			teams.append('Day off')
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
		data.leagueMatchs = SeasonData.allMatch
		GameData.season_save_data(data)

func _on_BtnRoundLeft_pressed() -> void:
	SeasonData.MatchDay = int(roundLabel.text)-1
	matchInfo.hide()
	if SeasonData.MatchDay > 0:
		SeasonData.MatchDay -= 1
		season_create_match()
	else:
		SeasonData.MatchDay = 21
		season_create_match()

func _on_BtnRoundRight_pressed() -> void:
	SeasonData.MatchDay = int(roundLabel.text)-1
	matchInfo.hide()
	if SeasonData.MatchDay < 21:
		SeasonData.MatchDay += 1
		season_create_match()
	else:
		SeasonData.MatchDay = 0
		season_create_match()

func _on_NextMatch_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	SeasonData.find_match()
	season_create_match()
	
	go_match()

func go_match() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	matchInfo.hide()
	if SeasonData.check_season_finishing() == false:
		ssMenu.ssMatch.load_setup()
	else:
		season_finishing()

func season_finishing() -> void:
	SeasonData.season_finshing_noti()
	Notification.push_noti(1,"You have finished this season" + "\n" + "Continue to Next Season")
	if !Notification.btnYes.is_connected("pressed", Callable(settings, "btn_next_season")):
		Notification.btnYes.connect("pressed", Callable(settings, "btn_next_season"))

func season_create_match() -> void:
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	var teamData = data.teams
	
	SeasonData.allResults = []
	
	if matchRound.get_child_count() > 0:
		for unit in matchRound.get_children():
			unit.queue_free()
# warning-ignore:unused_variable
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
		
		## Load match
		if leagueResults.size() > SeasonData.MatchDay:
#			if i != SeasonData.matchPlay[2]:
			var tdata = leagueResults[SeasonData.MatchDay][i]
			ins.get_node("Main/goalA").text = str(tdata.match[1][0])
			ins.get_node("Main/goalB").text = str(tdata.match[1][1])
		ins.id = i
		ins.get_node("Main/id").text = str(i+1)
		ins.get_node("Main/teamA").texture = Team.load_team_icon(teamData[couple[0]].icon)
		ins.get_node("Main/teamB").texture = Team.load_team_icon(teamData[couple[1]].icon)
		matchRound.add_child(ins)
		
	roundLabel.text = "Round " + str(SeasonData.MatchDay+1)

func _exit_tree():
	queue_free()
