extends Control

@onready var teamA: = $Main/TeamA
@onready var teamB: = $Main/TeamB
var id:int = 0

func set_up() -> void:
	FormationData.load_team_tactic()
	for i in teamA.get_children():
		i.team = Global.teamID1
		i.load_slot_player_data()
		i.get_node("touch").hide()
		i.get_node("Options").hide()
	for i in teamB.get_children():
		i.team = Global.teamID2
		i.load_slot_player_data()
		i.get_node("touch").hide()
		i.get_node("Options").hide()
	await get_tree().create_timer(0).timeout
	load_pos_broad(1,teamA,-730)
	load_pos_broad(2,teamB,700)

func load_pos_broad(value,group,pos) -> void:
	FormationData.reload_formation(value)
	var currFor
	if value == 1:
		if Global.MatchPlay == 1:
			currFor = FormationData.get_formation()[FormationData.teamTac1]
		else:
			currFor = FormationData.get_formation()[FormationData.teamTac2]
	else:
		if Global.MatchPlay == 1:
			currFor = FormationData.get_formation()[FormationData.teamTac2]
		else:
			currFor = FormationData.get_formation()[FormationData.teamTac1]
	
	for i in group.get_children():
		if i.uid == 0:
			i.position = vector_convert(currFor["GK"])
		elif i.uid == 1:
			i.position = vector_convert(currFor["CB"])
		elif i.uid == 2:
			i.position = vector_convert(currFor["RB"])
		elif i.uid == 3:
			i.position = vector_convert(currFor["LB"])
		elif i.uid == 4:
			i.position = vector_convert(currFor["CM"])
		elif i.uid == 5:
			i.position = vector_convert(currFor["LF"])
		elif i.uid == 6:
			i.position = vector_convert(currFor["RF"])
	
	var fix = 750 - size.y
	for i in group.get_children():
		if i.uid < 7:
			i.position.y -= fix
			i.position.x += pos

func vector_convert(vec):
	var x = remap(vec.z,-3.25,3.25,640,1032)
	var y = remap(vec.x,-13.25,-2.5,620,80)
#	x = clamp(x,640,1032)
	y = clamp(y,45,620)
	return Vector2(x,y)

func _exit_tree():
	queue_free()
