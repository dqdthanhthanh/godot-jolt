extends StaticBody3D

var mapFriction:float = 0.2
var mapBounce:float = 0

func _ready():
	physics_material_override.friction = mapFriction
	physics_material_override.bounce = mapBounce
	physics_material_override.rough = true
