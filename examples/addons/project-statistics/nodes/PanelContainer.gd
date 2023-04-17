@tool
extends PanelContainer

func _ready() -> void:
	set("custom_styles/panel", get_theme_stylebox("Content", "EditorStyles"))
