extends Control


var playerID = 0
var all:float = 0.0
var pp = 0

@onready var pData = $VBoxContainer/playerData
@onready var pIDInput = $VBoxContainer/playerLineEdit
@onready var poIDInput = $VBoxContainer/pointLineEdit
@onready var point = $VBoxContainer/Label



func _ready() -> void:
	get_player(playerID)

func get_player(id):
	var data = GameData.get_data(GameData.data_path)
	pp += all
	if int(id) < data.players.size():
		var playerData = data.players[int(id)]
		pData.text = str(playerData.Name) + " "
#		pData.text += str(playerData.Overall)
		var a = playerData.Overall
		var d = []
		for i in a.size():
			var c = a[i]
			d.append(float(c+0.1))
#			print(c)
		pData.text += str(d)
		var b = []
		for i in a.size():
			var n = remap(70,50,100,100,1000)
			print(n)
			var c = a[i]
			var e = a[i]*22*(float(pp)/n)
			var f = c+e
#			f = clamp(f,0,99)
			b.append(f+0.1)
		pData.text += "\n"
		pData.text += str(playerData.Name) + " "
		pData.text += str(b)
		pData.text += "\n"+str(pp)

func _on_playerLineEdit_text_changed(new_text):
	if typeof(int(new_text)) == 2:
		get_player(new_text)
		playerID = new_text

func _on_Button_pressed():
	get_player(playerID)

func _on_pointLineEdit_text_changed(new_text):
	all = 0
	var p = 7-float(poIDInput.text)
	all -= float(p)
	point.text = str(all)
	get_player(playerID)
