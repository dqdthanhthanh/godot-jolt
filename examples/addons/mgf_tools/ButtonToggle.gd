@tool
extends Button

@export var toggleOn:Texture2D = preload("res://Assets2D/UI/iconControllerHide.png")
@export var toggleOff:Texture2D = preload("res://Assets2D/UI/iconController.png")

@export var isToggle:bool = true

func _ready():
	if isToggle == true:
		icon = toggleOff
	else:
		icon = toggleOn
	connect("pressed",Callable(self,"_on_BtnToggle_pressed"))

func toggled():
	if isToggle == true:
		isToggle = false
		icon = toggleOn
	else:
		isToggle = true
		icon = toggleOff

func _on_BtnToggle_pressed():
	toggled()
