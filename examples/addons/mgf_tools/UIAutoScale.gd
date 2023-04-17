@tool
extends VBoxContainer

@export var debug:bool = false
@export var _size:int = 0
@export var separation:int = 0

func _run():
	item_auto_scale()

# warning-ignore:unused_argument
func _process(delta):
	if Engine.is_editor_hint():
#		size = size.y
		item_auto_scale()
	if not Engine.is_editor_hint():
		pass

func item_auto_scale():
	if debug == false:
		_size = 680
		separation = 10
	set("theme_override_constants/separation",0)
	if get_child_count() > 0:
		if separation*get_child_count() > _size or separation<0:
			separation = 0
		for unit in get_children():
			unit.custom_minimum_size.y = _size/(get_child_count())-(separation) + (separation/(get_child_count()))
			unit.size.y = unit.custom_minimum_size.y
			unit.custom_minimum_size.x = 0
#			get_child(get_child_count()-1).custom_minimum_size.y = size/(get_child_count())
#			get_child(get_child_count()-1).size.y = unit.custom_minimum_size.y
	set("theme_override_constants/separation",separation)
