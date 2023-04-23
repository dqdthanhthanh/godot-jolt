extends CanvasLayer

@onready var _gold: = $Account/Info/Gold
@onready var _diamond: = $Account/Info/Diamond

@onready var info: = $Account/Info

@onready var panel: = $Panel
@onready var tab: = $Panel/MainBtn
@onready var panelNotiData: = $Panel/Tab/Messenger/PanelNotiData
@onready var panelNotiItem: = $Panel/Tab/Messenger/PanelNotiItem
@onready var new: = $Account/news
@onready var btnAccount: = $Account

@onready var UIMusic: = $Panel/CenterContainer/File
@onready var slider: = $Panel/CenterContainer/File/BtnSlider
@onready var BtnPlayMusic: = $Panel/CenterContainer/File/PlayOtherMusic

var size:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	if !Global.device_is_mobile():
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,
#		SceneTree.STRETCH_ASPECT_KEEP,
#		Vector2(1792,828),1)
	
	game_load_set_up()
	size = panel.size.x
	show()
	panel.hide()
	btnAccount.show()
	GameData.fix_data()
	panelNotiItem.hide()

func game_load_set_up() -> void:
	reload_account()
	Account.info.show()
	Engine.time_scale = 1
	get_tree().paused = false

static func check_money(type,value):
	var data = GameData.get_data(GameData.account_data_path)
	match type:
		0:
			if data.Gold - int(value) >= 0:
				return true
			else:
				return false
		1:
			if data.Diamond - int(value) >= 0:
				return true
			else:
				return false

func item_check(type:int = 0) -> void:
	var data = GameData.get_data(GameData.account_data_path)
	var item = data.Item
	match type:
		0:
			item.Player += 1
			GameData.save_data(GameData.account_data_path,data)
			var count = item.Player
			if count == 1:
				Notification.create_achi(14,"",[])
			elif count == 10:
				Notification.create_achi(15,"",[])
			elif count == 100:
				Notification.create_achi(16,"",[])
			elif count == 1000:
				Notification.create_achi(17,"",[])
		1:
			item.Card += 1
			GameData.save_data(GameData.account_data_path,data)
			var count = item.Card
			if count == 1:
				Notification.create_achi(18,"",[])
			elif count == 10:
				Notification.create_achi(19,"",[])
			elif count == 100:
				Notification.create_achi(20,"",[])
			elif count == 1000:
				Notification.create_achi(21,"",[])
		2:
			item.Music += 1
			GameData.save_data(GameData.account_data_path,data)
			var count = item.Music
			if count == 1:
				Notification.create_achi(22,"",[])
			elif count == 10:
				Notification.create_achi(23,"",[])
			elif count == 100:
				Notification.create_achi(24,"",[])
			elif count == 1000:
				Notification.create_achi(25,"",[])
		3:
			item.Replay += 1
			GameData.save_data(GameData.account_data_path,data)
			var count = item.Replay
			if count == 1:
				Notification.create_achi(26,"",[])
			elif count == 10:
				Notification.create_achi(27,"",[])
			elif count == 100:
				Notification.create_achi(28,"",[])
			elif count == 1000:
				Notification.create_achi(29,"",[])
	
	await get_tree().create_timer(Global.btntime).timeout
	var all = item.Player + item.Card + item.Music + item.Replay
	if all == 1:
		Notification.create_achi(10,"",[])
	elif all == 10:
		Notification.create_achi(11,"",[])
	elif all == 100:
		Notification.create_achi(12,"",[])
	elif all == 1000:
		Notification.create_achi(13,"",[])
	
	Account.reload_account()

func gold(price,time:int = 100) -> void:
	var data = GameData.get_data(GameData.account_data_path)
	var count:int = data.Gold
	var value:int = int(price)
	
	data.Gold += value
	if data.Gold < 0:
		data.Gold = 0
	
	GameData.save_data(GameData.account_data_path,data)
	for i in range(time):
		count += round(value/time)
		_gold.text = str(count)
		$Panel/Info/Gold.text = _gold.text
		await get_tree().create_timer(0).timeout
		SoundGlobal.get_node("SfxrCoin").play()
	Account.reload_account()

func diamond(price,time:int = 100) -> void:
	var data = GameData.get_data(GameData.account_data_path)
	var count:int = data.Diamond
	var value:int = int(price)
	
	data.Diamond += value
	if data.Diamond < 0:
		data.Diamond = 0
	
	GameData.save_data(GameData.account_data_path,data)
	for i in range(time):
		count += value/time
		_diamond.text = str(count)
		$Panel/Info/Diamond.text = _diamond.text
		await get_tree().create_timer(0).timeout
		SoundGlobal.get_node("SfxrCoin").play()
	Account.reload_account()

func reload_account() -> void:
	var data = GameData.get_data(GameData.account_data_path)
	_gold.text = str(data.Gold)
	$Panel/Info/Gold.text = _gold.text
	_diamond.text = str(data.Diamond)
	$Panel/Info/Diamond.text = _diamond.text
	notifi_news()
	reload_icon_data()

func reload_icon_data() -> void:
	var base = GameData.get_data(GameData.setting_data_path)
	if base.seasons.size()>0:
		var data = GameData.season_load_data()
		var teamData = data.teams
		var seasonData = data.season
		SeasonData.teamA = int(seasonData.teamA)
		btnAccount.icon = Team.load_team_icon(teamData[seasonData.teamA].icon)
	else:
		SeasonData.teamA = 0
		btnAccount.icon = load("res://Assets2D/UI/user.png")

func notifi_news() -> void:
	var newCount = 0
	var data = GameData.get_data(GameData.noti_data_path)
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

func noti_delete_id(id) -> void:
	var data = GameData.get_data(GameData.noti_data_path)
	data.erase(data[id])
	GameData.save_data(GameData.noti_data_path,data)
	_on_Account_pressed()

func _on_Account_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(0).timeout
	reload_account()
	panel.show()
	tab.tab_select(tab.current_tab)
	_on_MainBtn_on_tab_select(tab.current_tab)

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	panel.hide()
	Calculate.remove_children($Panel/Tab/Achievement/LoadData/VBox)
	Calculate.remove_children($Panel/Tab/Messenger/PanelNotiData/LoadData/VBox)

func _on_MainBtn_on_tab_select(id):
	print(id)
	SceneTransition.transition()
	await get_tree().create_timer(Global.btntime).timeout
	$Panel/Tab.get_child(id).create_data()
