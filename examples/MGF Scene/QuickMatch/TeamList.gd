extends Panel


@onready var group: = $ScrollContainer/CenterContainer/GridContainer

func create_team_list() -> void:
	var teamIns = load("res://MGF Scene/QuickMatch/Teamselect.tscn")
	
	var data:FileData = FileData.new()
	var teamData = data.teams
	
	Calculate.remove_children(group)
	
	for i in teamData.size():
		var ins = teamIns.instantiate()
		ins.id = i
		group.add_child(ins)
		ins.load_team_select_icon(data)
