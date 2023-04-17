@tool
extends Control

"""
# EN_US: Exported variables
"""

# EN_US: Unique ID for the slot, for the dragged item, or for the slot to accept only other slots of that ID
@export var uid = 0 # (int, 0, 100)
@export var pos = "SUB" # (String, "GK", "CB", "LB", "RB", "CM","LF", "RF", "SUB")
var maxUid = 10
var setUid = 6

# EN_US: Accepts items in the same group
@export var group = ""

# EN_US: Item quantity, use with the "increment" variable
@export var qtd: int = 0 : set = _setQtd

# EN_US: Shows or hides the quantity counter
@export var showQtd: bool = true : set = _setShowQtd

# EN_US: Allows incremental control of the quantity
@export var increment: bool = true

# EN_US: Allows an item that has no image, overwrite the image of the slot where it is going
@export var replaceNull: bool = true

# EN_US: Allows click to clear the slot
@export var canClear: bool = true

# EN_US: Allows click to clear the slot
@export var canReceive: bool = true

# EN_US: Preview transparency
@export var opacityPreview = 0.8 # (float, 0.0, 1.0)

# EN_US: Background color for slot
@export var color:Color = Color(0.5,0.5,0.5,1) ##: set = _setColor

# EN_US: Slot size
@export var _size:Vector2 = Vector2(150, 150) : set = _setSize

# EN_US: Slot image
#export var image: Texture2D: Texture2D = null : set = _setImage
#
## EN_US: Drag preview image
#export var imagePreview: Texture2D: Texture2D = null : set = _setImagePreview

# EN_US: Drag preview image
@export var imageBackGround:Texture2D = null : set = _setImageBackGround

# PT_BR: Variaveis locais
# EN_US: Local variables
var defaults: Dictionary = {}
var _mouseRightButton: bool = false
var isDragging: bool = false

@onready var dName = $name
@onready var dImage = $image
@onready var dQtd = $id
@onready var dColor = $color
@onready var dPos = $pos

var newPosMa = ""
var rmPlayerID = 0

# EN_US: setGet Functions
func _setShowQtd(newValue) -> void:
	showQtd = newValue
	if weakref($id).get_ref():
		$id.set("visible", showQtd)
func _setQtd(newValue) -> void:
	qtd = newValue
	if weakref($id).get_ref():
		$id.text = str(qtd)
#func _setColor(newValue) -> void:
#	color = newValue
#	if weakref($color).get_ref():
#		$color.color = color
#func _setImage(newValue) -> void:
#	image = newValue
#	if weakref($image).get_ref():
#		$image.texture = image
#func _setImagePreview(newValue) -> void:
#	imagePreview = newValue
#	if weakref($preview).get_ref():
#		$preview.texture = imagePreview
func _setImageBackGround(newValue) -> void:
	imageBackGround = newValue
	if weakref($background).get_ref():
		$background.texture = imageBackGround

func _setSize(newValue) -> void:
	size = newValue
	custom_minimum_size = size
	size = size
	$color.custom_minimum_size = size
	$color.size = size
	$image.custom_minimum_size = size
	$image.size = size
	$preview.custom_minimum_size = size
	$preview.size = size
	$background.custom_minimum_size = size
	$background.size = size
	$id.size.x = size.x - 10
	$touch.scale = (newValue * 64 / 2.0) / 1000.0

func load_player_data_new() -> void:
	load_player_card()
	var data = GameData.formation_load_data()
	$background.texture = load(data.teams[FormationData.teamForm].icon)
	var teamData = data.teams[FormationData.teamForm]
	var id_Data
	var stt_Data
	var player_data = data.players
	for i in teamData.Fid.size():
		id_Data = int(teamData.Fid[i])
		stt_Data = int(teamData.Fstt[i])
		player_data = data.players[id_Data]
		if uid == stt_Data:
			$name.text = player_data.Name
			load_player_card(player_data.PlayerID,player_data.Team[0],player_data.Name,
			player_data.texturePath,player_data.Team[2],
			player_data.Overall[1],player_data.Overall[2],player_data.Overall[3],player_data.Overall[0],false)
	player_data = data.players[int($id.text)]
	if uid >= 7:
		Calculate.stat_color($ov)
		Calculate.position_color($pos)
		$Options.show()
	elif uid < 7:
		match uid:
			0:
				$pos.text = "GK"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[4])
					$d.text = str_round(player_data.Overall[4])
			1:
				$pos.text = "CB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			2:
				$pos.text = "RB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			3:
				$pos.text = "LB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			4:
				$pos.text = "CM"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[2])
			5:
				$pos.text = "LF"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[1])
			6:
				$pos.text = "RF"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[1])
		Calculate.stat_color($ov)
		Calculate.position_color($pos)
		$Options.hide()

