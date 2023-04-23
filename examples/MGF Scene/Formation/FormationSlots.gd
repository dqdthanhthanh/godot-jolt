extends Control

# EN_US: Unique ID for the slot, for the dragged item, or for the slot to accept only other slots of that ID
@export var uid = 0 # (int, 0, 100)
var id:int = 0
@export var pos = "SUB" # (String, "GK", "CB", "LB", "RB", "CM","LF", "RF", "SUB")
var maxUid:int = 10
var setUid:int = 6

# EN_US: Accepts items in the same group
@export var group = ""

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
@export var color:Color = Color(0.5,0.5,0.5,1)

# EN_US: Drag preview image
@export var imageBackGround:Texture2D = null: set = _setImageBackGround

# EN_US: Local variables
var defaults: Dictionary = {}
var _mouseRightButton: bool = false
var isDragging: bool = false

@onready var dSta: = $sta
@onready var dFoul: = $foul
@onready var dName: = $name
@onready var dImage: = $image
@onready var dQtd: = $id
@onready var dColor: = $color
@onready var dPos: = $pos

@onready var menu: = get_parent().get_parent()
@export var team:int = 0

var newPosMa:String = ""
var rmPlayerID:int = 0

func _setImageBackGround(newValue) -> void:
	imageBackGround = newValue
	if weakref($background).get_ref():
		$background.texture = imageBackGround

func load_slot_player_data() -> void:
	load_player_card()
	var data = GameData.formation_load_data()
	$background.texture = Team.load_team_icon(data.teams[team].icon)
	var teamData = data.teams[team]
	var id_Data
	var stt_Data
	var playerData = data.players
	for i in teamData.Fid.size():
		id_Data = int(teamData.Fid[i])
		stt_Data = int(teamData.Fstt[i])
		playerData = data.players[id_Data]
		if uid == stt_Data:
#			$sta.show()
			$sta.value = playerData.Health[1]
			$name.text = playerData.Name
			load_player_card(playerData.PlayerID,playerData.Team[0],playerData.Name,
			playerData.Icon,playerData.Team[2],
			playerData.Overall[1],playerData.Overall[2],playerData.Overall[3],playerData.Overall[0],false)
	playerData = data.players[int($id.text)]
	if uid >= 7:
		Calculate.stat_color($ov)
		Calculate.position_color($pos)
		$Options.show()
	elif uid < 7:
		match uid:
			0:
				$pos.text = "GK"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[4])
					$d.text = str_round(playerData.Overall[4])
			1:
				$pos.text = "CB"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[3])
			2:
				$pos.text = "RB"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[3])
			3:
				$pos.text = "LB"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[3])
			4:
				$pos.text = "CM"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[2])
			5:
				$pos.text = "LF"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[1])
			6:
				$pos.text = "RF"
				if $id.text != "":
					$ov.text = str_round(playerData.Overall[1])
		Calculate.stat_color($ov)
		Calculate.stat_color($d)
		Calculate.position_color($pos)
		$Options.hide()
		update_player_data_MainGame()

func str_round(value):
	return str(int(value))

func load_player_card(id="",t="",na="",tt="",p="",f="",m="",d="",ov="",vi=true) -> void:
	$id.text = str(id)
	$check.text = str(t)
	$name.text = na
	if tt == "":
		$image.texture = null
	else:
		$image.texture = Player.load_image(tt)
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

func reload_player_data() -> void:
	var data = GameData.formation_load_data()
	var teamIcon = data.teams[team].icon
	var playerData = data.players[int($id.text)]
	
	if $id.text != "":
#		$sta.show()
		update_player_data_MainGame()
		$background.texture = Team.load_team_icon(teamIcon)
		$image.texture = Player.load_image(playerData.Icon)
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
		$background.texture = Team.load_team_icon(teamIcon)
		$image.texture = null
		$name.text = ""
		$id.text = ""
		$check.text = ""
		$ov.text = ""
		$f.text = ""
		$m.text = ""
		$d.text = ""
		$foul.hide()
		$lock.hide()
		$sta.hide()
		if uid >6:
			$pos.text = ""

func update_player_data_MainGame() -> void:
	if $id.text != "" and Global.gameModeCur < 2:
		var data = GameData.formation_load_data()
		var playerData = data.players[int($id.text)]
		$foul.text = str(playerData.Foul[1])
		if playerData.isSub[0] == false:
			$lock.show()
		else:
			$lock.hide()
		if int($foul.text) == 0:
			$foul.hide()
		elif int($foul.text) > 0 and int($foul.text) < 2:
			$foul.show()
			$foul.modulate = Color.YELLOW
		else:
			$foul.text = "1"
			$foul.modulate = Color.RED

