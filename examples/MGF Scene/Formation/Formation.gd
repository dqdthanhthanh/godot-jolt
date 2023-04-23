extends Control

@onready var disable: = $Disable
@onready var finance: = $Options/Finance
@onready var playerCardPanel: = $PlayerCard
@onready var playersPanel: = $PanelPlayerData
@onready var playerCard: = $PlayerCard/TextureRect
var id:int = 0

@onready var group: = $GroupSlots
var changeSlot:int = 0
var teamSelect:int = 0
@onready var opFor: = $Options/OptionSetFormation
@onready var OptionV: = $Options/OptionV/BtnV
@onready var OptionH: = $Options/OptionH/BtnH

@onready var btnHome: = $BtnHome
@onready var btnClose: = $BtnClose

var MainGame

func can_preview_player():
	if playerCardPanel.visible == true or playersPanel.visible == true:
		return false
	else:
		return true

func _ready() -> void:
	var data = GameData.formation_load_data()
	var teamData = data.teams[FormationData.teamForm].Fid[0]
	id = teamData
	
	##Reset player data
	for child in group.get_children():
		child.team = FormationData.teamForm
		child.load_slot_player_data()
		var _id = child.get_node("id").text
		var playerData = data.players[int(_id)]
		playerData.Foul = [0,0,0]
		playerData.isSub = [true,"NON"]
	GameData.formation_save_data(data)
	update_player_data_MainGame()
	
	Account.info.hide()
	if SeasonData.check_season_mode() == true:
		disabled(FormationData.isDisable)
	
	load_stats_team_info()
	var tactic = data.teams[FormationData.teamForm].tactic
	FormationData.teamTac = tactic[0]
	FormationData.teamV = tactic[1]
	FormationData.teamH = tactic[2]
	
	$Options/OptionSetFormation.text = FormationData.Formation[FormationData.teamTac].text
	load_pos_broad()
	
	GameData.return_radarStats_player($PlayerBaseInfo/RadarChartStats,teamData)
	group.get_node("slot1").player_data_preview(teamData)
	
	$PanelPlayerData.hide()
	
	var teamIcon = Team.load_team_icon(data.teams[FormationData.teamForm].icon)
	$Stats/BtnTeamIcon.icon = teamIcon

func disabled(value) -> void:
	disable.visible = value

func load_stats_team_info() -> void:
	var atk = get_node("Stats/ATK")
	var mid = get_node("Stats/MID")
	var def = get_node("Stats/DEF")
	var v1 = round((float(group.get_node("slot7/ov").text) + float(group.get_node("slot6/ov").text))/2)
	var v2 = round(float(group.get_node("slot5/ov").text))
	var v3 = round((float(group.get_node("slot1/ov").text) + float(group.get_node("slot2/ov").text) + float(group.get_node("slot3/ov").text) + float(group.get_node("slot4/ov").text))/4)
	
	atk.text = str(v1)
	mid.text = str(v2)
	def.text = str(v3)
	
	Calculate.stat_color(atk)
	Calculate.stat_color(mid)
	Calculate.stat_color(def)

func update_player_data_MainGame() -> void:
	for child in group.get_children():
		child.update_player_data_MainGame()
	await get_tree().create_timer(0).timeout
	var MainGame = get_parent()
	if MainGame.name == "UI":
		var team
		if Global.MatchPlay == 1:
			team = MainGame.get_parent().teamA
		else:
			team = MainGame.get_parent().teamB
		for i in team.size():
#			group.get_child(i).get_node("sta").show()
			group.get_child(i).get_node("sta").value = team[i].statEnergy

func player_set_skin() -> void:
	$PlayerBaseInfo/Panel/Texture2D.texture = playerCard.texture
	group.get_child(id).get_node("image").texture = playerCard.texture

func _on_PlayerInfo_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	playerCardPanel.create_art(id)

func _on_BtnHome_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	Account.info.show()
	FormationData.CanFormation = false
	save_formation_data()
	if SeasonData.check_season_mode() == true:
		SceneTransition.change_scene_to_file("res://MGF Scene/Season/Season.tscn")
	else:
		SceneTransition.change_scene_to_file("res://MGF Scene/QuickMatch/QuickMatch.tscn")

func save_formation_data() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	if disable.visible == false:
		var file_data:FileData = FileData.new()
		var data = GameData.formation_load_data()
#		var teamData = file_data.db.teams[FormationData.teamForm]
		var save_slot = file_data.db.teams[FormationData.teamForm]
