extends Control


@onready var groupData = $PanelNotiData/LoadData/VBox


func create_data():
	Calculate.remove_children(groupData)
	
	var data = GameData.get_data(GameData.noti_data_path)
	data.sort_custom(Callable(MyCustomSorter, "sort_notifi_id"))
	data.sort_custom(Callable(MyCustomSorter, "sort_notifi_news"))
	
	for i in data.size():
		data[i].id = i
	GameData.save_data(GameData.noti_data_path,data)
	
#	var size:int = 5
#	if data.size() < size:
#		size = data.size()
#	for i in range(size):
	for i in data.size():
		var itemData = data[i]
		var ins = load("res://DataBase/Account/NotifiItem.tscn").instantiate()
		groupData.add_child(ins)
		if itemData.active == 1:
			ins.btnDelete.visible = true
		ins.custom_minimum_size.x = Account.size-40
		ins.time.text = itemData.time
		ins.day.text = itemData.day
		ins.label.text = itemData.label
		ins.info.text = itemData.info
		ins.id = itemData.id
		await get_tree().create_timer(0).timeout

class MyCustomSorter:
	static func sort_notifi_news(a, b):
		if a.active < b.active:
			return true
		return false
	static func sort_notifi_id(a, b):
		if a.id < b.id:
			return true
		return false
