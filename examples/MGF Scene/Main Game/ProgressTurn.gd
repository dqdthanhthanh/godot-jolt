extends ProgressBar

@export var gradient:Gradient

@onready var menu:Node3D = get_parent().get_parent().get_parent()
@onready var UI = get_parent().get_parent()
var isStart:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_turn()

func new_turn() -> void:
	value = 100

func start_time() -> void:
	isStart = true
	new_turn()

func count_down() -> void:
	pass
#	value -= 0.6/Engine.time_scale

func when_time_is_up():
	return value <= 0

func check_turn():
	if value >= 0:
		return true
	else:
		return false

func _on_Timer_timeout() -> void:
	if (menu.isGameTime != 3 and 
	get_tree().paused == false and 
	menu.isPlayReplay == false and
	isStart == true):
		count_down()
		if when_time_is_up():
			isStart = false
			menu.isStartTurn = false
			if menu.teamSelect == 1:
				menu.teamAFoul += 1
			else:
				menu.teamBFoul += 1
			menu.power = 0
			menu._on_TimerNewTurn_timeout()

# warning-ignore:unused_argument
func _on_ProgressTurn_value_changed(value):
	get_theme_stylebox("fill").bg_color = gradient.sample(ratio)
