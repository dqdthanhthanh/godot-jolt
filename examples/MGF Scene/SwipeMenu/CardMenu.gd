extends Button

@export var id: int = 0

@onready var menu = get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var swipeMenu = get_parent().get_parent().get_parent().get_parent()
@onready var label = $Label
@onready var img = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# warning-ignore:return_value_discarded
	connect("pressed", Callable(self, "_on_CardMenu_pressed"))

func text(value) -> void:
	label.text = "[center]" + value + "[/center]"

func _on_CardMenu_pressed() -> void:
	swipeMenu.scroll(id)
	Calculate.timer(swipeMenu.get_node("Timer"),0.3)
	if Global.optionSelect == 0:
		Global.gameModeCur = id
		menu.get_parent().setGameMode.text = Global.gameModeList[id].name
	else:
		Global.staCur = id
		menu.get_parent().setStadium.text = Global.staList[id].name
#		menu.get_parent().setStadium.icon = load(Global.staList[id].icon)

func _exit_tree():
	queue_free()
