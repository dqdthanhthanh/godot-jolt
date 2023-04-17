extends Control

@onready var replayTime = $PanelMain/BtnVideoReplaySlider
@onready var btnPlay = $PanelMain/HBoxContainer/BtnReplayPlay
@onready var btnClose = $PanelMain/HBoxContainer/BtnReplayClose
@onready var btnNextRight = $PanelMain/HBoxContainer/ButtonNextRight
@onready var btnNextLeft = $PanelMain/HBoxContainer/ButtonNextLeft
@onready var btnTimeLine = $PanelMain/BtnVideoReplaySlider
var btnPlay_pressed:bool = true
@onready var goalTime = preload("res://MGF Scene/Main Game/BtnGoalTime.tscn")
@onready var playIcon = preload("res://Assets2D/UI/iconPlay.png")
@onready var stopIcon = preload("res://Assets2D/UI/IconMovePlay.png")

@onready var iconLoad = $PanelMain/BtnOpen/Label

@onready var main = $PanelMain
@onready var btnOpen = $PanelMain/BtnOpen
@onready var tween = $Tween

var posOpen:int = 695
var posClose:int = 832
var inputCheck:bool = true
var inputCount:int = 0

func _ready():
#	iconLoad.pivot_offset = iconLoad.custom_minimum_size/2
	btnOpen.show()

func _process(delta):
	if visible == true:
		iconLoad.rotation += 1*delta

# warning-ignore:unused_argument
func _input(event):
	if visible == true:
		if event is InputEventScreenTouch:
			ui_show()

func _on_Timer_timeout():
	if visible == true:
		$Timer.wait_time = Engine.time_scale
		inputCount += 1
		if inputCount == 3 and main.position.y < 880:
			ui_hide()

func ui_show():
	inputCount = 0
#	btnOpen.hide()
	GlobalTween.pos_UI(main,Vector2(8,posOpen),Engine.time_scale/5)

func ui_hide():
	GlobalTween.pos_UI(main,Vector2(8,posClose),Engine.time_scale/5)
#	btnOpen.show()


func _on_BtnReplayPlay_pressed():
	if btnPlay_pressed == false:
		btnPlay.icon = playIcon
		btnPlay_pressed = true
	else:
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func set_up():
	show()
	ui_show()
	btnPlay.icon = playIcon
	btnPlay_pressed = true

func _on_ButtonNextRight_pressed():
	if replayTime.value < 100:
		replayTime.value += 0.1
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func _on_ButtonNextLeft_pressed():
	if replayTime.value > 0:
		replayTime.value -= 0.1
		btnPlay.icon = stopIcon
		btnPlay_pressed = false
