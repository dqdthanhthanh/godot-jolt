@tool
extends GridContainer

var debug = false
var sizeX = 400
var sizeY = 0
var separationX = 30
var separationY = 30

var itemSizeX = 0
var itemSizeY = 0

func _get_property_list():
	var properties = []
	## Debug Tille
	properties.append({
		name = "Debug",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "debug",
		type = TYPE_BOOL
	})
	
	## Transform3D Tille
	properties.append({
		name = "Rect",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "sizeX",
		type = TYPE_INT
	})
	properties.append({
		name = "separationX",
		type = TYPE_INT
	})
	properties.append({
		name = "separationY",
		type = TYPE_INT
	})
	
	## Item Tille
	properties.append({
		name = "Item",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "itemSizeX",
		type = TYPE_INT
	})
	properties.append({
		name = "itemSizeY",
		type = TYPE_INT
	})
	return properties

func _run():
	item_auto_scale()

# warning-ignore:unused_argument
func _process(delta):
	if Engine.is_editor_hint():
		item_auto_scale()
	if not Engine.is_editor_hint():
		pass

func item_auto_scale():
	if debug == false:
		sizeX = 300
		separationX = 30
		separationY = 30
	set("custom_constants/v_separation",0)
	set("custom_constants/h_separation",0)
	
	custom_minimum_size.x = sizeX
	size.x = sizeX
	
#	var row = 0
	
	if get_child_count() > 0:
#		row = get_child_count()/columns
		for unit in get_children():
			
			unit.custom_minimum_size.x = sizeX/(columns)-(separationX) + (separationX/(columns))
			unit.size.x = unit.custom_minimum_size.x
			
			unit.custom_minimum_size.y = itemSizeY
			unit.size.y = itemSizeY
		itemSizeX = get_child(0).custom_minimum_size.x
#		sizeY = get_child(0).custom_minimum_size.y*row + separationY*(row-1)
#		size.y = sizeY
	
	set("custom_constants/v_separation",separationX)
	set("custom_constants/h_separation",separationY)
