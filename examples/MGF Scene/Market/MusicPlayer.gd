extends Panel

@onready var btnPlay: = $PanelMain/HBoxContainer/BtnReplayPlay
var btnPlay_pressed:bool = true

@onready var slider: = $PanelMain/BtnVideoReplaySlider
var temp:float

@onready var playIcon: = preload("res://Assets2D/UI/iconPlay.png")
@onready var stopIcon: = preload("res://Assets2D/UI/IconMovePlay.png")

func _ready() -> void:
	_on_Timer_timeout()

func _on_Timer_timeout() -> void:
	$PanelMain/Label.text = SoundGlobal.UI.text
	var length = SoundGlobal.stream.get_length()
	var currTime = SoundGlobal.get_playback_position()
	slider.value = (currTime/length)*100

func _on_BtnReplayPlay_pressed() -> void:
	if btnPlay_pressed == false:
		btnPlay.tooltip_text = "Stop"
		SoundGlobal.play_time(temp,true)
		btnPlay.icon = playIcon
		btnPlay_pressed = true
	else:
		btnPlay.tooltip_text = "Play"
		temp = SoundGlobal.get_playback_position()
		SoundGlobal.auto = false
		SoundGlobal.stop()
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func _on_BtnVideoReplaySlider_value_changed(value) -> void:
	var length = SoundGlobal.stream.get_length()
	temp = SoundGlobal.get_playback_position()
	if SoundGlobal.auto == true:
		SoundGlobal.play_time((value*length)/100,true)

func _on_ButtonNextLeft_pressed() -> void:
	SoundGlobal.play_next_mucis(false)

func _on_ButtonNextRight_pressed() -> void:
	SoundGlobal.play_next_mucis(true)

func _exit_tree():
	queue_free()
