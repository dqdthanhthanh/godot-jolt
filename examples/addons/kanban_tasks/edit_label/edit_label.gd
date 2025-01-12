@tool
extends VBoxContainer

enum INTENTION {REPLACE, ADDITION}

var edit: LineEdit
var label: Label
var old_focus: Control = null

@export var text: String = "": get = get_text, set = set_text

@export var default_intention: INTENTION := INTENTION.ADDITION
@export var double_click := true

signal text_changed(new_text)
signal text_submitted(new_text)

func set_text(value):
	text = value
	update_content()
	emit_signal("text_changed", text)

func get_text():
	return text

func update_content(val=null):
	if val is String:
		text = val
	if label:
		label.text = text
	if edit:
		edit.text = text

func _ready() -> void:
	self.alignment = BoxContainer.ALIGNMENT_CENTER
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	
	label = Label.new()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.size_flags_vertical = SIZE_SHRINK_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	
	#TODO forward to settings
	label.autowrap = true
	label.max_lines_visible = 2
	
	label.connect("gui_input", Callable(self, "label_input"))
	add_child(label)
	
	edit = LineEdit.new()
	edit.visible = false
	edit.size_flags_horizontal = SIZE_EXPAND_FILL
	edit.size_flags_vertical = SIZE_FILL
	edit.connect("text_submitted", Callable(self, "edit_text_entered"))
	edit.connect("gui_input", Callable(self, "edit_input"))
	add_child(edit)
	
	update_content()

func label_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index==MOUSE_BUTTON_LEFT and (event.is_double_click() if double_click else true):
		show_edit()
		label.accept_event()

func edit_input(event):
	if event is InputEventKey and event.is_pressed() and event.is_action("ui_cancel"):
		show_label(false)

func edit_text_entered(_new):
	update_content(edit.text)
	show_label()
	emit_signal("text_submitted")

func _input(event):
	if (event is InputEventMouseButton) and event.pressed and edit.visible:
		var local = edit.make_input_local(event)
		if not Rect2(Vector2(0,0), edit.size).has_point(local.position):
			show_label()

func show_edit(p_intention=null):
	if edit.visible:
		return
	
	if focus_mode == FOCUS_NONE:
		old_focus = get_viewport().gui_get_focus_owner()
	
	var intention = p_intention
	if intention == null:
		intention = default_intention
	update_content()
	label.visible = false
	edit.visible = true
	edit.grab_focus()
	match intention:
		INTENTION.ADDITION:
			edit.caret_column = len(edit.text)
		INTENTION.REPLACE:
			edit.select_all()

func show_label(_apply_changes=true):
	if label.visible:
		return
	
	if _apply_changes:
		update_content(edit.text)
		emit_signal("text_changed", text)
	
	if not is_instance_valid(old_focus):
		if focus_mode == FOCUS_NONE:
			edit.release_focus()
		else:
			grab_focus()
	else:
		old_focus.grab_focus()
	
	edit.visible = false
	label.visible = true
