extends Node

var teamA = 0
var teamB = 1

var TabManager = 0
var MatchDay = 0
var MatchID = 0
var MatchPlay = 0
var isSkip = false
var isLoad = false

var playersData
var teamsData
var ss = 0

var allMatch = []
var allResults = []
var leagueResults = []
var playerResults = []
var matchPlay = []

func find_match():
	var data = GameData.season_load_data()
	leagueResults = data.season.leagueResults
	
	if leagueResults.size() > 0:
		if leagueResults.size() != 22:
			MatchDay = leagueResults.size()
		else:
			MatchDay = leagueResults.size()-1
	else:
		MatchDay = 0

func noti_season_finshing():
	var data = GameData.season_load_data()
	if data.season.done == 0:
		var ssName = str(data.season.name)
		var teamName = SeasonData.get_team_select_name()
		data.season.done = 1
		GameData.season_save_data(data)
		NotiData.create_noti("Season "+ssName+" Finished",teamName+": Finished Season "+ssName)

func get_team_select():
	var data = GameData.season_load_data()
	var seasonData = data.season
	var team = int(seasonData.teamA)
	return team

func get_team_select_name():
	var data = GameData.season_load_data()
	var teamName = data.teams[SeasonData.teamA].fullName
	return teamName
	
func check_season_match_finishing():
	var data = GameData.season_load_data()
	leagueResults = data.season.leagueResults
	if leagueResults.size() != SeasonData.MatchDay:
		return false
	else:
		return true

func check_season_finishing():
	var data = GameData.season_load_data()
	var check = data.season.done
	if check == 0:
		return true
	else:
		return false

func check_teams_count():
	var data = GameData.season_load_data()
	
	var checkTeamCount = 0
	for i in data.teams.size():
		var id = data.teams[i].Fid
		if id.size()<7:
			checkTeamCount += 1
			Messenger.push_notification(0,data.teams[i].name + " team doesn't have enough 7 people in the squad")
	
	if checkTeamCount > 0:
		return false
	else:
		return true

func check_team_select(id):
	var data = GameData.season_load_data()
	if data.season.teamA == id:
		FormationData.isDisable = false
	else:
		FormationData.isDisable = true
