extends RefCounted
class_name SampledAxis

var values: Array
var min_max: Pair

func _init(values: Array = [],min_max: Pair = Pair.new()):
	self.values = values
	self.min_max = min_max

func _to_string() -> String:
	return "values: %s\nmin: %s, max: %s" % [self.values, self.min_max.left, self.min_max.right]

