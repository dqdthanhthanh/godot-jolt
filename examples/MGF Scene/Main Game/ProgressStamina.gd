extends ProgressBar

@export var gradient:Gradient

@onready var shader_bar: = preload("res://Assets2D/Theme/FormationStaminaShader.tres").duplicate()


func _on_ProgressStamina_value_changed(value) -> void:
	set("theme_override_styles/fg",shader_bar)
	shader_bar.bg_color = gradient.sample(value/100)

func _exit_tree():
	queue_free()
