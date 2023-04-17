extends CanvasLayer

func _ready():
	is_load(false)

func is_load(value):
	$icon.visible = value
	$Label.visible = value

func _process(delta):
	$icon.rotation += 1 * delta

# warning-ignore:return_value_discarded
func change_scene_to_file(target: String) -> void:
	Engine.time_scale = 1.0
	ClickEffect.stop_effect_click()
	$clouds.hide()
	$Label.hide()
	transition_dissolve(target)

func transition_dissolve(target: String) -> void:
	is_load(true)
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)
