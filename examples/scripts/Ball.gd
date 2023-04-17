extends RigidBody3D

var ballLinear:float = -1
var ballAngular:float = 0.5
var ballMass:float = 1.8
var ballFriction:float = 0.05
var ballBounce:float = 0.5
var ballMarginCol:float = 0.01

@onready var ballCol:CollisionShape3D = $CollisionShape3D

#@onready var effEmit:EffekseerEmitter = $EffekseerEmitter
#@onready var effTrail:EffekseerEmitter = $EffekseerEmitterTrail

@onready var soundfx:AudioStreamPlayer = $SoundFx

var team:int = 11

var replay_data = {
	"pos": [],
	"rot": []
}
var baseTransform:Transform3D

func _ready():
	pass
	linear_damp = ballLinear
	angular_damp = ballAngular
	mass = ballMass
	physics_material_override.friction = ballFriction
	physics_material_override.bounce = ballBounce
	physics_material_override.rough = false
	ballCol.shape.margin = ballMarginCol

func ballColTrue():
	ballCol.disabled = true

func ballColFalse():
	ballCol.disabled = false

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Ball_body_shape_entered(body_id, body, body_shape, local_shape):
	if linear_velocity.length()>0.5:
#		effEmit.play()
		soundfx.volume_db = linear_velocity.length()/4
		soundfx.play()

func ball_is_collision(value):
	ballCol.disabled = value
