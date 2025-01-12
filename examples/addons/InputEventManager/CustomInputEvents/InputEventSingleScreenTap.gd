class_name InputEventSingleScreenTap
extends InputEventAction

var position   : Vector2
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null):
	raw_gesture = _raw_gesture
	if raw_gesture:
		position = raw_gesture.presses.values()[0].position


func as_text() -> String:
	return "position=" + str(position)
