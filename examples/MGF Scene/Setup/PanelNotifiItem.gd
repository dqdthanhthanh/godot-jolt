extends Panel


@onready var time = $Panel/time
@onready var day = $Panel/day
@onready var label = $Panel/label
@onready var info = $Panel/info


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_ButtonClose_pressed():
	Account.notifi_news()
	hide()

func _exit_tree():
	queue_free()