#		var save_slot = {"id":"0","stt":"0"}
		var saveID = data.teams[FormationData.teamForm].Fid
		var saveSTT = data.teams[FormationData.teamForm].Fstt
		var player_data = data.players
		
		var tactic = data.teams[FormationData.teamForm].tactic
		tactic[0] = FormationData.teamTac
		tactic[1] = FormationData.teamV
		tactic[2] = FormationData.teamH
		
		## Save formations slot
		saveID.clear()
		saveSTT.clear()
		
		for unit in group.get_children():
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

func formation_check_team() -> void:
	## Check MainTeam
	FormationData.teamMain1 = []
	for unit in group.get_children():
		if unit.uid < 7:
			FormationData.teamPos1.append(unit.get_node("pos").text)
		else:
			FormationData.teamPos1.append("NON")
		var id
		if  unit.get_node("id").text != "":
			id = int(unit.get_node("id").text)
			FormationData.teamMain1.append(id)

func _on_OptionSetFormation_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	$InsOptionsBtn.creat_btn($Options/OptionSetFormation,"Formation",FormationData.teamTac,FormationData.Formation)
	if !$InsOptionsBtn.is_connected("item_selected", Callable(self, "_on_option_set_formation")):
		$InsOptionsBtn.connect("item_selected", Callable(self, "_on_option_set_formation"))

func _on_option_set_formation(index) -> void:
	FormationData.teamTac = index
	load_pos_broad()

func _on_BtnV_drag_ended(value_changed) -> void:
	FormationData.teamV = remap(OptionV.value,0,100,-0.2,0.2)
	load_pos_broad()

func _on_BtnH_drag_ended(value_changed) -> void:
	FormationData.teamH = remap(OptionH.value,0,100,-0.15,0.2)
	load_pos_broad()

func load_pos_broad() -> void:
	OptionV.value = remap(FormationData.teamV,-0.2,0.2,0,100)
	OptionH.value = remap(FormationData.teamH,-0.15,0.2,0,100)
	FormationData.reload_formation()
	var currFor = FormationData.get_formation()[FormationData.teamTac]
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

func vector_convert(vec):
	var x = remap(vec.z,-3.25,3.25,640,1032)
	var y = remap(vec.x,-13.25,-2.5,620,80)
#	x = clamp(x,640,1032)
	y = clamp(y,45,620)
	return Vector2(x,y)


func _on_BtnClose_pressed() -> void:
	## Check Sub team
	FormationData.teamIn1 = []
	FormationData.teamOut1 = []
	FormationData.teamSub1 = []
	FormationData.teamPos1 = []
	for unit in group.get_children():
		if unit.uid < 7 and unit.get_node("id").text != "":
			FormationData.teamPos1.append(unit.get_node("pos").text)
		else:
			FormationData.teamPos1.append("NON")
		var id
		if  unit.get_node("id").text != "":
			id = int(unit.get_node("id").text)
			FormationData.teamSub1.append(id)
	
	for i in FormationData.teamMain1.size():
		if FormationData.teamMain1[i] != FormationData.teamSub1[i]:
			if i < 7:
				FormationData.teamIn1.append(FormationData.teamSub1[i])
			else:
				FormationData.teamOut1.append(FormationData.teamSub1[i])
	
	if FormationData.teamFor == 1:
		FormationData.teamTac1 = FormationData.teamTac
		FormationData.teamV1 = FormationData.teamV
		FormationData.teamH1 = FormationData.teamH
		if (FormationData.teamTac1 != FormationData.tacData[0] or
		FormationData.teamV1 != FormationData.tacData[1] or
		FormationData.teamH1 != FormationData.tacData[2]):
			FormationData.isTac = true
#			prints("Run1",FormationData.isTac,FormationData.tacData)
	else:
		FormationData.teamTac2 = FormationData.teamTac
		FormationData.teamV2 = FormationData.teamV
		FormationData.teamH2 = FormationData.teamH
		if (FormationData.teamTac2 != FormationData.tacData[0] or
		FormationData.teamV2 != FormationData.tacData[1] or
		FormationData.teamH2 != FormationData.tacData[2]):
			FormationData.isTac = true
#			prints("Run2",FormationData.isTac,FormationData.tacData)
		
#		var MainGame = get_parent().get_parent()
#		MainGame.sub_change()

func _exit_tree():
	queue_free()
