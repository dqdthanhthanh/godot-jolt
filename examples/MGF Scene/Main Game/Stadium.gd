extends Node3D

var staMat = [
			"res://Assets3D/Stadium/DEN.material",
			"res://Assets3D/Stadium/khandai.material",
			"res://Assets3D/Stadium/che.material",
			"res://Assets3D/Stadium/san.material",
			"res://Assets3D/Stadium/tuong.material",
			"res://Assets3D/Stadium/gach.material",
			"res://Assets3D/Stadium/kimloai.material",
			"res://Assets3D/Stadium/thang.material",
			"res://Assets3D/Goal/M_COT.material",
			"res://Assets3D/StadiumShader/field_mat_op.tres",
			]
func stadium_load_mat(value:bool = false,crowdRatio:int=100) -> void:
	var staColor:Array = GlobalTheme.teamColor[Global.teamID1]
	var graColor: GradientTexture2D = load("res://Assets2D/Stadium/GradientStadiumMat.tres")
#	var mat_base = load("res://Assets2D/StadiumShader/field_mat_op.tres")
#	var mat_high = load("res://Assets2D/StadiumShader/field_mat.tres")

	var col = staColor[0]
	col.r += 0.01
	col.g += 0.01

	load(staMat[1]).albedo_color = staColor[1]
	load(staMat[2]).albedo_color = col
	graColor.gradient.colors[0] = col
	load(staMat[2]).get_next_pass().set("shader_param/Material_Albedo",graColor)

#var weather:Dictionary = {
#	"day": true,
#	"rain": false,
#	"snow": false,
#	"count": 0, ##200-500 1000-5000
#	"crowd": [80],
#	"stadium": "MGF Stadium",
	var field:int = 9
	var rain:float = 0
	var snow:float = 0
	if Global.isGuide == false and Global.weather.count > 0:
		rain = remap(Global.weather.count,200,5000,0.1,1.0)
		rain = clamp(rain,0.1,1.0)
		snow = remap(Global.weather.count,200,5000,0.1,0.8)
		snow = clamp(snow,0.1,0.8)

	for i in range(2,9):
		load(staMat[i]).get_next_pass().set("shader_param/rain_amount",0)
		load(staMat[i]).get_next_pass().set("shader_param/wet_level",0)
		load(staMat[i]).get_next_pass().set("shader_param/snow_amount",0)
		load(staMat[i]).set("shader_param/without_snow_angle",0)

		if Global.isGuide == false:
			if Global.weather.rain == true:
				load(staMat[i]).get_next_pass().set("shader_param/rain_amount",1)
				load(staMat[i]).get_next_pass().set("shader_param/wet_level",rain)
				load(staMat[i]).get_next_pass().set("shader_param/snow_amount",0)
			if Global.weather.snow == true:
				if snow > 0.4:
					load("res://Assets3D/Grass/M_line.tres").albedo_color = Color.ORANGE_RED
				load(staMat[i]).get_next_pass().set("shader_param/rain_amount",0)
				load(staMat[i]).get_next_pass().set("shader_param/wet_level",0)
				load(staMat[i]).get_next_pass().set("shader_param/snow_amount",snow)

	load(staMat[field]).set("shader_param/rain_amount",0)
	load(staMat[field]).set("shader_param/wet_level",0)
	load(staMat[field]).set("shader_param/snow_amount",0)
	load(staMat[field]).set("shader_param/without_snow_angle",0)

	if Global.isGuide == false:
		if Global.weather.rain == true:
			load(staMat[field]).set("shader_param/rain_amount",1)
			load(staMat[field]).set("shader_param/wet_level",rain)
			load(staMat[field]).set("shader_param/snow_amount",0)
		if Global.weather.snow == true:
			load(staMat[field]).set("shader_param/rain_amount",0)
			load(staMat[field]).set("shader_param/wet_level",0)
			load(staMat[field]).set("shader_param/snow_amount",snow)

	if value == false:
		load(staMat[0]).albedo_color = Color.WHITE
		load(staMat[0]).emission = Color.WHITE
	else:
		load(staMat[0]).albedo_color = Color.BLACK
		load(staMat[0]).emission = Color.BLACK
	
	if Global.gameModeCur <2:
		for i in get_child_count():
			if i > 0:
				get_child(i).create_crowd(crowdRatio)

func _exit_tree():
	queue_free()
