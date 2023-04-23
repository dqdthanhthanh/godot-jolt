extends Control

@onready var insRoot: = $Panel/VScrollBarBXH/GridContainer
@onready var tab: = $Panel/MainBtn
var insID:int = 0
var fitter:int = 0
var turnSort: bool = false

@onready var closeBtn: = $Panel/Label/HBoxContainer/ClosePanel

func load_setup() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	creat_player_data(0)

func _on_ButtonSort_pressed() -> void:
	if turnSort == true:
		turnSort = false
	else:
		turnSort = true
	creat_player_data(fitter)

func str_round(value) -> String:
	return str(int(value))

class MyCustomSorter:
	static func sort_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			return true
		return false

func creat_player_data(value:int = 0, type:int = 0) -> void:
	await get_tree().create_timer(Global.btntime).timeout
	var insData: = load("res://MGF Scene/Market/PlayerData.tscn")
	if FormationData.CanFormation == false:
		closeBtn.hide()
	if insRoot.get_child_count()>0:
		for i in insRoot.get_children():
			i.queue_free()
		
	var data = GameData.formation_load_data()
	var account = GameData.get_data(GameData.account_data_path)
	
	if turnSort == true and FormationData.CanFormation == false:
		data.players.sort_custom(Callable(MyCustomSorter, "sort_stat"))
	
	var arr:Array
	var size:int = 6
	
	if FormationData.CanFormation != true:
		arr = data.players
	else:
		$BG.show()
		arr = account.playerSlot
#	if arr.size() < size:
#		size = arr.size()
#	for i in range(size):
	
	for i in arr.size():
		var player_Data
		if FormationData.CanFormation != true:
			player_Data = data.players[i]
		else:
			player_Data = data.players[arr[i]]
		var creStats
		var all = false
		var pos1 = ""
		var pos2 = ""
		var pos3 = ""
		var Ov = $Panel/Label/HBoxContainer/OvInput.text
		var clb = $Panel/Label/HBoxContainer/CLBInput.text
		
		match value:
			0:#all
				all = true
			1:#atk
				pos1 = "CF"
				pos2 = "WF"
				pos3 = "SS"
			2:#mid
				pos1 = "CM"
				pos2 = "DM"
				pos3 = "AM"
			3:#def
				pos1 = "CB"
				pos2 = "WB"
			4:#gk
				pos1 = "GK"
			5:#free
				pass
		
		if (all == true or 
		str(player_Data.Team[0]) == clb or 
		player_Data.Team[2] == pos1 or 
		player_Data.Team[2] == pos2 or 
		player_Data.Team[2] == pos3):
			if float(player_Data.Overall[0]) >= float(Ov):
				if typeof(player_Data.Team[0]) == return_type(type):
					insID = int(player_Data.PlayerID)
					creStats = insData.instantiate()
					if player_Data.Active[0] == false:
						creStats.get_node("Button/active").show()
					else:
						creStats.get_node("Button/active").hide()
					if FormationData.CanFormation == false:
						creStats.get_node("Button/price").show()
					creStats.get_node("Button/name").text = str(player_Data.Name)
					creStats.get_node("Button/id").text = str(player_Data.PlayerID)
					creStats.get_node("Button/pos").text = str(player_Data.Team[2])
					creStats.get_node("Button/check").text = str(player_Data.Team[0])
					creStats.get_node("Button/price/transfer").text = str(player_Data.Price[1])
					creStats.get_node("Button/image").texture = Player.load_image(player_Data.Icon)
					
					creStats.get_node("Button/ov").text = str_round(player_Data.Overall[0])
					creStats.get_node("Button/f").text = str_round(player_Data.Overall[1])
	#	["statFinishing": 0,"statShotPower": 1,"statAccurate": 2,"statBallControl": 3,
	#	"statStamina": 4,"statSpeed": 5,"statPower": 6,"statBody": 7,
	#	"statTackle": 8,"statDefend": 9,"statSave": 10,"statReflexes": 11]
					creStats.get_node("Button/m").text = str_round(player_Data.Overall[2])
					if creStats.get_node("Button/pos").text != "GK":
						creStats.get_node("Button/d").text = str_round(player_Data.Overall[3])
					else:
						creStats.get_node("Button/d").text = str_round(player_Data.Overall[4])
					
					Calculate.stat_color(creStats.get_node("Button/ov"))
					Calculate.stat_color(creStats.get_node("Button/f"))
					Calculate.stat_color(creStats.get_node("Button/m"))
					Calculate.stat_color(creStats.get_node("Button/d"))
					Calculate.position_color(creStats.get_node("Button/pos"))
					
					var teamData = data.teams[int(player_Data.Team[0])]
					creStats.get_node("Button/background").texture = Team.load_team_icon(teamData.icon)
					
					if str(player_Data.Team[0]) == "NON":
						creStats.get_node("Button/background").texture = null
					insRoot.call_deferred("add_child", creStats)
					await get_tree().create_timer(0).timeout

func return_type(type) -> int:
	var value:int
	if FormationData.CanFormation != true:
		value =  3
	else:
		value = 4
	return value

func _on_ClosePanel_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	hide()

func _on_ButtonAll_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 0
	creat_player_data(0)

func _on_ButtonAtk_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 1
	creat_player_data(1)

func _on_ButtonMid_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 2
	creat_player_data(2)

func _on_ButtonDef_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 3
	creat_player_data(3)

func _on_ButtonGk_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 4
	creat_player_data(4)

func _on_ButtonCLB_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	fitter = 5
	creat_player_data(5)

func _exit_tree():
	queue_free()
