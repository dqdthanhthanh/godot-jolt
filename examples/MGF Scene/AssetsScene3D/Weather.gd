extends Node3D

@onready var sun:DirectionalLight3D = $DirectionalLight3D
@onready var rain:CPUParticles3D = $RainCPUParticles
@onready var snow:CPUParticles3D = $SnowCPUParticles
@onready var lights:Node3D = $Lights

@onready var stadium: = get_parent().get_node("Stadium")



func _ready() -> void:
	weather_setup()
#	if OS.get_current_video_driver() == 0:
#		$WorldEnvironment.environment.background_energy = 0.3
#		$WorldEnvironment.environment.adjustment_enabled = true
#		$WorldEnvironment.environment.adjustment_contrast = 1.6
#		$WorldEnvironment.environment.adjustment_saturation = 1.2
#	else:
#		$WorldEnvironment.environment.background_energy = 1
#		$WorldEnvironment.environment.adjustment_enabled = true
#		$WorldEnvironment.environment.adjustment_contrast = 1.1
#		$WorldEnvironment.environment.adjustment_saturation = 1.2

func weather_setup():
	var data: = Global.weather
	var count:int = data.count
	var en:float
	var peo:float = data.crowd[0]
	
	if Global.isGuide == false:
		if data.day == true:
			sun_angle()
			en = abs(Calculate.rand_a_num(0.7,0.85))
			_sun(true,en)
			stadium.stadium_load_mat(true,peo)
		else:
			_sun(false)
			stadium.stadium_load_mat(false,peo)
	else:
		stadium.stadium_load_mat(false,peo)
	
	if Global.isGuide == false:
		if data.rain == true or data.snow == true:
			var e:float = remap(en,1000,5000,0,0.2)
			if data.rain == true:
				_rain(true,count)
				if data.day == true:
					_sun(true,en-e)
			elif data.snow == true:
				_snow(true,count/2)
				if data.day == false:
					_sun(true,en-(e/4.0))
#	prints(sun,night,rain,snow,count)

func sun_angle():
	sun.rotation_degrees.y += Calculate.rand_int(200)
	sun.rotation_degrees.x += Calculate.rand_int(20)
	sun.rotation_degrees.z += Calculate.rand_int(20)

func _sun(value:bool = true, amount:float = 0.8):
	sun.visible = value
	sun.light_energy = amount
	if value == false:
		lights.visible = true

func _rain(value:bool = false, amount:int = 100):
	rain.visible = value
	rain.emitting = true
	rain.amount = amount

func _snow(value:bool = false, amount:int = 100):
	snow.visible = value
	snow.emitting = true
	snow.amount = amount

func _exit_tree():
	queue_free()
