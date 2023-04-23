extends Panel

@onready var group: = $GridContainer

func _ready() -> void:
	hide()

func load_set_up() -> void:
	SceneTransition.transition()
	show()
	Calculate.remove_children(group)
	
	for i in Global.gameModeList.size():
		var item = Global.gameModeList[i]
		var ins = load("res://addons/mgf_tools/ButtonInfo.tscn").instantiate()
		group.add_child(ins)
		ins.is_info_btn = false
		ins.label_text = item.name
		ins.info_text = item.info
		ins.icon_texture = load(item.icon)
		ins.load_setup()
		ins.connect("pressed", Callable(self, "option_selected").bind(i))
	
	await get_tree().create_timer(Global.btntime).timeout
	group.get_child(Global.gameModeCur).grab_focus()

func option_selected(id):
	print(id)
	Global.gameModeCur = id
	get_parent().setGameMode.text = Global.gameModeList[id].name
	_on_ButtonClose_pressed()

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	hide()
	Calculate.remove_children(group)
