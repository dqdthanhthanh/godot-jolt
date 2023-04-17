extends Node3D


func _ready():
	if OS.get_name() == "iOS":
		$DirectionalLight3D.light_energy = 0.8
		$WorldEnvironment.environment.adjustment_contrast = 1.4
		$WorldEnvironment.environment.adjustment_saturation = 1.2
	else:
		$DirectionalLight3D.light_energy = 1.0
		$WorldEnvironment.environment.adjustment_contrast = 1.25
		$WorldEnvironment.environment.adjustment_saturation = 1.1
