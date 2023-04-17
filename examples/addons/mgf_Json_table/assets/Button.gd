@tool

extends Button


var id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	var parrent = get_parent().get_parent().get_parent()
	var tabs = get_parent().get_parent().get_node("TabContainer")
	parrent.reload_data(tabs.current_tab,id)
