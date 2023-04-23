extends Popup


@onready var voicebox: = $ACVoicebox
@onready var current_label:Label = $Demo/Info/Label
@onready var info_label:Label = $Main/BtnInfo/Info
@onready var demo: = $Demo
@onready var video:VideoStreamPlayer = $Demo/VideoStreamPlayer
@onready var checkGroup: = $Main/BtnInfo/Panel/Check

var index:int = -1
var data:Array = Global.GuideData

var videoPos:float
var videoTime:float

var camGuide:Dictionary = {
	"label":"CAMERA VIEW",
	"info":"CONTROL Camera3D View by DRAG or PINCH with 2 fingers to ZOOM and POSITION",
	"pc":"CONTROL Camera3D View by scroll wheel to ZOOM, hold midle and drag to POSITION",
	"file":"cam_pc.ogv","length":5}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.isGuide == true:
		$Main.hide()
		show()
		get_tree().paused = true
		Notification.btnYes.connect("pressed", Callable(self, "start_guide"))
		await get_tree().create_timer(2.0).timeout
		SceneTransition.transition()
		Notification.push_noti(2,"Welcome to the basic control tutorial!")

func replay_guide(id:int = -1) -> void:
	for i in data[index].check[0]:
		checkGroup.get_child(i).get_node("icon").hide()
	if id < 0:
		for i in data.size():
			data[i].check[0] = 0
	else:
		data[id].check[0] = 0

func start_guide() -> void:
	SceneTransition.transition()
	Notification.btnYes.disconnect("pressed", Callable(self, "start_guide"))
	await get_tree().create_timer(1.5).timeout
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))
	
	
	Calculate.remove_children(checkGroup)
	demo_visible(true)
	var test = camGuide
	var timeT:String
	var text:String
	
	video.stream = video_path(test.file)
	video.play()
	
	text = ""
	if Global.device_is_mobile():
		voice(text + test.label + "\n" + test.info)
	else:
		voice(text + test.label + "\n" + test.pc)

	$Main.show()

func video_path(path):
	return load("res://Demo/guide/pc/" + path)

func play_guide(id) -> void:
	SceneTransition.transition()
	var test = data[id]
	var timeT:String
	var text:String
	
	video.stream = video_path(test.file)
	video.play()
	
	if index < test.size():
		text = "Let's "
	else:
		text = "Finally, let's "
	
	if Global.device_is_mobile():
		voice(text + test.label + "!" + "\n" + test.info)
	else:
		voice(text + test.label + "!" + "\n" + test.pc)
	
	if test.check[1] < 2:
		timeT = " time"
	else:
		timeT = " times"
	info_label.text = "" + test.label + " (" + str(test.check[1]) + timeT + ")"

func _on_voicebox_characters_sounded(characters: String) -> void:
	current_label.text += characters

func voice(text) -> void:
	voicebox.stop()
	current_label.text = ""
	voicebox.play_string(text,0.25,10)

func demo_visible(value) -> void:
	demo.visible = value
	get_tree().paused = value
	SoundGlobal.set_volume(false)

func _on_BtnSkip_pressed() -> void:
	await get_tree().create_timer(0).timeout
	SceneTransition.transition()
	if index >= 0:
		for i in data[index].check[0]:
			checkGroup.get_child(i).get_node("icon").show()
		voicebox.stop()
		current_label.text = ""
		video.stop()
		video.stream = null
		demo_visible(false)
	else:
		index = 0
		_on_BtnInfo_pressed()

func _on_BtnInfo_pressed() -> void:
	await get_tree().create_timer(0).timeout
	SceneTransition.transition()
	Calculate.remove_children(checkGroup)
	
	var size = data[index].check[1]
	for i in size:
		var ins = load("res://MGF Scene/Main Game/check.tscn").instantiate()
		checkGroup.add_child(ins)
	
	demo_visible(true)
	play_guide(index)

func _on_BtnAdd_pressed() -> void:
	var count = data[index].check[0]
	var size = data[index].check[1]
	if count < size:
		data[index].check[0] += 1
		for i in data[index].check[0]:
			checkGroup.get_child(i).get_node("icon").show()
		if data[index].check[0] == size:
			await get_tree().create_timer(2.0).timeout
			_on_BtnNextGuide_pressed()

func check_guide(id) -> void:
	if id == index:
		prints("Guide",id)
		await get_tree().create_timer(1.0).timeout
		_on_BtnAdd_pressed()

func _on_BtnNextGuide_pressed() -> void:
	await get_tree().create_timer(1).timeout
	SceneTransition.transition()
	# Play next guide
	if index < data.size()-1:
		Notification.push_noti(0,"Done.")
		await get_tree().create_timer(3).timeout
		index += 1
		Global.GuideIndex += 1
		_on_BtnInfo_pressed()
	else:
		quit_guide()

func _on_VideoPlayer_finished() -> void:
	if demo.visible == true and video.stream != null:
		video.play()


func _on_BtnQuit_pressed() -> void:
	await get_tree().create_timer(0).timeout
	SceneTransition.transition()
	Notification.btnYes.connect("pressed", Callable(self, "quit_guide"))
	Notification.push_noti(1,"Quit basic control tutorial ?" + "\n" + "Then play a FullMatch!")

func quit_guide() -> void:
	if Notification.btnYes.is_connected("pressed", Callable(self, "quit_guide")):
		Notification.btnYes.disconnect("pressed", Callable(self, "quit_guide"))
	var gameData = GameData.get_data(GameData.setting_data_path)
	gameData.Guide = true
	GameData.save_data(GameData.setting_data_path,gameData)
	
	Notification.push_noti(0,"Complete!")
	await get_tree().create_timer(3).timeout
	Notification.push_noti(0,"Let's play a FullMatch!")
	await get_tree().create_timer(3).timeout
	Global.gameModeCur = 1
	Global.MatchPlay = 1
	Global.isGuide = false
	SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")

func _on_Timer_timeout() -> void:
	var length:float
	if index < 0:
		length = camGuide.length
	else:
		length = data[index].length
	videoPos = remap(video.stream_position,0,length,0,100)
	videoPos = clamp(videoPos,0,100)
	$Demo/Info/BtnVideoSlider.value = videoPos

func _exit_tree():
	queue_free()
