extends Area3D


@onready var CrossBarSound: = $CrossBarSound
@onready var NetSound: = $NetSound


func _on_CrossBar_body_entered(body) -> void:
	if body == get_parent().Ball:
		CrossBarSound.play()

func _exit_tree():
	queue_free()
