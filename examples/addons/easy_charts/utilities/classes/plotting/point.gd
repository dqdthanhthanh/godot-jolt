@tool
extends RefCounted
class_name Point

enum Shape3D {
	CIRCLE,
	TRIANGLE,
	SQUARE,
	CROSS
}

var position: Vector2
var value: Pair

func _init(position: Vector2,value: Pair = Pair.new()):
	self.value = value
	self.position = position

func _to_string() -> String:
	return "Value: %s\nPosition: %s" % [self.value, self.position]
