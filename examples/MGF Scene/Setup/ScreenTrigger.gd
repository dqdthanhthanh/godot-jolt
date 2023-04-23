extends Panel


func _ready() -> void:
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		hide()

func _exit_tree():
	queue_free()
