extends Control


@onready var groupData = $LoadData/VBox

func create_data():
	Calculate.remove_children(groupData)
	
	var data = GameData.get_data(GameData.achi_data_path)
	
	for i in data.size():
		var itemData = data[i]
		var ins = load("res://DataBase/Account/AchiFile.tscn").instantiate()
		groupData.add_child(ins)
		ins.custom_minimum_size.x = Account.size-40
		ins.id = i
		ins.get_node("HBoxContainer/Label").text = itemData.label
		ins.get_node("HBoxContainer/Info").text = ""
		ins.get_node("HBoxContainer/HBoxContainer/Price").text = str(itemData.price[0])
		
		var activeOn = load("res://Assets2D/UI/iconApply.png")
		var activeOff = load("res://Assets2D/UI/iconApplyNon.png")
		if itemData.active == true:
			ins.active = itemData.price[1]
			ins.get_node("HBoxContainer/Active").texture = activeOn
		else:
			ins.get_node("HBoxContainer/Active").texture = activeOff
		await get_tree().create_timer(0).timeout
