extends Node

var teamA:int = 0
var teamB:int = 1

var TabManager:int = 0
var MatchDay:int = 0
var MatchID:int = 0
var MatchPlay:int = 0
var isSkip:bool = false
var isLoad:bool = false

var ss:int = 0

var allMatch:Array = []
var allResults:Array = []
var leagueResults:Array = []
var playerResults:Array = []
var Match:Array = [] ## MatchID, teamA, teamB

static func check_season_mode() -> bool:
	var value:bool
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		value = true
	else:
		value = false
	return value

func find_match(type:int = 0) -> void:
	var data = GameData.season_load_data()
	leagueResults = data.leagueResults
	
	if leagueResults.size() > 0:
		if type == 0:
			if leagueResults.size() != 22:
				MatchDay = leagueResults.size()
			else:
				MatchDay = leagueResults.size()-1
		else:
			if leagueResults.size() != 0:
				MatchDay = leagueResults.size()-1
			elif leagueResults.size() == 0:
				MatchDay = 0
	else:
		MatchDay = 0

static func season_finshing_noti() -> void:
	var data = GameData.season_load_data()
	var team = data.teams[get_team_select()]
	
	var leagueResults = data.leagueResults
	if leagueResults.size() >= 22:
		if data.season.done == false:
			var ssName = str(data.season.name)
			var teamName = SeasonData.get_team_select_name()
			data.season.done = true
			GameData.season_save_data(data)
			var labelText = "Season " + ssName + " Finished"
			var infoText = [teamName+": Finished Season "+ssName + " (" + "Top " + str(team.index) + ")"]
			Notification.create_achi(2, labelText, infoText)
			Notification.create_noti(labelText, infoText)

static func get_team_select() -> int:
	var data = GameData.season_load_data()
	var seasonData = data.season
	var team = int(seasonData.teamA)
	return team

static func get_team_index_select() -> int:
	var data = GameData.season_load_data()
	var seasonData = data.season
	var team = data.teams[seasonData.teamA].index
	return team

static func get_team_select_name() -> String:
	var data = GameData.season_load_data()
	var teamName:String = str(data.teams[SeasonData.teamA].fullName)
	return teamName

func check_season_match_finishing() -> bool:
	var value:bool
	var data = GameData.season_load_data()
	leagueResults = data.leagueResults
	if leagueResults.size() != SeasonData.MatchDay:
		value = false
	else:
		value = true
	return value

static func check_season_finishing() -> bool:
	var check:bool
	var data = GameData.season_load_data()
	var leagueResults = data.leagueResults
	if leagueResults.size() >= 22:
		check = true
	else:
		check = false
	return check

static func check_teams_count() -> bool:
	var value:bool
	var data = GameData.season_load_data()
	
	var checkTeamCount = 0
	for i in data.teams.size():
		var id = data.teams[i].Fid
		if id.size()<7:
			checkTeamCount += 1
			Notification.push_noti(0,data.teams[i].name + " team doesn't have enough 7 people in the squad")
	
	if checkTeamCount > 0:
		value = false
	else:
		value = true
	return value

static func check_team_select(id) -> void:
	var data = GameData.season_load_data()
	if data.season.teamA == id:
		FormationData.isDisable = false
	else:
		FormationData.isDisable = true
