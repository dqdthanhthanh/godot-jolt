extends RayCast3D

var target:Player = null

func _physics_process(delta):
	if is_colliding():
		target = get_collider()
		print(target.playerName)
