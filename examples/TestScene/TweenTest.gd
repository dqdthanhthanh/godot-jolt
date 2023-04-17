extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	var tween = get_node("Tween")
#	tween.interpolate_property($Sprite2D, "position",
#			Vector2(0, 0), Vector2(100, 100), 1,
#			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
	
#	var tween = create_tween()
#	tween.tween_property($Sprite2D, "position", 
#	Vector2(100, 200), 1)
#	tween.tween_property($Sprite2D, "position", 
#	Vector2(200, 300), 1)
	
#	tween.tween_property($Sprite2D, "modulate", Color.RED, 1)
#	tween.tween_property($Sprite2D, "scale", Vector2(), 1)
#	tween.tween_callback(Callable($Sprite2D,"queue_free"))

#	tween.tween_property($Sprite2D, "modulate", Color.RED, 1).set_trans(Tween.TRANS_SINE)
#	tween.tween_property($Sprite2D, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_callback(Callable($Sprite2D,"queue_free"))

#	var tweens = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
#	tweens.tween_property($Sprite2D, "modulate", Color.RED, 1)
#	tweens.tween_property($Sprite2D, "scale", Vector2(), 1)
#	tweens.tween_callback(Callable($Sprite2D,"queue_free"))


	var tween = create_tween()
	for sprite in get_children():
		tween.tween_property(sprite, "position", Vector2(200, 200), 1)








# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