func load_player_data() -> void:
	$background.texture = load(FileData.db.teamDetail[Global.teamName[FormationData.teamForm]].teamIcon)
	var data = GameData.formation_load_data()
	var player_id = data.teamFormation.get(FormationData.teamForm)
	var player_data = data.players
#	player_id = game_Data.teamFormation.get("ST")
	if uid < player_id.size():
		## Quick load team data
		var teams = int(player_id[uid].id)
		player_data = data.players[teams]
		load_player_card(player_data.PlayerID,player_data.Team[0],player_data.Name,
		player_data.texturePath,player_data.Team[2],
		player_data.Overall[1],player_data.Overall[2],player_data.Overall[3],player_data.Overall[0],false)
	else:
		load_player_card()
	player_data = data.players[int($id.text)]
	if uid >= 7:
		Calculate.stat_color($ov)
		Calculate.position_color($pos)
		$Options.show()
	elif uid < 7:
		match uid:
			0:
				$pos.text = "GK"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[4])
					$d.text = str_round(player_data.Overall[4])
			1:
				$pos.text = "CB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			2:
				$pos.text = "RB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			3:
				$pos.text = "LB"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[3])
			4:
				$pos.text = "CM"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[2])
			5:
				$pos.text = "LF"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[1])
			6:
				$pos.text = "RF"
				if $id.text != "":
					$ov.text = str_round(player_data.Overall[1])
		Calculate.stat_color($ov)
		Calculate.position_color($pos)
		$Options.hide()

func str_round(value):
	return str(round(float(value)))

func load_player_card(id="",t="",na="",tt="",p="",f="",m="",d="",ov="",vi=true):
	$id.text = str(id)
	$check.text = str(t)
	$name.text = na
	if tt == "":
		$image.texture = null
	else:
		$image.texture = load(tt)
	$pos.text = p
	if str(id) != "":
		$f.text = str_round(f)
		$m.text = str_round(m)
		$d.text = str_round(d)
		$ov.text = str_round(ov)
	else:
		$f.text = ""
		$m.text = ""
		$d.text = ""
		$ov.text = ""
	Calculate.stat_color($f)
	Calculate.stat_color($m)
	Calculate.stat_color($d)
	$Options.visible = vi

func reload_player_data()-> void:
	var data = GameData.formation_load_data()
#	var teamData = game_Data.teams
	var teamIcon = data.teams[FormationData.teamForm].icon
	var playerData = data.players[int($id.text)]
	
	if $id.text != "":
		$background.texture = load(teamIcon)
		$image.texture = load(playerData.texturePath)
		$name.text = playerData.Name
		$id.text = str(playerData.PlayerID)
		$check.text = str(playerData.Team[0])
		if uid <7:
			if $pos.text == "GK":
				$ov.text = str_round(playerData.Overall[4])
			elif $pos.text == "CB" or $pos.text == "LB" or $pos.text == "RB":
				$ov.text = str_round(playerData.Overall[3])
			elif $pos.text == "CM":
				$ov.text = str_round(playerData.Overall[2])
			elif $pos.text == "LF" or $pos.text == "RF":
				$ov.text = str_round(playerData.Overall[1])
		else:
			$ov.text = str_round(playerData.Overall[0])
			$pos.text = playerData.Team[2]
		$f.text = str_round(playerData.Overall[1])
		$m.text = str_round(playerData.Overall[2])
		if playerData.Team[2] != "GK":
			$d.text = str_round(playerData.Overall[3])
		else:
			$d.text = str_round(playerData.Overall[4])
		Calculate.stat_color($ov)
		Calculate.stat_color($f)
		Calculate.stat_color($m)
		Calculate.stat_color($d)
		Calculate.position_color($pos)
	else:
		$background.texture = load(teamIcon)
		$image.texture = null
		$name.text = ""
		$id.text = ""
		$check.text = ""
		$ov.text = ""
		$f.text = ""
		$m.text = ""
		$d.text = ""
		if uid >6:
			$pos.text = ""

