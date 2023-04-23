extends Popup

@onready var teamNameA: = $Panel/TeamName/A
@onready var teamNameB: = $Panel/TeamName/A

func _on_ButtonClose_pressed() -> void:
	hide()

func _exit_tree():
	queue_free()
