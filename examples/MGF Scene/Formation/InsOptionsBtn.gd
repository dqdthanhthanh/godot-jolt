extends Panel


@onready var group: = $ScrollContainer/MainBtn

signal item_selected(id)

func _ready() -> void:
	hide()

func creat_btn(obj,label:String,tab:int = 0, list:Array = [],icon:String = "") -> void:
	if list.size()>0:
		show()
		$Label.text = label
		if icon != "":
			$Label.icon = load(icon)
		Calculate.remove_children(group)
		
		for i in list.size():
			var item = list[i]
			var ins = load("res://MGF Scene/Setup/BtnOptionsIns.tscn").instantiate()
			ins.text = item.text
			ins.connect("pressed", Callable(self, "item_select").bind(obj,i))
			if icon != "":
				ins.icon = load(icon)
			else:
				ins.icon = load(item.icon)
			group.add_child(ins)
			await get_tree().create_timer(0).timeout
		await get_tree().create_timer(0).timeout
		group.get_child(tab).grab_focus()

func item_select(obj,id) -> int:
	emit_signal("item_selected",id)
	obj.text = group.get_child(id).text
	obj.icon = group.get_child(id).icon
	hide()
	return id

func _on_ButtonClose_pressed() -> void:
	hide()

func _exit_tree():
	queue_free()
