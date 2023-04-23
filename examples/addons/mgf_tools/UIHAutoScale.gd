@tool
extends HBoxContainer

@export var debug:bool = false
@export var _size:int = 0
@export var _separation:int = 0

func _run() -> void:
	item_auto_scale()

# warning-ignore:unused_argument
func _process(delta) -> void:
	if Engine.is_editor_hint():
		item_auto_scale()
	if not Engine.is_editor_hint():
		pass

func item_auto_scale() -> void:
	if debug == false:
		_size = 680
		_separation = 10
	set("theme_override_constants/separation",0)
	if get_child_count() > 0:
		if _separation*get_child_count() > _size or _separation<0:
			_separation = 0
		for unit in get_children():
			unit.custom_minimum_size.x = _size/(get_child_count())-(_separation) + (_separation/(get_child_count()))
			unit.size.x = unit.custom_minimum_size.x
			unit.custom_minimum_size.y = 0
#			get_child(get_child_count()-1).rect_min_size.y = size/(get_child_count())
#			get_child(get_child_count()-1).rect_size.y = unit.rect_min_size.y
	set("theme_override_constants/separation",_separation)
