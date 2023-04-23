@tool
extends AcceptDialog

@onready var label := $VBoxContainer/RichTextLabel

func _ready() -> void:
	label.connect("meta_clicked", Callable(self, "__label_meta_clicked"))

func __label_meta_clicked(meta):
	OS.shell_open(meta)
