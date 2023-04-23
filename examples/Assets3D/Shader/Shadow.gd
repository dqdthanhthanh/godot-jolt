extends Node3D


var pivot:float
@onready var mat:MeshInstance3D = $Shadow


func _process(delta) -> void:
	rotation_degrees.y = -get_parent().rotation_degrees.y

#func rotateAround(obj, point, axis, angle):
#	var rot = angle + obj.rotation.y 
#	var tStart = point
#	obj.global_translate (-tStart)
#	obj.transform = obj.transform.rotated(axis, -rot)
#	obj.global_translate (tStart)

func _exit_tree():
	queue_free()
