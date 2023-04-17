@tool

extends Button


var id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonGroup_pressed():
	var parrent = get_parent().get_parent().get_parent().get_parent()
	parrent.groupID = id
	parrent._on_Reload_pressed()
#	parrent.reload_data(tabs.current_tab,id)
