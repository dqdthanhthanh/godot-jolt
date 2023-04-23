@tool
extends Button

@export var toggleOn:Texture2D = preload("res://Assets2D/UI/IconMovePlay.png")
@export var toggleOff:Texture2D = preload("res://Assets2D/UI/IconMoveRight.png")

@export var isToggle:bool = true

func _run() -> void:
	_ready()

func _ready() -> void:
	if isToggle == true:
		icon = toggleOff
	else:
		icon = toggleOn
	connect("pressed",Callable(self,"_on_BtnToggle_pressed"))

func toggled() -> void:
	if isToggle == true:
		isToggle = false
		icon = toggleOn
	else:
		isToggle = true
		icon = toggleOff

func _on_BtnToggle_pressed() -> void:
	toggled()
