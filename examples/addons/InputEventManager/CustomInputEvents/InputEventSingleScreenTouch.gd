class_name InputEventSingleScreenTouch
extends InputEventAction

var position   : Vector2
var canceled  : bool
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null):
	raw_gesture = _raw_gesture
	if raw_gesture:
		pressed = raw_gesture.releases.is_empty()
		if pressed:
			position = raw_gesture.presses.values()[0].position
		else:
			position = raw_gesture.releases.values()[0].position
		canceled = raw_gesture.size() > 1

func as_text() -> String:
	return "position=" + str(position) + "|pressed=" + str(pressed) + "|canceled=" + str(canceled)