func edit_player_data(edit,id)-> void:
	var data = GameData.formation_load_data()
#	var teamData = game_Data.teams
	var teamIcon = data.teams[FormationData.teamForm].icon
	var player_Data = data.players
	var teamDataID = data.teams[FormationData.teamForm].Fid
	var teamDataSTT = data.teams[FormationData.teamForm].Fstt
	
	match edit:
		0:##Remove
			print("RemovePlayer")
			if teamDataID.size() > 7:
				player_Data[int($id.text)].Team[0] = "NON"
				for i in teamDataID.size()-1:
					if int(teamDataID[i]) == int($id.text):
						teamDataID.erase(teamDataID[i])
						teamDataSTT.erase(int(uid))
						print("RemoveDone")
				$id.text = ""
				$name.text = ""
				$pos.text = ""
				$check.text = ""
				$ov.text = ""
				$f.text = ""
				$m.text = ""
				$d.text = ""
				$image.texture = null
			else:
				Messenger.push_notification(0,"The team must have 7 people in the squad")
		1:##AddNew
			print("AddNewPlayer")
			var addPlayer = player_Data[int(id)].duplicate()
			addPlayer.PlayerID = str(player_Data.size())
			addPlayer.Team[0] = FormationData.teamForm
			$background.texture = load(teamIcon)
			Calculate.position_color($pos)
			
			for i in FileData.players[0].Health:
				addPlayer.Health[0] = 0
			for i in FileData.players[0].Career:
				addPlayer.Career[0] = 0
			for i in FileData.players[0].Season:
				addPlayer.Season[0] = 0
			for i in FileData.players[0].Match:
				addPlayer.Match[0] = 0
			
			player_Data.append(addPlayer)
			$id.text = str(addPlayer.PlayerID)
			$check.text = str(FormationData.teamForm)
			teamDataID.append(int(addPlayer.PlayerID))
			teamDataSTT.append(int(uid))
		2:##Add
			print("AddPlayer")
			var addPlayer = player_Data[int(id)]
			$id.text = str(addPlayer.PlayerID)
			$check.text = str(FormationData.teamForm)
			$background.texture = load(teamIcon)
			Calculate.position_color($pos)
			addPlayer.Team[0] = str(FormationData.teamForm)
			teamDataID.append(int(addPlayer.PlayerID))
			teamDataSTT.append(int(uid))
	
	print("ID",teamDataID)
	print("STT",teamDataSTT)
	GameData.formation_save_data(data)
	get_parent().get_parent().get_node("Finance").load_finance_data()

func player_data_preview(value):
	if $image.texture != null:
		var data = GameData.formation_load_data()
		var teamData = data.teams[FormationData.teamForm]
		var playerData = data.players[int(value)]
#		print(playerData.Name)
		var list = get_parent().get_parent().get_node("ItemList")
		list.get_node("namePlayer").text = playerData.Name
		list.get_node("nameTeam").text = teamData.name
#		list.get_node("playerPosition").text = playerData.Team[2]
#		list.get_node("playerPositionMatch").text = playerData.Team[1]
#		list.get_node("playerPosition").text = playerData.PlayerID
		list.get_node("texturePlayer").texture = load(playerData.texturePath)
		
		list.get_node("playerStatGames").text = str(playerData.Season[0])
		list.get_node("playerStatGoals").text = str(playerData.Season[2])
		list.get_node("playerStatAssits").text = str(playerData.Season[3])
		
		list.get_node("playerPasses").text = str(playerData.Season[4])
		list.get_node("playerMoves").text = str(playerData.Season[5])
		list.get_node("playerOwnGoals").text = str(playerData.Season[8])
		if playerData.Season[0]>0:
			list.get_node("playerPosition").text = str("%.2f" % float(playerData.Season[1]/playerData.Season[0]))
		else:
			list.get_node("playerPosition").text = "5"
		if playerData.Season[10]>0:
			list.get_node("playerMistakes").text = str(round(playerData.Season[10]/playerData.Season[0]))
		else:
			list.get_node("playerMistakes").text = "0"
		list.get_node("playerFinishing").text = str_round(playerData.Stat[0])
		list.get_node("playerShotPower").text = str_round(playerData.Stat[1])
		list.get_node("playerAccurate").text = str_round(playerData.Stat[2])
		list.get_node("playerControll").text = str_round(playerData.Stat[3])
		list.get_node("playerSpeed").text = str_round(playerData.Stat[5])
		list.get_node("playerStamina").text = str_round(playerData.Stat[4])
		list.get_node("playerPower").text = str_round(playerData.Stat[6])
		list.get_node("playerBody").text = str_round(playerData.Stat[7])
		list.get_node("playerInterception").text = str_round(playerData.Stat[8])
		list.get_node("playerDefend").text = str_round(playerData.Stat[9])
		list.get_node("playerPenSave").text = str_round(playerData.Stat[10])
		list.get_node("playerReflexes").text = str_round(playerData.Stat[11])
		list.get_node("playerEnergy").text = str_round(playerData.Health[1])
		list.get_node("playerInjuryRate").text = str(playerData.Health[2])
		
		list.get_node("Popular").text = "$"
		for i in int(playerData.Price[0]):
			list.get_node("Popular").text += "$"
		list.get_node("Overall").text = str_round(playerData.Overall[0])
		
		list.get_node("Transfer").text = str(playerData.Price[1])
		list.get_node("Wage").text = str(playerData.Price[2])
		
