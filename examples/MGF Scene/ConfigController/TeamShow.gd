extends Button

@export var teamSelect = "teamID1" # (String, "teamID1", "teamID2")

func _ready():
	var data = GameData.get_data(GameData.data_path)
	if teamSelect == "teamID1":
		icon = load(data.teams[int(Global.teamID1)].icon)
	else:
		icon = load(data.teams[int(Global.teamID2)].icon)
