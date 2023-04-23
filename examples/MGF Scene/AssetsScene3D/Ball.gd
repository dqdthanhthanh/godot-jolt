extends RigidBody3D

@export var ballLinear:float = 0.5
@export var ballAngular:float = 0.8
@export var ballMass:float = 2.0
@export var ballFriction:float = 0.5
@export var ballBounce:float = 0.3
@export var ballMarginCol:float = 0.01

@onready var ballCol:CollisionShape3D = $CollisionShape3D

#@onready var effEmit:EffekseerEmitter = $EffekseerEmitter
#@onready var effTrail:EffekseerEmitter = $EffekseerEmitterTrail

@onready var soundfx:AudioStreamPlayer = $SoundFx

var team:int = 11

var replay_data:Dictionary = {
	"pos": [],
	"rot": []
}
var baseTransform:Transform3D

func _ready() -> void:
	linear_damp = ballLinear
	angular_damp = ballAngular
	mass = ballMass
	physics_material_override.friction = ballFriction
	physics_material_override.bounce = ballBounce
	ballCol.shape.margin = ballMarginCol

func ball_effect_trail(value) -> void:
	pass
#	effTrail.color = value
#	effTrail.color.a = 1

func ballColTrue() -> void:
	ballCol.disabled = true

func ballColFalse() -> void:
	ballCol.disabled = false

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Ball_body_shape_entered(body_id, body, body_shape, local_shape) -> void:
	if linear_velocity.length()>0.5:
#		effEmit.play()
		soundfx.volume_db = linear_velocity.length()/4
		soundfx.play()

func ball_is_collision(value) -> void:
	ballCol.disabled = value

func _exit_tree() -> void:
	queue_free()
