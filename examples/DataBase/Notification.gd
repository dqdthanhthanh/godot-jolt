extends FileData

@onready var panel: = $Popup
@onready var label: = $Popup/Panel/VBoxContainer/TextContainer/Label
@onready var btnYes: = $Popup/Panel/VBoxContainer/HBoxContainer/BtnYes
@onready var btnNo: = $Popup/Panel/VBoxContainer/HBoxContainer/BtnNo
@onready var allBtn: = $Popup/Panel/VBoxContainer/HBoxContainer

func _ready() -> void:
	panel.show()
	var dataSet = GameData.get_data(GameData.setting_data_path)
	var oldVer = dataSet.ver
	var newVer = self.settings.ver
	Global.ver = newVer
	
	#Force Update
	if str(newVer) != str(oldVer):
		push_noti(0,"Magic Football World" + "\n" + "You have new update version " + newVer,1)
		GameData.create_new_data_ver()
	else:
		push_noti(0,"Magic Football World" + "\n" + "Version " + newVer,1)
	
	var data = GameData.get_data(GameData.data_path)
	var itemData = GameData.get_data(GameData.item_data_path)
	var file_data:FileData = FileData.new()
	
	if itemData.cards.size() < file_data.item.cards.size():
		GameData.create_new_data_ver()
		print("Updates New Player Card")
	else:
		await get_tree().create_timer(Global.btntime).timeout
		if data.players.size() < file_data.players.size() or  data.teams.size() < file_data.teams.size():
			GameData.save_data(GameData.data_path,GameData.base)
			print("Fix error data")
	
	await get_tree().create_timer(Global.btntime).timeout
#	GameData.play_game_guide()

func push_noti(type = 0, value = "",time:float = 1) -> void:
	panel.show()
	btnYes.show()
	btnNo.show()
	allBtn.show()
	label.text = value
	match type:
		0:
			allBtn.hide()
			await get_tree().create_timer(time).timeout
			panel.hide()
		1:
			btnNo.show()
		2:
			btnNo.hide()
		3:
			allBtn.hide()
#	if funcType != null:
#		var btn
#
#		if type == 0:
#			btn = btnYes
#		else:
#			btn = btnNo
#
##		btn.disconnect("pressed", obj, Func)
#		if param != null:
#			btn.connect("pressed", obj, Func,[param])
#		else:
#			btn.connect("pressed", obj, Func)
	Account.reload_account()

func _on_BtnYes_pressed() -> void:
	panel.hide()

func _on_BtnNo_pressed() -> void:
	panel.hide()

func _on_ButtonClose_pressed() -> void:
	panel.hide()

## Data process
static func multi_text(news) -> String:
	var combine:String
	for i in news.size():
		combine += news[i] + "\n"
	return combine

func create_achi(id, label, text) -> void:
	var data = GameData.get_data(GameData.achi_data_path)
	var notidata = GameData.get_data(GameData.noti_data_path)
	var info = data[id].info
	for i in text:
		info.append(i)
	info.append("")
	info.append("Go Account-Achivement to reward " + "-" + " Magic Football World")
	
	if data[id].active == false:
		var new_notifi = self.notification
		new_notifi.id = notidata.size()
		new_notifi.active = 0
		new_notifi.label = data[id].label
		new_notifi.info = multi_text(info)
		new_notifi.day = Calculate.return_day()
		new_notifi.time = Calculate.return_time()
		notidata.append(new_notifi)
		data[id].active = true
		GameData.save_data(GameData.achi_data_path,data)
		GameData.save_data(GameData.noti_data_path,notidata)
#	Account.reload_account()

func create_noti(label, info) -> void:
	var data = GameData.get_data(GameData.noti_data_path)
	var new_notifi = self.notification.duplicate()
	new_notifi.id = data.size()
	new_notifi.active = 0
	new_notifi.label = label
	new_notifi.info = multi_text(info)
	new_notifi.day = Calculate.return_day()
	new_notifi.time = Calculate.return_time()
	
	data.append(new_notifi)
	GameData.save_data(GameData.noti_data_path,data)
#	Account.reload_account()

static func new_active(id) -> void:
	var data = GameData.get_data(GameData.noti_data_path)
	data[id].active = 1
	GameData.save_data(GameData.noti_data_path,data)
