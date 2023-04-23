extends CanvasLayer

@onready var BG: = $BG


func _ready() -> void:
	is_load(false)

func is_load(value) -> void:
	$icon.visible = value
	$Label.visible = value

func _process(delta) -> void:
	if $icon.visible == true:
		$icon.rotation += 500 * delta

# warning-ignore:return_value_discarded
func change_scene_to_file(target: String, type: String = 'dissolve') -> void:
	ClickEffect.stop_effect_click()
	$clouds.hide()
	$Label.hide()
	if type == 'dissolve':
		transition_dissolve(target)
	else:
		transition_match(target)
	Account.game_load_set_up()

func transition_match(target: String) -> void:
	var ins = load("res://MGF Scene/Season/MatchReady.tscn").instantiate()
	BG.show()
	BG.add_child(ins)
	ins.hide()
	ins.load_setup(true,1)
	await get_tree().create_timer(1.0).timeout
	ins.show()
	
	is_load(true)
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)
	
	BG.hide()
	ins.queue_free()

func transition_dissolve(target: String) -> void:
	if Global.isQuit == false:
		is_load(true)
		$AnimationPlayer.play('dissolve')
		await $AnimationPlayer.animation_finished
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)

func transition_clouds(target: String) -> void:
	is_load(true)
	$clouds.show()
	$AnimationPlayer.play('clouds_in')
	await $AnimationPlayer.animation_finished
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play('clouds_out')
	is_load(false)

func load_transition(time:float = 0) -> void:
	is_load(true)
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(time).timeout
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)

func transition() -> void:
	is_load(true)
	$AnimationPlayer.play('dissolve')
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)

func start_transition() -> void:
	is_load(true)
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished

func end_transition(time:float = 0) -> void:
	await get_tree().create_timer(time).timeout
# warning-ignore:return_value_discarded
	$AnimationPlayer.play_backwards('dissolve')
	is_load(false)
