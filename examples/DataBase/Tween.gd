extends Node

var tween: Tween
#	tween.tween_property(a, "bg_color", b, time)
#	tween.tween_callback(a.queue_free)

func color_UI(a,b,time):
	tween = get_tree().create_tween()
	tween.tween_property(a,"color",b,time)

func pos_UI(a,b,time):
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,time)

func pos(a,b):
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,1)

func pos_dir(a,b):
	var dir = a.position.distance_to(b)
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,dir)

func pos_time(a,b,time):
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,time)

func rot_time(a,b,time):
	tween = get_tree().create_tween()
	tween.tween_property(a,"rotation_degrees",b,time)

func rot(a,b):
	tween = get_tree().create_tween()
	tween.tween_property(a,"rotation_degrees",b,1)

func fade_out(a,time):
	a.modulate = Color(1, 1, 1, 1)
	tween = get_tree().create_tween()
	tween.tween_property(a,"modulate",Color(1, 1, 1, 0),time)

func show_out(a,time):
	a.modulate = Color(1, 1, 1, 0)
	tween = get_tree().create_tween()
	tween.tween_property(a,"modulate",Color(1, 1, 1, 1),time)

func value(a,b):
	tween = get_tree().create_tween()
	tween.tween_property(a,"value",b,2)
