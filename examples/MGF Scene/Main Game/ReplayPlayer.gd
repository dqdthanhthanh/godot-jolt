extends Control

@onready var btnTimeLine: = $PanelMain/BtnVideoReplaySlider
@onready var btnPlay: = $PanelMain/HBoxContainer/BtnReplayPlay
@onready var btnClose: = $PanelMain/HBoxContainer/BtnReplayClose
@onready var btnSave: = $PanelMain/HBoxContainer/BtnReplaySave
@onready var btnNextRight: = $PanelMain/HBoxContainer/ButtonNextRight
@onready var btnNextLeft: = $PanelMain/HBoxContainer/ButtonNextLeft

var btnPlay_pressed:bool = true
@onready var playIcon: = preload("res://Assets2D/UI/IconMovePlay.png")
@onready var stopIcon: = preload("res://Assets2D/UI/iconPlay.png")

@onready var shader_goalN: = preload("res://Assets2D/Theme/btnUICNReplay.tres")
@onready var shader_goalP: = preload("res://Assets2D/Theme/btnUICPReplay.tres")

@onready var UI: = get_parent()
@onready var MainGame: = get_parent().get_parent()
@onready var main: = $PanelMain
@onready var btnOpen: = $PanelMain/BtnOpen
@onready var iconLoad: = $PanelMain/BtnOpen/Label
@onready var tween: = $Tween

var posOpen:int = 695
var posClose:int = 832
var inputCheck:bool = true
var inputCount:int = 0

## Replay
var isSaveReplay:bool = true
var isPlayReplay:bool = false
var timePlayReplay:int
var teamPlayReplay:int
var replayCount:int = 0
var replayTurns:int = 0

func _ready() -> void:
	hide()
	btnSave.hide()
	btnOpen.show()

func _process(delta) -> void:
	if visible == true:
		iconLoad.rotation += 0.1

# warning-ignore:unused_argument
func _input(event):
	if visible == true:
		if event is InputEventScreenTouch:
			ui_show()

func _on_Timer_timeout() -> void:
	if visible == true:
		$Timer.wait_time = Engine.time_scale
		inputCount += 1
		if inputCount == 3 and main.position.y < 880:
			ui_hide()

func ui_show() -> void:
	inputCount = 0
	GlobalTween.pos_UI(main,Vector2(8,posOpen),Engine.time_scale/5)

func ui_hide() -> void:
	GlobalTween.pos_UI(main,Vector2(8,posClose),Engine.time_scale/5)

func _on_BtnReplayPlay_pressed() -> void:
	if btnPlay_pressed == false:
		btnPlay.icon = playIcon
		btnPlay_pressed = true
	else:
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func set_up(data,size) -> void:
	show()
	ui_show()
	btnPlay.icon = playIcon
	btnPlay_pressed = true
	var goals = $PanelMain/goals
	if goals.get_child_count()>0:
		for i in goals.get_children():
			i.queue_free()
#	print(data,size)
	for i in data.size():
		var goalData = data[i]
		var ins = load("res://MGF Scene/Main Game/BtnGoalTime.tscn").instantiate()
		goals.add_child(ins)
		
		ins.get_node("Label").text = str(goalData[1]) + "'"
		ins.icon = Player.load_icon(goalData[2].playerData.Icon)
		
		if goalData[2].team == 1:
			shader_goalN.bg_color = UI.teamAMat
			shader_goalP.bg_color = UI.teamAMat*1.5
		else:
			shader_goalN.bg_color = UI.teamBMat
			shader_goalP.bg_color = UI.teamBMat*1.5
		var goalN = shader_goalN.duplicate()
		var goalP = shader_goalP.duplicate()
		ins.set("theme_override_styles/normal",goalN.duplicate())
		ins.set("theme_override_styles/hover",goalP.duplicate())
		ins.set("theme_override_styles/pressed",goalP.duplicate())
		ins.set("theme_override_styles/focus",goalP.duplicate())
		
		var Min = btnTimeLine.position.x
		var Max = btnTimeLine.size.x + Min/2
		
		ins.position.x = remap(goalData[0],0,size,Min,Max)
		ins.position.x = clamp(ins.position.x,Min,Max)
		ins.position.y = 24
		
		var timeGoalValue:float
		if goalData[0] > 50:
			timeGoalValue = remap(goalData[0]-50,0,size,0,100)
		else:
			timeGoalValue = 0
		timeGoalValue = clamp(timeGoalValue,0,100)
		ins.connect("pressed", Callable(self, "next_goal").bind(timeGoalValue,MainGame.timeGoals[i][1]))

func next_goal(time,goalTime) -> void:
	btnSave.text = str(goalTime) + "'"
	btnTimeLine.value = time
	btnPlay.icon = playIcon
	btnPlay_pressed = true

func _on_ButtonNextRight_pressed() -> void:
	if btnTimeLine.value < 100:
		btnTimeLine.value += 0.1
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func _on_ButtonNextLeft_pressed() -> void:
	if btnTimeLine.value > 0:
		btnTimeLine.value -= 0.1
		btnPlay.icon = stopIcon
		btnPlay_pressed = false

func play_quick_replay() -> void:
	var frameMax = MainGame.Ball.replay_data.pos.size()*1.0
	var frame = 0
	var ratio = 0
	if frameMax >= 300:
		frame = frameMax - 300
	ratio = frame/frameMax*100.0
	if MainGame.timeGoals.size()>0:
		btnSave.hide()
		btnSave.text = str(MainGame.timeGoals[MainGame.timeGoals.size()-1][1]) + "'"
	else:
		btnSave.hide()
	play_replay(ratio)