#		list.get_node("playerOverall").text = str(Calculate.return_Overall(
##			playerData.Team[2],
##			playerData.Team[1]
#			$pos.text,
#			$pos.text,
#			playerData.Stat[0],
#			playerData.Stat[1],
#			playerData.Stat[8],
#			playerData.Stat[2],
#			playerData.Stat[5],
#			playerData.Stat[3],
#			playerData.Stat[4],
#			playerData.Stat[6],
#			playerData.Stat[7],
#			playerData.Stat[11],
#			playerData.Stat[9],
#			playerData.Stat[10]))
#
		list.get_node("playerOverall").text = str_round(playerData.Overall[0])
		list.get_node("playerPotential").text = str_round(Calculate.return_Potential(
			playerData.Age,
			list.get_node("playerOverall").text))
		
		Calculate.position_color(list.get_node("playerPosition"))
		Calculate.stat_color(list.get_node("playerFinishing"))
		Calculate.stat_color(list.get_node("playerShotPower"))
		Calculate.stat_color(list.get_node("playerInterception"))
		Calculate.stat_color(list.get_node("playerAccurate"))
		Calculate.stat_color(list.get_node("playerSpeed"))
		Calculate.stat_color(list.get_node("playerControll"))
		Calculate.stat_color(list.get_node("playerStamina"))
		Calculate.stat_color(list.get_node("playerPower"))
		Calculate.stat_color(list.get_node("playerBody"))
		Calculate.stat_color(list.get_node("playerReflexes"))
		Calculate.stat_color(list.get_node("playerDefend"))
		Calculate.stat_color(list.get_node("playerPenSave"))
		Calculate.stat_color(list.get_node("playerEnergy"))
		Calculate.stat_color(list.get_node("playerInjuryRate"))
		
		Calculate.stat_color(list.get_node("Overall"))
		
		Calculate.stat_color(list.get_node("playerOverall"))
		Calculate.stat_color(list.get_node("playerPotential"))

func _ready():
	if Global.isCheck == true:
		$id.show()
		$check.show()
	load_player_data_new()
	
	defaults = {
		"color": color
	}
	
	# EN_US: It is necessary to put the mouse filter as ignore, otherwise the drag will not work
	# Set all children as MOUSE_FILTER_IGNORE
	for n in get_children():
		if "mouse_filter" in n:
			n.mouse_filter = MOUSE_FILTER_IGNORE

# EN_US: If the user clicks the right mouse button, or two fingers checked the screen
# EN_US: Enables / Disables unit transfer of slots that increment
func _input(event) -> void:
	# EN_US: If you right-click
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.is_pressed():
			if increment:
				_mouseRightButton = !_mouseRightButton
				$unit.set("visible", _mouseRightButton)

	# EN_US: If you touch the screen with both fingers
	if event is InputEventScreenTouch:
		if event.index == 1 and event.is_pressed():
			if increment:
				_mouseRightButton = !_mouseRightButton
				$unit.set("visible", _mouseRightButton)

# EN_US: A function to reset the slot
func _clearSlot() -> void:
	# EN_US: Sets the default values
	$color.color = defaults["color"]

