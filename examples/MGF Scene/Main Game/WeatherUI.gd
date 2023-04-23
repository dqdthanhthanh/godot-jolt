extends Button


@onready var day: = $Main/Label/IconDay
@onready var add: = $Main/Label/IconAdd

@onready var infoLabel: = $Main/Info/Info/Info

func _ready() -> void:
	weather_UI_setup()

func weather_UI_setup() -> void:
	var textInfo:Array = ["","","","",""]
	var data = Global.weather
	var do:int = 25
	
	if data.day == true:
		textInfo[0] = "Day"
		day.texture = load("res://Assets2D/UI/iconSun.png")
	else:
		textInfo[0] = "Night"
		do -= 3
		day.texture = load("res://Assets2D/UI/iconMoon.png")

	if data.rain == true:
		textInfo[1] = "/Rain/"
		do -= 2
		add.texture = load("res://Assets2D/UI/iconRain.png")
	elif data.snow == true:
		textInfo[1] = "/Snow/"
		do -= 10
		add.texture = load("res://Assets2D/UI/iconSnow.png")
	else:
		add.hide()
		textInfo[1] = "/Sun/"
	
	textInfo[2] = str(do) + "°"
	textInfo[3] = str(data.stadium)
	textInfo[4] = "(" + str(int(data.crowd[0]*10)) + " audiences" + ")"
	
	infoLabel.text = ""
	infoLabel.text = textInfo[0] + textInfo[1] + textInfo[2] + "\n" + textInfo[3] + "\n" + textInfo[4]