func edit_player_data(edit,id)-> void:
	var data = GameData.formation_load_data()
#	var teamData = game_Data.teams
	var teamIcon = data.teams[team].icon
	var player_Data = data.players
	var teamDataID = data.teams[team].Fid
	var teamDataSTT = data.teams[team].Fstt
	
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
				GameData.formation_save_data(data)
			else:
				Notification.push_noti(0,"The team must have 7 people in the squad")
		1:##AddNew
			print("AddNewPlayer")
			var addPlayer = player_Data[int(id)].duplicate()
			addPlayer.PlayerID = int(player_Data.size())
			addPlayer.Team[0] = team
			$background.texture = Team.load_team_icon(teamIcon)
			Calculate.position_color($pos)
			
			player_Data.append(addPlayer)
			$id.text = str(addPlayer.PlayerID)
			$check.text = str(team)
			teamDataID.append(int(addPlayer.PlayerID))
			teamDataSTT.append(int(uid))
			GameData.formation_save_data(data)
		2:##Add
			print("AddPlayer")
			var addPlayer = player_Data[int(id)]
			$id.text = str(addPlayer.PlayerID)
			$check.text = str(team)
			$background.texture = Team.load_team_icon(teamIcon)
			Calculate.position_color($pos)
			addPlayer.Team[0] = int(team)
			teamDataID.append(int(addPlayer.PlayerID))
			teamDataSTT.append(int(uid))
			GameData.formation_save_data(data)
	
	print("ID",teamDataID)
	print("STT",teamDataSTT)
	menu.finance.load_finance_data()

func player_data_preview(value) -> void:
	if $image.texture != null:
		var data = GameData.formation_load_data()
		var teamData = data.teams[team]
		var playerData = data.players[int(value)]
		
		var list = menu.get_node("PlayerBaseInfo")
		list.get_node("Panel/Name").text = playerData.Name
		list.get_node("Panel/Pos").text = playerData.Team[1]
		Calculate.position_color(list.get_node("Panel/Pos"))
		
		list.get_node("Panel/Texture2D").texture = Player.load_high_image(playerData.Icon)
		
		list.get_node("PanelStats/Games/Label1").text = str(playerData.Season[0])
		list.get_node("PanelStats/Games/Label2").text = str(playerData.Season[2])
		list.get_node("PanelStats/Games/Label3").text = str(playerData.Season[3])
		
		list.get_node("PanelStats/Stats/Label4").text = str(playerData.Season[4])
		list.get_node("PanelStats/Stats/Label5").text = str(playerData.Season[5])
		list.get_node("PanelStats/Stats/Label7").text = str(playerData.Season[8])
		if playerData.Season[0]>0:
			list.get_node("PanelStats/Games/Label0").text = str("%.2f" % float(playerData.Season[1]/playerData.Season[0]))
		else:
			list.get_node("PanelStats/Games/Label0").text = "5"
		if playerData.Season[10]>0:
			list.get_node("PanelStats/Stats/Label9").text = str(round(playerData.Season[10]/playerData.Season[0]))
		else:
			list.get_node("PanelStats/Stats/Label9").text = "0"
		
		list.get_node("Panel/Popular").value = int(playerData.Price[0])*10
		list.get_node("Panel/Popular").position.x = remap(list.get_node("Panel/Popular").value,0,100,100,48)
		list.get_node("Panel/Overall").text = str_round(playerData.Overall[0])
		
		Calculate.stat_color(list.get_node("Panel/Overall"))

func _ready() -> void:
	defaults = {
		"color": color
	}
	
	# EN_US: It is necessary to put the mouse filter as ignore, otherwise the drag will not work
	# Set all children as MOUSE_FILTER_IGNORE
	for n in get_children():
		if "mouse_filter" in n:
			n.mouse_filter = MOUSE_FILTER_IGNORE

# EN_US: If the user clicks the right mouse button, or two fingers on the screen
# EN_US: Enables / Disables unit transfer of slots that increment
func _input(event) -> void:
	if $id.text != "":
		# EN_US: If you right-click
		if event is InputEventMouseButton:
			if event.button_index == 2 and event.is_pressed():
				if increment:
					_mouseRightButton = !_mouseRightButton
					$sta.set("visible", _mouseRightButton)

		# EN_US: If you touch the screen with both fingers
		if event is InputEventScreenTouch:
			if event.index == 1 and event.is_pressed():
				if increment:
					_mouseRightButton = !_mouseRightButton
					$sta.set("visible", _mouseRightButton)

