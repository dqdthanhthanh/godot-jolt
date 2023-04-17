extends Button


var default_data = {}
var data = {}
var default_path = "user://playerDBDefault.json"
var data_path = "user://playerDB.json"


func _ready():
	load_finance_data()

func load_finance_data() -> void:
	var game_Data = GameData.get_data(GameData.data_path)
	var teamData = game_Data.teams[FormationData.teamForm].Fid
	var player_data
# warning-ignore:unused_variable
	var ss = 0
	
	var wageCal = 0
	var transferCal = 0
	
	for i in range(teamData.size()):
		player_data = game_Data.players[int(teamData[i])]
		wageCal += float(player_data.Price[2])
		transferCal += float(player_data.Price[1])
	
	$TransferAll.text = str(transferCal)
	$WageAll.text = str(wageCal*54)
