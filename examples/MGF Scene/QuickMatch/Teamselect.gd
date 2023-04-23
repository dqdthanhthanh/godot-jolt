extends Button

var id:int = 0

func _exit_tree():
	queue_free()

func load_team_select_icon(data) -> void:
	var team = data.teams[id]
	icon = Team.load_team_icon(team.icon)
	if team.active == false:
		$active.show()
	if team.active == false and SeasonData.check_season_mode() == true:
		disabled = true
	tooltip_text = team.fullName + " FC"
