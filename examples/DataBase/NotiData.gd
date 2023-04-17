extends Node


func create_achi(id, label, info):
	var data = load_data()
	if data.achievement[id].active == false:
		var notifi = data.notification
		var new_notifi = FileData.notification
		new_notifi.id = notifi.size()
		new_notifi.active = 0
		new_notifi.label = label
		new_notifi.info = info
		new_notifi.day = Calculate.return_day()
		new_notifi.time = Calculate.return_time()
		notifi.append(new_notifi)
		data.achievement[id].active = true
		GameData.save_data(GameData.data_path,data)

func create_noti(label, info):
	var data = load_data()
	var notifi = data.notification
	var new_notifi = FileData.notification
	new_notifi.id = notifi.size()
	new_notifi.active = 0
	new_notifi.label = label
	new_notifi.info = info
	new_notifi.day = Calculate.return_day()
	new_notifi.time = Calculate.return_time()
	
	notifi.append(new_notifi)
	GameData.save_data(GameData.data_path,data)

func new_active(id):
	var data = load_data()
	data.notification[id].active = 1
	GameData.save_data(GameData.data_path,data)

func load_data():
	var data = GameData.get_data(GameData.data_path)
	return data

func save_data(value):
	GameData.save_data(GameData.data_path,value)
