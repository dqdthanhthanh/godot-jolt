extends Panel


@onready var menu: = get_parent().get_parent().get_parent().get_parent()

func str_round(value) -> String:
	return str(round(float(value)))

# warning-ignore:unused_variable
func _on_Button_pressed() -> void:
	if FormationData.CanFormation != true:
		if SeasonData.check_season_mode() == false:
			if get_node("Button/active").visible == true:
				if FormationData.CanFormation == false:
					menu.get_node("PlayerCard").btnBuy.show()
				else:
					menu.get_node("PlayerCard").btnBuy.hide()
				menu.get_node("PlayerCard").create_art(int($Button/id.text))
				menu.get_node("PlayerCard").btnBuy.connect("pressed", Callable(self, "on_button_buy_pressed"))
				menu.get_node("PlayerCard").btnClose.connect("pressed", Callable(self, "on_button_close_pressed"))
			else:
				menu.get_node("PlayerCard").btnBuy.hide()
				menu.get_node("PlayerCard").create_art(int($Button/id.text))
	else:
		var data = GameData.formation_load_data()
		var check = data.players[int($Button/id.text)].Active[0]
		if check == true:
			var forNode = menu.get_parent().get_node("GroupSlots")
			var slotNode = menu.get_parent().changeSlot
			for i in forNode.get_children():
				if i.uid == slotNode:
					i.get_node("id").text = $Button/id.text
					i.get_node("check").text = $Button/check.text
					if i.get_node("check").text != "NON":
						print("Buy player")
						if Global.isPlayerCreate == true:
							i.get_node("id").text = $Button/id.text
							i.get_node("name").text = $Button/name.text
							i.get_node("pos").text = $Button/pos.text
							i.get_node("check").text = $Button/check.text
							i.get_node("image").texture = $Button/image.texture
							i.get_node("ov").text = $Button/ov.text
							i.get_node("f").text = $Button/f.text
							i.get_node("m").text = $Button/m.text
							i.get_node("d").text = $Button/d.text
							Calculate.stat_color(i.get_node("ov"))
							Calculate.stat_color(i.get_node("f"))
							Calculate.stat_color(i.get_node("m"))
							Calculate.stat_color(i.get_node("d"))
							if i.get_node("id").text != "":
								i.edit_player_data(1,$Button/id.text)
						else:
							i.get_node("id").text = ""
							i.get_node("check").text = ""
							if i.get_node("id").text != "":
								i.edit_player_data(1,$Button/id.text)
					else:
						print("Buy Done")
						i.get_node("id").text = $Button/id.text
						i.get_node("name").text = $Button/name.text
						i.get_node("pos").text = $Button/pos.text
						i.get_node("check").text = $Button/check.text
						i.get_node("image").texture = $Button/image.texture
						i.get_node("ov").text = str_round($Button/ov.text)
						i.get_node("f").text = str_round($Button/f.text)
						i.get_node("m").text = str_round($Button/m.text)
						i.get_node("d").text = str_round($Button/d.text)
						Calculate.stat_color(i.get_node("ov"))
						Calculate.stat_color(i.get_node("f"))
						Calculate.stat_color(i.get_node("m"))
						Calculate.stat_color(i.get_node("d"))
						i.edit_player_data(2,$Button/id.text)
			menu.hide()
		else:
			menu.get_node("PlayerCard").btnBuy.hide()
			menu.get_node("PlayerCard").create_art(int($Button/id.text))

func on_button_buy_pressed() -> void:
	var id  = int(get_node("Button/id").text)
	var price  = int(get_node("Button/price/transfer").text)
	if Account.check_money(0,price) == true:
		Notification.push_noti(1,"Unlock Player: " + str(price) + " Coins")
#		Notification.load_icon()
		Notification.btnYes.connect("pressed", Callable(self, "buy_player").bind(id,price))
		Notification.btnNo.connect("pressed", Callable(self, "player_btn_no"))
	else:
		Notification.push_noti(0,"Not enough coins")
#		Notification.load_icon()

func player_btn_no() -> void:
	Notification.btnYes.disconnect("pressed", Callable(self, "buy_player"))
	Notification.btnNo.disconnect("pressed", Callable(self, "player_btn_no"))

func buy_player(id,price) -> void:
#	prints("Unlock",id,":",price)
	Account.gold(-int(price))
	Account.item_check(0)
	var data = GameData.get_data(GameData.data_path)
	var player = data.players[int(id)]
	player.Active[0] = true
	get_node("Button/active").hide()
	player_btn_no()
	
	var playerData = data.players
	var account = GameData.get_data(GameData.account_data_path)
	var file_data:FileData = FileData.new()
	var addPlayer = file_data.players[int(id)]
	addPlayer.PlayerID = playerData.size()
	addPlayer.Active[0] = true
	addPlayer.Team[0] = "NON"
	addPlayer.Team[1] = "NON"
	
	account.playerSlot.append(addPlayer.PlayerID)
	account.playerBuy.append(addPlayer.PlayerID)
	
	playerData.append(addPlayer)
	
	GameData.save_data(GameData.data_path,data)
	GameData.save_data(GameData.account_data_path,account)
	
	on_button_close_pressed()

func on_button_close_pressed() -> void:
	menu.get_node("PlayerCard").hide()
	menu.get_node("PlayerCard").btnBuy.disconnect("pressed", Callable(self, "on_button_buy_pressed"))
	menu.get_node("PlayerCard").btnClose.disconnect("pressed", Callable(self, "on_button_close_pressed"))

func _exit_tree():
	queue_free()
