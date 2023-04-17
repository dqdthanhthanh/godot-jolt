extends Node

func my_func():
	print("Hello")
	print("world")


func _ready():
	pass
#	get_parent().call_deferred("wait_time")
#	await get_tree().create_timer(10.0).timeout
#	get_parent().call_deferred("_on_ButtonSeason_pressed")

#func get_method_names():
#	var methods = []
#	for fun in get_parent().get_method_list():
#		if fun["flags"] == METHOD_FLAG_NORMAL + METHOD_FLAG_FROM_SCRIPT:
#			methods.append(fun["name"])
#	return methods

func wait_time(time):
	await get_tree().create_timer(time).timeout
	print("run")
