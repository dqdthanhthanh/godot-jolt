extends MarginContainer


@onready var balls:Array = get_tree().get_nodes_in_group("ball")
@onready var ball:Sprite2D = $Ball/unit

@onready var obj:Array = get_tree().get_nodes_in_group("obj")
@onready var units:Array = get_tree().get_nodes_in_group("units")

var run:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/unit.hide()
	ins_units()

func ins_units() -> void:
	var unit = get_tree().get_nodes_in_group("units")
	for i in unit.size():
		var ins = load("res://MGF Scene/MiniMap/unit_minimap.tscn").instantiate()
		ins.id = i
		$MarginContainer.add_child(ins)
	run = true

func _process(delta) -> void:
	ball.position = vector_convert(balls[0].position)
#	if run == true:
#		for i in obj.size():
#			prints(obj[i].position,units[i].translation)
#			obj[i].position = vector_convert(units[i].translation)

func vector_convert(vec) -> Vector2:
	var x = remap(vec.x,-14.25,14.25,0,256)
	var y = remap(vec.z,-6.9,6.9,0,150)
	x = clamp(x,0,256)
	y = clamp(y,0,150)
	return Vector2(x,y)

func _exit_tree():
	queue_free()
