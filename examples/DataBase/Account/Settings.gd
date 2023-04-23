extends Control

@onready var btnClearData: = $VBoxContainer/BtnClearData



func _ready() -> void:
	GameData.load_game_settings()
	set_up()

func create_data() -> void:
	GameData.load_game_settings()

func _on_BtnClearData_pressed() -> void:
	Notification.push_noti(1,'Clear all "game data" ?')
	if !Notification.btnYes.is_connected("pressed", Callable(self, "clear_all_data")):
		Notification.btnYes.connect("pressed", Callable(self, "clear_all_data"))

func clear_all_data() -> void:
	GameData.data_clear_all(GameData.user_path)
	await get_tree().create_timer(0.1).timeout
	SceneTransition.change_scene_to_file("res://MGF Scene/MainMenu.tscn")
	
	Notification.push_noti(0,'Clear data Done !!!')
	Notification.btnYes.disconnect("pressed", Callable(self, "clear_all_data"))

func _on_BtnVolume_drag_ended(value_changed) -> void:
	var value = $VBoxContainer/Volume/BtnVolume.value
	GameData.sound_set("Master",value)
	save_sound_data(0,value)

func _on_BtnMusic_drag_ended(value_changed) -> void:
	var value = $VBoxContainer/Music/BtnMusic.value
	GameData.sound_set("Music",value)
	save_sound_data(1,value)

func _on_BtnSound_drag_ended(value_changed) -> void:
	var value = $VBoxContainer/Sound/BtnSound.value
	GameData.sound_set("Sound",value)
	save_sound_data(2,value)

func _on_BtnMatch_drag_ended(value_changed) -> void:
	var value = $VBoxContainer/MatchSFX/BtnMatch.value
	GameData.sound_set("GameSFX",value)
	save_sound_data(3,value)

func _on_BtnMatchVoice_drag_ended(value_changed) -> void:
	var value = $VBoxContainer/MatchVoice/BtnMatchVoice.value
	GameData.sound_set("MatchVoice",value)
	save_sound_data(4,value)

func save_sound_data(sound,value) -> void:
	var data = GameData.get_data(GameData.setting_data_path)
	data.sound[sound] = value
	GameData.save_data(GameData.setting_data_path,data)

func set_up() -> void:
	var data = GameData.get_data(GameData.setting_data_path)
	var sound = data.sound
	$VBoxContainer/Volume/BtnVolume.value = sound[0]
	$VBoxContainer/Music/BtnMusic.value = sound[1]
	$VBoxContainer/Sound/BtnSound.value = sound[2]
	$VBoxContainer/MatchSFX/BtnMatch.value = sound[3]
	$VBoxContainer/MatchVoice/BtnMatchVoice.value = sound[4]
