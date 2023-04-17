extends Node

var changeSlot = 0
var teamSelect = 0
var isFor = 0
@onready var disable = get_parent().get_node("Disable")
@onready var opFor = get_parent().get_node("Options/OptionButtonSetFormation")


var formationMatch = {
	0 : FormationData.playerMaPos0,
	1 : FormationData.playerMaPos1,
	2 : FormationData.playerMaPos2,
	3 : FormationData.playerMaPos3,
	4 : FormationData.playerMaPos4
}

var formationBroad = {
	0 : FormationData.playerFoPos0,
	1 : FormationData.playerFoPos1,
	2 : FormationData.playerFoPos2,
	3 : FormationData.playerFoPos3,
	4 : FormationData.playerFoPos4
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var data = GameData.formation_load_data()
	get_parent().get_node("Finance/texturePlayer").texture = load(data.teams[FormationData.teamForm].icon)
	load_stats_team_info()
#	load_pos_broad()
#	var save_data = data.teams[FormationData.teamForm].formation
#	print(save_data.id)

func load_stats_team_info():
	var atk = get_parent().get_node("Stats/ATK")
	var mid = get_parent().get_node("Stats/MID")
	var def = get_parent().get_node("Stats/DEF")
	var v1 = round((float($slot7/ov.text) + float($slot6/ov.text))/2)
	var v2 = round(float($slot5/ov.text))
	var v3 = round((float($slot1/ov.text) + float($slot2/ov.text) + float($slot3/ov.text) + float($slot4/ov.text))/4)
	
	atk.text = str(v1)
	mid.text = str(v2)
	def.text = str(v3)
	
	Calculate.stat_color(atk)
	Calculate.stat_color(mid)
	Calculate.stat_color(def)

func load_pos_broad():
	if FormationData.teamFor == 1:
		FormationData.teamFor1 = isFor
	else:
		FormationData.teamFor2 = isFor

	var currFor = formationBroad[isFor]
	for i in get_children():
		if i.uid == 0:
			i.position = currFor["GK"]
		elif i.uid == 1:
			i.position = currFor["CB"]
		elif i.uid == 2:
			i.position = currFor["RB"]
		elif i.uid == 3:
			i.position = currFor["LB"]
		elif i.uid == 4:
			i.position = currFor["CM"]
		elif i.uid == 5:
			i.position = currFor["LF"]
		elif i.uid == 6:
			i.position = currFor["RF"]

func _on_ButtonTeamSelect_pressed():
	if FormationData.isSub == false:
		save_formation_data()
		if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
			Engine.time_scale = 1
			SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
		else:
			Engine.time_scale = 1
			SceneTransition.change_scene_to_file("res://MGF Scene/ConfigController/ConfigController.tscn")
	else:
		## Check Sub team
		FormationData.teamIn1 = []
		FormationData.teamOut1 = []
		FormationData.teamSub1 = []
		FormationData.teamPos1 = []
		for unit in get_children():
			if unit.uid < 7 and unit.get_node("id").text != "":
				FormationData.teamPos1.append(unit.get_node("pos").text)
			else:
				FormationData.teamPos1.append("NON")
			var id
			if  unit.get_node("id").text != "":
				id = int(unit.get_node("id").text)
				FormationData.teamSub1.append(id)
		print("Pos    ",FormationData.teamPos1)
		print("Base   ",FormationData.teamMain1)
		print("Change ",FormationData.teamSub1)
		
		for i in FormationData.teamMain1.size():
			if FormationData.teamMain1[i] != FormationData.teamSub1[i]:
				print(FormationData.teamSub1[i])
				if i < 7:
					FormationData.teamIn1.append(FormationData.teamSub1[i])
				else:
					FormationData.teamOut1.append(FormationData.teamSub1[i])

		print("Player in is ",FormationData.teamIn1)
		print("Player out is ",FormationData.teamOut1)
		
		var MainGame = get_parent().get_parent().get_parent()
		MainGame.sub_change()

func formation_check_team():
	## Check MainTeam
	FormationData.teamMain1 = []
	for unit in get_children():
		if unit.uid < 7:
			FormationData.teamPos1.append(unit.get_node("pos").text)
		else:
			FormationData.teamPos1.append("NON")
		var id
		if  unit.get_node("id").text != "":
			id = int(unit.get_node("id").text)
			FormationData.teamMain1.append(id)

func _on_OptionButtonSetFormation_item_selected(index):
	isFor = index
	
	load_pos_broad()

func _on_ItemList_pressed():
	save_formation_data()
	for unit in get_children():
		unit.load_player_data_new()

func save_formation_data():
	if disable.visible == false:
		var data = GameData.formation_load_data()
#		var teamData = FileData.db.teams[FormationData.teamForm]
		var save_slot = FileData.db.teams[FormationData.teamForm]
#		var save_slot = {"id":"0","stt":"0"}
		var saveID = data.teams[FormationData.teamForm].Fid
		var saveSTT = data.teams[FormationData.teamForm].Fstt
		var player_data = data.players
		
		## Save formations slot
		saveID.clear()
		saveSTT.clear()
		
		for unit in get_children():
			var i = player_data[int(unit.get_node("id").text)]
			if unit.get_node("id").text != "":
				save_slot.Fid[0] = int(i.PlayerID)
				save_slot.Fstt[0] = int(unit.uid)
				saveID.append(save_slot.Fid[0])
				saveSTT.append(save_slot.Fstt[0])
				i.Team[0] = FormationData.teamForm
				if unit.uid > 6:
					i.Team[1] = "NON"
				elif unit.uid<=6:
					i.Team[1] = unit.get_node("pos").text
		
		## Reset sub
		var count = 0
		var isPlay = 6
		var maxSlot = 10
		var slot = maxSlot-3
		for a in saveSTT.size():
			if saveSTT[a]>isPlay:
				count += 1
				for i in range(isPlay-1,slot):
					saveSTT[a] = i+count
		
		GameData.formation_save_data(data)
		
		##Debug
#		print("__Save__")
#		for i in saveSTT.size():
#			print(saveSTT[i])
#		print("__Finish__")