# EN_US: A function to reset the slot
func _clearSlot() -> void:
	# EN_US: Sets the default values
	$color.color = defaults["color"]

# EN_US: A function for when the user clicks on the slot, to allow it to be cleaned, as long as the parameter "canClear" is "TRUE"
func _on_touch_pressed() -> void:
	if menu.can_preview_player() == true:
		if $id.text != "":
			menu.id = int($id.text)
		var list = menu.get_node("PlayerBaseInfo")
		GameData.return_radarStats_player(list.get_node("RadarChartStats"),$id.text)
	#	get_parent().move_child(self,get_parent().get_child_count())
		player_data_preview($id.text)
		if increment: return
		await get_tree().create_timer(0).timeout
		if isDragging: return
		if !canClear: return
		_clearSlot()

"""
DRAG AND DROP
"""

# EN_US: Function called automatically as soon as a drag action is identified
# warning-ignore:unused_argument
func _get_drag_data(position):
#	if isSub[0] == true:
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
			
			# EN_US: Build the preview
			set_drag_preview(dragPreview)
			dragPreview.get_node("image").texture = $image.texture
			
			# EN_US: Return to can_drag / drop
			return self

# EN_US: This function validates if there is an item being dragged over that node, it must return "TRUE" or "FALSE"
# warning-ignore:unused_argument
# warning-ignore:shadowed_variable
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
#	check_player_foul($id.text)[0] bi thay
#	check_player_foul(data.dQtd.text)[0] keo de thay
#	prints(check_player_foul($id.text)[0],check_player_foul(data.dQtd.text)[0])
	prints(int(uid),int(data.uid))
	var check:bool = false
	if Global.gameModeCur < 2:
		if check_player_foul(data.dQtd.text)[0] == false and check_player_foul($id.text)[0] == false:
			check = false
		elif check_player_foul(data.dQtd.text)[0] == true and check_player_foul($id.text)[0] == true:
			check = true
		if int(uid) < 7 and int(data.uid) < 7:
			check = true
		elif int(uid) > 6 and int(data.uid) > 6:
			check = true
	else:
		check = true
	print(check)
	
	if check == true:
		# EN_US: Updates the image, color and quantity of the slot that received the item
		# Swap id player
		var oldid = data.dQtd.text
		var newid = $id.text
		
		var oldsta = data.dSta.value
		var newsta = $sta.value
		
		var oldPos = data.dPos.text
		var newPos = $pos.text
		
		$id.text = oldid
		data.dQtd.text = newid
		
		$sta.value = oldsta
		data.dSta.value = newsta
		
		# Reload data from player id
		newPosMa = oldPos
		reload_player_data()
		
		newPosMa = newPos
		data.reload_player_data()
		
		player_data_preview($id.text)
		
		# EN_US: Updates the variable in the dropped object (source)
		data.isDragging = false
		
		menu.load_stats_team_info()

func check_player_foul(id):
	var data = GameData.formation_load_data()
	var playerData = data.players[int(id)]
	return playerData.isSub

func _on_ButtonAdd_pressed() -> void:
	if $id.text == "":
		menu.get_node("PanelPlayerData").show()
		menu.get_node("PanelPlayerData").creat_player_data(0,1)
		menu.changeSlot = uid
	else:
		Notification.push_noti(0,"Choose an empty position.")

func _on_ButtonDel_pressed() -> void:
	if $id.text != "":
		var file_data:FileData = FileData.new()
		var data = GameData.formation_load_data()
		var playerData = data.players[int($id.text)]
		prints("Buy Playẻer",playerData.PlayerID)
		if playerData.PlayerID < file_data.players.size():
			Notification.push_noti(0,"This player is fixed in the team.")
		else:
			Notification.push_noti(1,"RemovePlayer")
			Notification.btnYes.connect("pressed", Callable(self, "player_remove"))
	#		edit_player_data(0,$id.text)
	#		menu._on_PlayerInfo_pressed()
			menu.finance.load_finance_data()

func player_remove() -> void:
	edit_player_data(0,$id.text)
	Notification.btnYes.disconnect("pressed", Callable(self, "player_remove"))

func _exit_tree():
	queue_free()
