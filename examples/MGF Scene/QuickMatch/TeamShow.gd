extends Button

@export var teamSelect = "teamID1" # (String, "teamID1", "teamID2")
@onready var star: = $Star

func _ready() -> void:
	var data = GameData.get_data(GameData.data_path)
	star.value = data.teams[int(Global.teamID1)].overall[0]*10
	if teamSelect == "teamID1":
		icon = Team.load_team_icon_high(data.teams[int(Global.teamID1)].icon)
	else:
		icon = Team.load_team_icon_high(data.teams[int(Global.teamID2)].icon)

func update_data(data) -> void:
	icon = Team.load_team_icon_high(data.icon)
	star.value = data.overall[0]*10

func _exit_tree():
	queue_free()
