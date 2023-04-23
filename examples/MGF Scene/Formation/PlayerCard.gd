extends Control


@onready var btnBuy: = $Main/ButtonBuy
@onready var btnClose: = $Main/ButtonClose
@onready var voicebox: = $ACVoicebox
@onready var current_label: = $Main/BtnVoice/Label
@onready var RadarChartStats: = $Main/RadarChartStats

var PlayerID:int
var ID:int
var maxSize:float = 1792

func _ready() -> void:
	$TabContainer.show()
	$Main.show()
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))
	btnBuy.hide()
	hide()

func fix_size() -> void:
	if (Global.MGFMode == Global.Season
	or Global.MGFMode == Global.SeasonMatch):
		if FormationData.CanFormation == false:
			var currSize = maxSize*55/100
			var posX = (maxSize-currSize)/2
			size.x = currSize
			position.x = posX
			RadarChartStats.scale = Vector2(2,2)
			RadarChartStats.position = Vector2(currSize/1.75,currSize/2.2)

func create_art(id) -> void:
	if FormationData.CanFormation == false:
		$BG.hide()
		$PanelN.show()
#	fix_size()
	current_label.text = ""
	PlayerID = int(id)
	
	if $TabContainer.get_child_count()>0:
		for unit in $TabContainer.get_children():
			unit.queue_free()
	
	var data = GameData.formation_load_data()
	var playerData = data.players[int(id)]
	ID = playerData.ID
	
	btnBuy.text = str(playerData.Price[1])
	var star = $Main/Popular
	star.value = int(playerData.Price[0])*10
	
	$Main/Name.text = playerData.Name
	
	var stats = $StatsVBoxContainer
	var statsValue = $ValueVBoxContainer
	var statsMax = $MaxVBoxContainer
	stats.get_child(0).value = playerData.Overall[0]
	statsValue.get_child(0).text = str(playerData.Overall[0])
	statsMax.get_child(0).text = str(playerData.Max[0])
	statsMax.get_child(1).text = str(playerData.Max[1])
	statsMax.get_child(2).text = str(round((playerData.Max[1]+playerData.Max[2])/2))
	statsMax.get_child(3).text = str(round((playerData.Max[0]+playerData.Max[1])/2))
	statsMax.get_child(4).text = str(playerData.Max[2])
	statsMax.get_child(5).text = str(playerData.Max[2])
	statsMax.get_child(6).text = str(playerData.Max[0])
	statsMax.get_child(7).text = str(playerData.Max[3])
	statsMax.get_child(8).text = str(playerData.Max[3])
	statsMax.get_child(9).text = str(playerData.Max[3])
	statsMax.get_child(10).text = str(playerData.Max[3])
	statsMax.get_child(11).text = str(playerData.Max[4])
	statsMax.get_child(12).text = str(playerData.Max[4])
	
	show()
	
	for i in stats.get_child_count():
		if i > 0:
			stats.get_child(i).value = int(playerData.Stat[i-1])
			statsValue.get_child(i).text = str(stats.get_child(i).value)
		Calculate.stat_color(statsValue.get_child(i))
		Calculate.stat_color(statsMax.get_child(i))
	
	for i in playerData.Art.size():
		if i > 0:
			var ins = load("res://MGF Scene/Formation/ArtTabs.tscn").instantiate()
			$TabContainer.add_child(ins)
			await get_tree().create_timer(0).timeout
			ins.name = "Art " + str(i)
	$TabContainer.current_tab = playerData.Art[0]
	GameData.return_radarStats_player(RadarChartStats,id)

func _on_TabContainer_tab_selected(tab) -> void:
	await get_tree().create_timer(Global.btntime).timeout
	$TextureRect.texture = null
	var data:FileData = FileData.new()
	var item = GameData.get_data(GameData.item_data_path)
	var playerData = data.players[ID]
	var card = item.cards[int(playerData.Art[tab+1])]
	if card.active == true:
		if FormationData.CanFormation == true and FormationData.isSub == true:
			get_parent().PlayerInfo.get_node("Panel/Texture2D").texture = Player.load_high_image(card.file)
			var MainGame = get_parent().get_parent().get_parent()
			for unit in MainGame.units:
				if unit.playerID == PlayerID:
					unit.set_skin(card.file)
		$Active.hide()
	else:
		$Active.show()
	
	if playerData.Available == true:
		$TextureRect.texture = Player.load_high_image(card.file)
	else:
		$TextureRect.texture = Player.load_high_image(playerData.Icon)

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	if get_parent().name == "Formation":
		var tab = $TabContainer.current_tab
		var data = GameData.formation_load_data()
		var item = GameData.get_data(GameData.item_data_path)
		var playerData = data.players[get_parent().id]
		var card = item.cards[int(playerData.Art[tab+1])]
		if card.active == true and playerData.Available == true:
			var newCard = item.cards[int(playerData.Art[$TabContainer.current_tab+1])].file
			playerData.Art[0] = $TabContainer.current_tab
			if playerData.Icon != newCard:
				playerData.Icon = newCard
				GameData.formation_save_data(data)
				get_parent().player_set_skin()
		get_parent()._on_PlayerInfo_pressed()
	await get_tree().create_timer(Global.btntime).timeout
	hide()

func _on_BtnVoice_pressed() -> void:
	await get_tree().create_timer(Global.btntime).timeout
	voicebox.stop()
	current_label.text = ""
	var data = GameData.formation_load_data()
	var playData = data.players[PlayerID]
	var voiceType = playData.Voice[0]
	voicebox.play_string(playData.Name,voiceType)

func _on_voicebox_characters_sounded(characters: String) -> void:
	current_label.text += characters

func _exit_tree():
	queue_free()
