extends AudioStreamPlayer

var files:Array = []
var file:Dictionary
var auto:bool = true

@onready var timer: = $Timer
@onready var sound: = $SfxrClick
var UI
var slider
var BtnPlayMusic

func _ready() -> void:
	UI = Account.UIMusic
	slider = Account.slider
	BtnPlayMusic = Account.BtnPlayMusic
	volume_normal()
	load_random_music()
	BtnPlayMusic.connect("pressed", Callable(self, "load_random_music"))
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func load_random_music() -> void:
	files = []
	var data = GameData.get_data(GameData.item_data_path)
	for i in data.musics.size():
		if data.musics[i].active == true:
			files.append(data.musics[i])
	file = Calculate.random_in_size(files)
	UI.text = file.label
	stream = load(file.file)
	play()

func play_mucis(_file) -> void:
	UI.text = _file.label
	stream = load(_file.file)
	play()

func play_next_mucis(type:bool = true) -> void:
	var data = GameData.get_data(GameData.item_data_path)
	var size = data.musics.size()-1
	var id = file.id
	var newId = id
	if type == true:
		if id == size:
			newId = 0
		else:
			newId += 1
	else:
		if id == 0:
			newId = size
		else:
			newId -= 1
	var nextMusic = data.musics[newId]
	file = nextMusic
	UI.text = nextMusic.label
	stream = load(nextMusic.file)
	play()

func play_time(time:float,value:bool = true) -> void:
	auto = value
	play()
	seek(time)

func volume_low() -> void:
	if OS.get_name() == "iOS":
		volume_db = -30
	else:
		volume_db = -20

func volume_normal() -> void:
	if OS.get_name() == "iOS":
		volume_db = -20
	else:
		volume_db = -10

func set_volume(value) -> void:
	if value == true:
		volume_normal()
	else:
		volume_low()

func _on_SoundBg_finished() -> void:
	if auto == true:
		load_random_music()

static func get_file_name(text:String) -> String:
	text = text.replace("res://Sounds/Music//", "").replace(".mp3", "")
	return text

func _on_Timer_timeout() -> void:
	var length = stream.get_length()
	var currTime = get_playback_position()
	slider.value = (currTime/length)*100

func play_other_music() -> void:
	if file.active == false:
		load_random_music()
