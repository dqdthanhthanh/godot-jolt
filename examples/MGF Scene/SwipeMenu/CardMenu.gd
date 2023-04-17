extends Button

@export var id: int = 0

@onready var menu = get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var swipeMenu = get_parent().get_parent().get_parent().get_parent()
@onready var label = $Label
@onready var img = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	connect("pressed",Callable(self,"_on_CardMenu_pressed"))

func text(value):
	label.text = "[center]" + value + "[/center]"

func _on_CardMenu_pressed():
	swipeMenu.scroll(id)
	Calculate.timer(swipeMenu.get_node("Timer"),0.3)
	if Global.optionSelect == 0:
		Global.gameModeCur = id
		menu.get_parent().setGameMode.text = Global.gameModeName[id]
	else:
		Global.staCur = id
		menu.get_parent().setStadium.text = Global.staName[id]
#		menu.get_parent().setStadium.icon = Global.staImg[id]

