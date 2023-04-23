@tool
extends Polygon2D

@onready var ins: = preload("res://addons/CreateCharacter/DrawLine.tscn")
@export var lineColor:Color = Color.BLACK
@export var polyColor:Color = Color.WHITE
@export var size:float = 10


func _ready() -> void:
#	if Engine.editor_hint:
		var child = ins.instantiate()
		add_child(child)
		child.update()

#func _process(delta) -> void:
#	if Engine.editor_hint:
#		var child = ins.instance()
#		add_child(child)
#		child.update()
#	if not Engine.editor_hint:
#		pass
