extends Control


@onready var iconTrue = preload("res://Assets2D/UI/iconApply.png")
@onready var iconFalse = preload("res://Assets2D/UI/iconApplyNon.png")

@onready var music = $Shop/Music/ScrollContainer/VBoxContainer
@onready var card = $Shop/Card/ScrollContainer/VBoxContainer


func _ready() -> void:
	$Shop/Player.load_setup()
	tab_music()
	tab_card()

func tab_music() -> void:
	var data = GameData.get_data(GameData.item_data_path)
	var files = data.musics
	if music.get_child_count()>0:
		for i in music.get_children():
			i.queue_free()
	for i in files.size():
#	for i in range(7):
		var item = files[i]
		var ins = load("res://MGF Scene/Market/MusicFile.tscn").instantiate()
		music.add_child(ins)
		ins.get_node("HBoxContainer/File").text = item.label
		ins.get_node("HBoxContainer/Author").text = item.author
		ins.get_node("HBoxContainer/HBoxContainer/Price").text = str(item.price)
		ins.connect("pressed", Callable(self, "music_play").bind(item))
		if item.active == true:
			ins.get_node("HBoxContainer/Active").texture = iconTrue
		else:
			ins.connect("pressed", Callable(self, "music_click").bind(i,str(item.price)))
			ins.get_node("HBoxContainer/Active").texture = iconFalse
		await get_tree().create_timer(0).timeout

func music_play(file) -> void:
	SoundGlobal.play_mucis(file)

func music_click(id,price) -> void:
	if Account.check_money(0,price) == true:
		Notification.push_noti(1,"Unlock Item: " + price + " Coins")
		Notification.btnYes.connect("pressed", Callable(self, "music_buy_item").bind(id,price))
		Notification.btnNo.connect("pressed", Callable(self, "music_btn_no"))
	else:
		Notification.push_noti(0,"Not enough coins")

func music_btn_no() -> void:
	Notification.btnYes.disconnect("pressed", Callable(self, "music_buy_item"))
	Notification.btnNo.disconnect("pressed", Callable(self, "music_btn_no"))

func music_buy_item(id,price) -> void:
	Account.gold(-int(price))
	Account.item_check(2)
	music_btn_no()
	var data = GameData.get_data(GameData.item_data_path)
	var musicFiles = data.musics
	musicFiles[id].active = true
	GameData.save_data(GameData.item_data_path,data)
	music.get_child(id).disconnect("pressed", Callable(self, "music_click"))
	music.get_child(id).get_node("HBoxContainer/Active").texture = load("res://Assets2D/UI/iconApply.png")

func _exit_tree():
	SoundGlobal.play_other_music()
	queue_free()

func tab_card() -> void:
	var data = GameData.get_data(GameData.data_path)
	var itemdata = GameData.get_data(GameData.item_data_path)
	var files = itemdata.cards
	if card.get_child_count()>0:
		for i in card.get_children():
			i.queue_free()
	for i in files.size():
#	for i in range(7):
		var item = files[i]
		var ins = load("res://MGF Scene/Market/CardFile.tscn").instantiate()
		card.add_child(ins)
		ins.get_node("HBoxContainer/Icon").texture = Player.load_icon(item.file)
		var cardName:String
		if item.id >0:
			cardName = data.players[item.id].Name
		else:
			cardName = "Unknow"
		ins.get_node("HBoxContainer/Label").text = cardName
		ins.get_node("HBoxContainer/HBoxContainer/Price").text = str(item.price)
		ins.connect("pressed", Callable(self, "card_open").bind(item.file))
		if item.active == true:
			ins.get_node("HBoxContainer/Active").texture = iconTrue
		else:
			ins.connect("pressed", Callable(self, "card_click").bind(i,str(item.price)))
			ins.get_node("HBoxContainer/Active").texture = iconFalse
		await get_tree().create_timer(0).timeout

func card_open(file) -> void:
	$Shop/Card/PlayerCard/TextureRect.texture = Player.load_high_image(file)

func card_click(id,price) -> void:
	if Account.check_money(0,price) == true:
		Notification.push_noti(1,"Unlock Item: " + price + " Coins")
		Notification.btnYes.connect("pressed", Callable(self, "card_buy_item").bind(id,price))
		Notification.btnNo.connect("pressed", Callable(self, "card_btn_no"))
	else:
		Notification.push_noti(0,"Not enough coins")

func card_btn_no() -> void:
	Notification.btnYes.disconnect("pressed", Callable(self, "card_buy_item"))
	Notification.btnNo.disconnect("pressed", Callable(self, "card_btn_no"))

func card_buy_item(id,price) -> void:
	Account.gold(-int(price))
	Account.item_check(1)
	card_btn_no()
	var data = GameData.get_data(GameData.item_data_path)
	var cardFiles = data.cards
	cardFiles[id].active = true
	GameData.save_data(GameData.item_data_path,data)
	card.get_child(id).disconnect("pressed", Callable(self, "card_click"))
	card.get_child(id).get_node("HBoxContainer/Active").texture = load("res://Assets2D/UI/iconApply.png")

func _on_Shop_tab_selected(tab) -> void:
	SceneTransition.transition()

func _on_MainBtn_on_tab_select(id):
	$Shop/Player.load_setup()