func play_replay(value) -> void:
	SceneTransition.transition()
	UI.ui_visible(false)
	if MainGame.time != MainGame.gameRound or MainGame.time != MainGame.gameRound-1:
		UI._on_BtnCamMode_pressed()
		SoundGlobal.UI.hide()
		SoundGlobal.volume_normal()
		if isPlayReplay == false:
			set_up(MainGame.timeGoals,MainGame.Ball.replay_data.pos.size())
			timePlayReplay = MainGame.time
			teamPlayReplay = MainGame.teamSelect
			replayTurns = UI.newTurn.value
			
			replayCount = conver_frame_value(value)
			
			isPlayReplay = true
			show()
			
			MainGame.Ball.baseTransform = MainGame.Ball.transform
			MainGame.units = get_tree().get_nodes_in_group("units")
			for unit in MainGame.units:
				unit.baseTransform = unit.transform
			for unit in MainGame.units:
				MainGame.selected_units.clear()
				unit.deselect()

func _on_TimerPlayReplay_timeout() -> void:
	if btnPlay_pressed == true:
		if isPlayReplay == true:
			MainGame.player_col_active(false)
			var posData = MainGame.Ball.replay_data
			var size = posData.pos.size()-1
			btnTimeLine.value += 100.0/size
			if MainGame.isGameTime == 3:
				if btnTimeLine.value == 100:
					conver_frame_value(0)

func replay_stop() -> void:
	UI.ui_visible(true)
	SoundGlobal.UI.show()
	SoundGlobal.volume_low()
	isPlayReplay = false
	replayCount = 0
	MainGame.Ball.transform = MainGame.Ball.baseTransform
	for unit in MainGame.units:
		unit.transform = unit.baseTransform
	MainGame.player_col_active(true)
	isSaveReplay = true
	btnTimeLine.value = 0
	hide()
	MainGame.change_state(MainGame.SET_PLAYER)
#	time -= 1
	if teamPlayReplay == 1:
		MainGame.teamSelect = 1
	else:
		MainGame.teamSelect = 2
	MainGame._on_TimerAllStop_timeout()
	UI.newTurn.value = replayTurns

func _on_TimerSaveReplay_timeout() -> void:
	if isSaveReplay == true and MainGame.isGameTime != 3:
		MainGame.Ball.replay_data.pos.append(MainGame.Ball.position)
		MainGame.Ball.replay_data.rot.append(MainGame.Ball.rotation_degrees.y)
		MainGame.units = get_tree().get_nodes_in_group("units")
		for unit in MainGame.units:
			unit.replay_data.id = unit.playerID
			unit.replay_data.pos.append(unit.position)
			unit.replay_data.rot.append(unit.rotation_degrees.y)

func replay_is_save(value) -> void:
	if isPlayReplay == true or get_tree().paused == true or MainGame.isGameTime == 3:
		isSaveReplay = false
	else:
		isSaveReplay = value

# warning-ignore:unused_argument
func _on_BtnVideoReplaySlider_value_changed(value_changed) -> void:
	if isPlayReplay == true:
		replayCount = conver_frame_value(btnTimeLine.value)
		MainGame.player_col_active(false)
		var posData = MainGame.Ball.replay_data
		var size = posData.pos.size()-1
		MainGame.Ball.position = posData.pos[replayCount]
		MainGame.Ball.rotation_degrees.y = posData.rot[replayCount]
		MainGame.units = get_tree().get_nodes_in_group("units")
		for unit in MainGame.units:
			var pdata = unit.replay_data
			if replayCount < pdata.pos.size()-1:
				unit.position = pdata.pos[replayCount]
				unit.rotation_degrees.y = pdata.rot[replayCount]
	if value_changed == 100 and MainGame.isGameTime != 3:
		replay_stop()

func conver_frame_value(value) -> int:
	btnTimeLine.value = value
	var replayData = MainGame.Ball.replay_data
	var size = replayData.pos.size()-1
	var fix:int = round(remap(value,0,100,0,size))
	fix = clamp(fix,0,size)
	return fix

func _on_BtnReplayClose_pressed() -> void:
	btnPlay_pressed = true
	replay_stop()

func _on_BtnReplaySave_pressed() -> void:
	var path:String
	var fileName:String
	var files = GameData.list_files("user://save/replay/")
	print(files.size())
	
	if files.size() <10:
		fileName = "000" + str(files.size())
	elif files.size() <100:
		fileName = "00" + str(files.size())
	elif files.size() <1000:
		fileName = "0" + str(files.size())
	elif files.size() >999:
		fileName = str(files.size())
	path = "user://save/replay/" + fileName + ".json"
	
	replay.info = []
	replay.players = []
	replay.data = []
	replay.ball = []
	
	for unit in MainGame.units:
		replay.players.append(unit.playerData)
		replay.data.append(unit.replay_data)
	replay.ball.append(MainGame.Ball.replay_data)
	GameData.save_data(path,replay)

var replay:Dictionary = {
	"label": "QD 2 - 0 QV",
	"icon": "",
	"info": ["time","size","GoalPlayer","goaltime"],
	"players": [],
	"data": [],
	"ball": [],
}

func _exit_tree():
	queue_free()
