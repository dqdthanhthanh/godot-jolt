extends Node

var tween: Tween

func color_UI(a,b,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"color",b,time)

func pos_UI(a,b,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"position",b,time)

func pos(a,b,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"position",b,time)

func pos_dir(a,b) -> void:
	var dir:float = a.position.distance_to(b)
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,dir/5.0)

func pos_dir_ratio(a,b,ratio) -> void:
	var dir:float = a.position.distance_to(b)
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,dir*ratio)

func pos_time(a,b,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.tween_property(a,"position",b,time)

func rot(a,b,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"rotation_degrees",b,time)

func fade_out(a,time:float = 1.0) -> void:
	a.modulate = Color(1, 1, 1, 1)
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"modulate",Color(1, 1, 1, 0),time)

func show_out(a,time:float = 1.0) -> void:
	a.modulate = Color(1, 1, 1, 0)
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"modulate",Color(1, 1, 1, 1),time)

func value(t,a,b,time:float = 2.0) -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(2)
	tween.tween_property(a,"value",b,time)

func mesh_tween_color(a,alpha,time:float = 1.0) -> void:
	var co = a.albedo_color
	tween = get_tree().create_tween()
	tween.tween_property(a,"albedo_color",Color(co.r,co.g,co.b,alpha),time)
