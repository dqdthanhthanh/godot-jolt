extends Control


@onready var panelNotiData = $PanelNotiData
@onready var panelNotiItem = $PanelNotiItem
@onready var new = $Account/news
@onready var btnAcc = $Account
@onready var notiItem = preload("res://MGF Scene/Notification/NotifiItem.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	btnAcc.show()
	GameData.fix_data()
	notifi_active()
	reload_icon_data()
	panelNotiData.hide()
	panelNotiItem.hide()

func notifi_active():
	var newCount = 0
	var data = NotiData.load_data().notification
	for i in data.size():
		var item = data[i]
		if item.active == 0:
			newCount += 1
	if newCount > 0:
		new.show()
		new.text = str(newCount)
		if newCount > 99:
			new.text = "99+"
	else:
		new.hide()

func noti_delete_id(id):
	var data = NotiData.load_data()
	var item = data.notification
#	print(id)
#	print(item[id])
	item.erase(item[id])
#	print(item)
	NotiData.save_data(data)
	_on_account_pressed()

func _on_account_pressed():
	panelNotiData.show()
	var groupData = $PanelNotiData/LoadData/VBox
	if groupData.get_child_count() > 0:
		for unit in groupData.get_children():
			unit.queue_free()
	var data = NotiData.load_data()
	var noti = data.notification
	noti.sort_custom(Callable(MyCustomSorter,"sort_notifi_id"))
	noti.sort_custom(Callable(MyCustomSorter,"sort_notifi_active"))

	for i in noti.size():
		noti[i].id = i
	NotiData.save_data(data)

	for i in noti.size():
		var itemData = noti[i]
		var ins = notiItem.instantiate()
		groupData.add_child(ins)
		if itemData.active == 1:
			ins.btnDelete.visible = true
		ins.custom_minimum_size.x = size.x-40
		ins.time.text = itemData.time
		ins.day.text = itemData.day
		ins.label.text = itemData.label
		ins.info.text = itemData.info
		ins.id = itemData.id

func reload_icon_data():
	var base = GameData.get_data(GameData.data_path)
	if base.settings.seasons.size()>0:
		var data = GameData.season_load_data()
		var teamData = data.teams
		var seasonData = data.season
		SeasonData.teamA = int(seasonData.teamA)
		btnAcc.icon = load(teamData[seasonData.teamA].icon)
	else:
		SeasonData.teamA = 0
		btnAcc.icon = load("res://Assets2D/UI/user.png")

class MyCustomSorter:
	static func sort_notifi_active(a, b):
		if a.active < b.active:
			return true
		return false
	static func sort_notifi_id(a, b):
		if a.id < b.id:
			return true
		return false

func _on_ButtonClose_pressed():
	notifi_active()
	panelNotiData.hide()
	panelNotiItem.hide()

func _on_ItemButtonExit_pressed():
	_on_account_pressed()
	panelNotiItem.hide()


