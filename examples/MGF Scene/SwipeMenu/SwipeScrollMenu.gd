extends ScrollContainer


# warning-ignore:export_hint_type_mistmatch
@export var card_scale = 1 # (float, 0.5, 1.0, 0.1)
@export var card_current_scale = 1.3 # (float, 1.0, 1.5, 0.1)
@export var scroll_duration = 1.3 # (float, 0.1, 1.0, 0.1)

var card_current_index: int = 0
var card_x_positions: Array = []

@onready var cardItemIns: = preload("res://MGF Scene/SwipeMenu/CardItem.tscn")
@onready var holdCardItem: = $CenterContainer/MarginContainer/HBoxContainer
@onready var scroll_tween: Tween = $Tween
@onready var margin_r: int = $CenterContainer/MarginContainer.get("theme_override_constants/margin_right")
@onready var card_space: int = $CenterContainer/MarginContainer/HBoxContainer.get("theme_override_constants/separation")
@onready var card_nodes: Array = $CenterContainer/MarginContainer/HBoxContainer.get_children()

@onready var menu: = get_parent().get_parent()

func card_item_instance() -> void:
	card_nodes = []
	card_x_positions = []
	holdCardItem = get_node("CenterContainer/MarginContainer/HBoxContainer")
	cardItemIns = preload("res://MGF Scene/SwipeMenu/CardItem.tscn")
	if holdCardItem.get_child_count() > 0:
		for unit in holdCardItem.get_children():
			unit.queue_free()
	var opName
	var opSize = Global.itemSize
	var opImg
	if Global.optionSelect == 0:
		card_current_index = Global.gameModeCur
		opName = Global.gameModeList
		opImg = Global.gameModeList
	else:
		card_current_index = Global.staCur
		opName = Global.staList
		opImg = Global.staList
	for i in opSize:
		var cardItem = cardItemIns.instantiate()
		holdCardItem.add_child(cardItem)
		cardItem.id = i
		cardItem.text(str(opName[i].name))
		cardItem.img.texture = load(opImg[i].icon)
		card_nodes.append(cardItem)
	create()

func create() -> void:
	if holdCardItem.get_child_count() > 0:
		
		await get_tree().idle_frame
		
		get_h_scroll_bar().modulate.a = 0
		
		for _card in card_nodes:
			var _card_pos_x: float = (margin_r + _card.position.x) - ((size.x - _card.size.x) / 2)
			_card.pivot_offset = (_card.size / 2)
			card_x_positions.append(_card_pos_x)
			
		scroll(card_current_index)

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if visible == true:
		card_nodes = $CenterContainer/MarginContainer/HBoxContainer.get_children()
		for _index in range(card_x_positions.size()):
			var _card_pos_x: float = card_x_positions[_index]
# warning-ignore:integer_division
			var _swipe_length: float = (card_nodes[_index].size.x / 2) + (card_space / 2)
			var _swipe_current_length: float = abs(_card_pos_x - scroll_horizontal)
			var _card_scale: float = remap(_swipe_current_length, _swipe_length, 0, card_scale, card_current_scale)
			var _card_opacity: float = remap(_swipe_current_length, _swipe_length, 0, 0.3, 1)
			
			_card_scale = clamp(_card_scale, card_scale, card_current_scale)
			_card_opacity = clamp(_card_opacity, 0.3, 1)
			
			card_nodes[_index].scale = Vector2(_card_scale, _card_scale)
			card_nodes[_index].modulate.a = _card_opacity
			
			if _swipe_current_length < _swipe_length:
				card_current_index = _index

# warning-ignore:shadowed_variable
func scroll(card_current_index) -> void:
	scroll_horizontal = card_x_positions[card_current_index]
# warning-ignore:return_value_discarded
	scroll_tween.interpolate_property(
		self,
		"scroll_horizontal",
		scroll_horizontal,
		card_x_positions[card_current_index],
		scroll_duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT)
	
	for _index in range(card_nodes.size()):
		var _card_scale: float = card_current_scale if _index == card_current_index else card_scale
# warning-ignore:return_value_discarded
		scroll_tween.interpolate_property(
			card_nodes[_index],
			"scale",
			card_nodes[_index].scale,
			Vector2(_card_scale,_card_scale),
			scroll_duration,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	scroll_tween.start()

func _on_Timer_timeout() -> void:
	menu.setGameMode.disabled = false
	menu.setStadium.disabled = false
	get_parent().hide()

func _exit_tree():
	queue_free()
