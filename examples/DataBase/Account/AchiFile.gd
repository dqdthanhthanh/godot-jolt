extends Button


var id:int
var active:bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func reward():
	if active == false:
		var data = GameData.get_data(GameData.achi_data_path)
		var achi = data
		achi[id].price[0] = 0
		achi[id].price[1] = true
		GameData.save_data(GameData.achi_data_path,data)
		Account.gold($HBoxContainer/HBoxContainer/Price.text)
		$HBoxContainer/HBoxContainer/Price.text = str(0)
#		Notification.push_noti(0,data.teams[i].name + " team doesn't have enough 7 people in the squad")
#		Notification.btnYes.disconnect("pressed", self, "create_match_data")


func _on_AchiFile_pressed():
	reward()
