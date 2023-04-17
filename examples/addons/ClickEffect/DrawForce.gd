extends Node2D

@onready var _lines:= $Lines
@onready var _linesAI:= $LinesAI
@onready var _lineForce:= preload("res://addons/ClickEffect/LineForce.tres")

var _click_pos:Array = []

var p0:Vector2 = Vector2.ZERO
var p1:Vector2 = Vector2.ZERO

var size:int = 20
var _pressed:bool = false
var _current_line: Line2D

@export var checkAI:bool = false

func _ready():
	_lines.modulate = Color(1,1,1,0)

func _input(event: InputEvent):
	if checkAI == false:
		size = 20
	#	if event is InputEventSingleScreenTap:
	#		draw_line_force(event.position,Vector2(0,0),100)
		if event is InputEventScreenTouch:
			_pressed = event.pressed
			if _pressed:
				_current_line = Line2D.new()
				_current_line.joint_mode = 2
				_current_line.begin_cap_mode = 2
				_current_line.end_cap_mode = 2
				_current_line.default_color = Color(1,1,1,1)
				_current_line.width_curve = _lineForce
				_current_line.width = size
				_current_line.round_precision = 256
				_lines.add_child(_current_line)
		if event is InputEventSingleScreenSwipe:
			size = event.relative.length()/20
			size = clamp(size,20,30)
			_current_line.width = size
		if event is InputEventMouseMotion && _pressed:
			_current_line.add_point(event.position)
			GlobalTween.fade_out(_lines,0.5)
			for i in _lines.get_child_count()-1:
				_lines.get_child(i).queue_free()

func draw_line_force(p0,p1,power,time):
	if checkAI == true:
		size = 20
		_current_line = Line2D.new()
		_current_line.joint_mode = 2
		_current_line.begin_cap_mode = 2
		_current_line.end_cap_mode = 2
		_current_line.default_color = Color(1,1,1,0.5)
		_current_line.width_curve = _lineForce
		_current_line.width = power/2.5
		size = clamp(size,20,30)
		_current_line.round_precision = 256
		_linesAI.add_child(_current_line)
		_current_line.add_point(p0)
		_current_line.add_point(p1)
		GlobalTween.fade_out(_linesAI,time)
		for i in _linesAI.get_child_count()-1:
			_linesAI.get_child(i).queue_free()

#func _draw():
#	for i in _click_pos:
#		draw_circle(i,20,Color.AQUA)
#	await get_tree().create_timer(0.3).timeout
#	_click_pos = []
##	draw_line(p0,p0+p1,Color.AQUA,20)
##	draw_circle(p0+p1,20,Color.AQUA)
##	draw_circle(p0,20,Color.AQUA)
#
#
#func _input(event):
##	if event is InputEventSingleScreenSwipe:
##		p0 = event.position
##		p1 = event.relative
##		update()
#	if not event is InputEventSingleScreenDrag:
#		return
#	_click_pos.append(event.position)
#	update()