# EN_US: A function for when the user clicks checked the slot, to allow it to be cleaned, as long as the parameter "canClear" is "TRUE"
func _on_touch_pressed() -> void:
	var list = get_parent().get_parent().get_node("ItemList")
	GameData.return_radarStats_player(list.get_node("RadarChartStats"),$id.text)
#	get_parent().move_child(self,get_parent().get_child_count())
	player_data_preview($id.text)
	if increment: return
	await get_tree().create_timer(.2).timeout
	if isDragging: return
	if !canClear: return
	_clearSlot()

"""
DRAG AND DROP
"""

# EN_US: Function called automatically as soon as a drag action is identified
# warning-ignore:unused_argument
func _get_drag_data(position):
	if $image.texture != null:
		isDragging = true
# warning-ignore:unused_variable
		var previewPos = -($color.size / 2)
		
		# EN_US(1): Preview of the dragged item, duplicating itself
		# EN_US(2): This duplicate item, only server for the preview, then it is automatically discarded
		var dragPreview = self.duplicate()
		dragPreview.modulate.a = opacityPreview*1.5
		dragPreview.get_node("Options").hide()
		dragPreview.get_node("Options/ButtonAdd").hide()
		dragPreview.get_node("Options/ButtonRm").hide()
#		dragPreview.get_node("color").position = previewPos
#		dragPreview.get_node("image").position = previewPos
#		dragPreview.get_node("preview").position = previewPos
#		dragPreview.get_node("background").position = previewPos
		
#		if dragPreview.image is Texture2D:
#			dragPreview.get_node("color").hide()
		
#		if dragPreview.imagePreview is Texture2D:
#			dragPreview.get_node("preview").show()
#			dragPreview.get_node("background").hide()
#			dragPreview.get_node("color").hide()
#			dragPreview.get_node("name").hide()
#			dragPreview.get_node("image").hide()
		
		# EN_US: Build the preview
		set_drag_preview(dragPreview)
		dragPreview.get_node("image").texture = $image.texture
		
		# EN_US: Return to can_drag / drop
		return self

# EN_US: This function validates if there is an item being dragged over that node, it must return "TRUE" or "FALSE"
# warning-ignore:unused_argument
# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func _can_drop_data(position, data) -> bool:
	if !canReceive: return false
	if data == self: return false
	var ret = false
	
	# EN_US: If the source slot has an option that is significantly different from the target slot
	if increment != data["increment"]:
		return false

	# EN_US: If the slot is incremental
	if increment:
		# EN_US: If the source and destination have the same uid, or the slot has no uid
		ret = true
	else:
		# EN_US: If origin and destination are from the same group, or the slot has no group
		if ((data["group"] == group) or (group == "")):
			ret = true
	return ret

# EN_US: This function captures the preview that was being dragged, and comes in the parameter "data"
# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func _drop_data(position, data) -> void:
	# EN_US: Updates the image, color and quantity of the slot that received the item
	# Swap id player
	var oldid = data.dQtd.text
	var newid = $id.text
	
	var oldPos = data.dPos.text
	var newPos = $pos.text
	
	$id.text = oldid
	data.dQtd.text = newid
	
	# Reload data from player id
	newPosMa = oldPos
	reload_player_data()
	
	newPosMa = newPos
	data.reload_player_data()
	
	player_data_preview($id.text)
	
	# EN_US: Updates the variable in the dropped object (source)
	data.isDragging = false
	
	get_parent().load_stats_team_info()

func _on_ButtonAdd_pressed():
	if $id.text == "":
		get_parent().get_parent().get_node("PanelPlayerData").show()
		get_parent().get_parent().get_node("PanelPlayerData").creat_player_data(0)
		get_parent().changeSlot = uid
	else:
		pass
#		edit_player_data(0,uid)
#		get_parent().get_parent().get_node("PanelPlayerData").show()
#		get_parent().get_parent().get_node("PanelPlayerData").creat_player_data(0)
#		get_parent().changeSlot = uid

func _on_ButtonDel_pressed():
	if $id.text != "":
		Messenger.push_notification(1,"RemovePlayer")
		Messenger.btnYes.connect("pressed",Callable(self,"player_remove"))
#		edit_player_data(0,$id.text)
#		get_parent()._on_ItemList_pressed()
	get_parent().get_parent().get_node("Finance").load_finance_data()

func player_remove():
	edit_player_data(0,$id.text)
	get_parent()._on_ItemList_pressed()
	Messenger.btnYes.disconnect("pressed",Callable(self,"player_remove"))
