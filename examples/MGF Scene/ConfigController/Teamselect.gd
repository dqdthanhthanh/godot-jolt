extends Button

var teamIcon = 0

func _ready():
	var data = GameData.get_data(GameData.data_path)
	icon = load(data.teams[teamIcon].icon)
