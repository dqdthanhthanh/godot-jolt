extends Node3D

var rng: = RandomNumberGenerator.new()
var speed = 1
var enemySpeed = 0.05
@onready var obj = $Target
@onready var point = $Target/PivotPoint
@onready var follow = $Object

func _ready() -> void:
#	print("0")
	await get_tree().create_timer(3).timeout
#	print("2")
	$point3.position.z = rand_num(5)

func _process(delta) -> void:
	var benchmark = 0.5
	var disUn = $point1.position.distance_to($point3.position)
	$point2.position = lerp($point1.position, $point3.position, remap(-benchmark,0,disUn,0,1))
	var fixx = obj.position.x - point.global_transform.origin.x
	var fixz = obj.position.z - point.global_transform.origin.z
	var vectorFix = Vector3($Enemy.position.x+fixx,obj.position.y,$Enemy.position.z+fixz)
	obj.position = obj.position.move_toward(vectorFix, enemySpeed)
	move_object()
	if Input.is_action_pressed("roll_left"):
		speed -= 0.1
	elif Input.is_action_pressed("roll_right"):
		speed += 0.1
	
	$Object.position = $Object.position.move_toward($Target/PivotPoint.global_transform.origin,0.06)
	rotateAround($Target, $Target/PivotPoint.global_transform.origin,speed)
	
	var shot = 90
	
	## point3 = diemsut
	$point3.position.z = rand_num(remap(shot,0,100,40,1))
	
	## point2 = cau thu; point1 = bong
	$point2.look_at($point3.position, transform.basis.y)
	
#	find_angle()

func find_angle():
	## Bai toan tim goc
	var AB = $point1.position.distance_to($point3.position)
#	print(AB) #11.18
	var AH = abs($point1.position.x-$point3.position.x)
#	print(AH) #10
	var BH = abs($point1.position.z-$point3.position.z)
#	print(BH) #5
	var BC = pow(AB,2)/BH
#	print(BC) #25
	## Tim goc cosAlpha:
	var cosAl = rad_to_deg(acos(AB/BC))
#	print(cosAl)
	var gocChuan
	if $point1.position.x<$point3.position.z:
		if $point2.position.z<0:
			gocChuan = 90+cosAl
		else:
			gocChuan = 90-cosAl
	else:
		if $point2.position.z<0:
			gocChuan = 90-cosAl
		else:
			gocChuan = 90+cosAl
	$point2.rotation_degrees.y = gocChuan
	print($point2.rotation_degrees.y)

func rand_num(value):
	rng.randomize()
	var number = rng.randf_range(-value, value)
	return number

## Xoay doi tuong quanh tam
func rotateAround(obj, point, angle):
	var axis = Vector3(0,1,0)
	var rot = angle + obj.rotation.y 
	var tStart = point
	obj.global_translate (-tStart)
	obj.transform = obj.transform.rotated(axis, -rot)
	obj.global_translate (tStart)

## Di chuyen tam de test
func move_object():
	var speedPlayer = 0.1
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			obj.global_transform.origin.z = obj.global_transform.origin.z
			$point1.position.z = $point1.position.z
	elif Input.is_action_pressed("ui_up"):
			obj.global_transform.origin.z -= speedPlayer
			$point1.position.z -= speedPlayer
	elif Input.is_action_pressed("ui_down"):
			obj.global_transform.origin.z += speedPlayer
			$point1.position.z += speedPlayer
	## Di chuyen sang ngang
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			obj.global_transform.origin.x = obj.global_transform.origin.x
			$point1.position.x = $point1.position.x
	elif Input.is_action_pressed("ui_left"):
			obj.global_transform.origin.x -= speedPlayer
			$point1.position.x -= speedPlayer
	elif Input.is_action_pressed("ui_right"):
			obj.global_transform.origin.x += speedPlayer
			$point1.position.x += speedPlayer
