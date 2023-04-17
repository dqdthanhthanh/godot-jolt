extends Control

@onready var insRoot = $Panel/VScrollBarBXH/GridContainer
@onready var insData = preload("res://MGF Scene/Market/PlayerData.tscn")
var insID:int = 0
var fitter:int = 0

var turnSort: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.MGFMode != Global.Season:
		creat_player_data(0)

func load_setup():
	creat_player_data(0)

func _on_ButtonSort_pressed():
	if turnSort == true:
		turnSort = false
	else:
		turnSort = true
	creat_player_data(fitter)

func str_round(value):
	return str(round(float(value)))

class MyCustomSorter:
	static func sort_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			return true
		return false

func creat_player_data(value):
	if insRoot.get_child_count()>0:
		for i in insRoot.get_children():
			i.queue_free()
		
	var data = GameData.formation_load_data()
	
	if turnSort == true:
		data.players.sort_custom(Callable(MyCustomSorter,"sort_stat"))
# warning-ignore:shadowed_variable
	for i in range(data.players.size()):
		var player_Data = data.players[i]
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
				insID = int(player_Data.PlayerID)
				creStats = insData.instantiate()
				creStats.get_node("Button/name").text = str(player_Data.Name)
				creStats.get_node("Button/id").text = str(player_Data.PlayerID)
				creStats.get_node("Button/pos").text = str(player_Data.Team[2])
				creStats.get_node("Button/check").text = str(player_Data.Team[0])
				creStats.get_node("Button/transfer").text = str(player_Data.Price[1])
				creStats.get_node("Button/image").texture = load(player_Data.texturePath)
				
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
				
				var fileData = GameData.get_data(GameData.data_path)
				var teamData = fileData.teams[int(player_Data.Team[0])]
				creStats.get_node("Button/background").texture = load(teamData.icon)
				
				if str(player_Data.Team[0]) == "NON":
					creStats.get_node("Button/background").texture = null
				insRoot.call_deferred("add_child", creStats)
				await get_tree().create_timer(0).timeout

func _on_ClosePanel_pressed():
	hide()

func _on_ButtonAll_pressed():
	fitter = 0
	creat_player_data(0)

func _on_ButtonAtk_pressed():
	fitter = 1
	creat_player_data(1)

func _on_ButtonMid_pressed():
	fitter = 2
	creat_player_data(2)

func _on_ButtonDef_pressed():
	fitter = 3
	creat_player_data(3)

func _on_ButtonGk_pressed():
	fitter = 4
	creat_player_data(4)

func _on_ButtonCLB_pressed():
	fitter = 5
	creat_player_data(5)
