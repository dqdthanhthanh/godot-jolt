@tool
extends EditorPlugin

const MainPanel = preload("res://addons/mgf_json_table/MainUI.tscn")

var MainPanelIns

func _enter_tree():
	MainPanelIns = MainPanel.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(MainPanelIns)
	_make_visible(false)

func _exit_tree():
	if MainPanelIns:
		MainPanelIns.queue_free()

func _has_main_screen():
	return true
	
func _make_visible(visible):
	if MainPanelIns:
		MainPanelIns.visible = visible

func _get_plugin_name():
	return "JsonTable"
	
#func _get_plugin_icon():
#	return get_editor_interface().get_base_control().get_icon("ListSelect","EditorIcons")
