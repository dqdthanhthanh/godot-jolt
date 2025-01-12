@tool
extends Control

const color_width := 8

@onready var panel_container := $PanelContainer
@onready var title_label := $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/Title
@onready var details_label := $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/Details
@onready var edit_button := $PanelContainer/HBoxContainer/EditButton
@onready var context_menu := $ContextMenu

signal change()

var style_box_focus: StyleBoxFlat
var style_box_panel: StyleBoxFlat

var board

var title: String: set = set_title
var details: String: set = set_details
var category : set = set_category

func set_category(val):
	if is_instance_valid(category):
		category.disconnect("changed", Callable(self, "update"))
	category = val
	category.connect("changed", Callable(self, "update"))
	update()

func copy():
	var t = board.construct_task(title, details, category)
	return t

func set_title(val):
	title = val
	if title_label and not title_label.text==val:
		title_label.text = val
	
	if is_inside_tree():
		emit_signal("change")

func set_details(val):
	details = val
	if is_instance_valid(details_label):
		details_label.visible = board.show_details_preview and not details.strip_edges().is_empty()
		details_label.text = details
	
	if is_inside_tree():
		emit_signal("change")

# forward to title_label
func show_edit(intention):
	title_label.show_edit(intention)

func init(board, title, details, category):
	self.board = board
	
	self.title = title
	self.details = details
	self.category = category

func serialize():
	var res = {
		"category": board.category_index(category),
		"title": title,
		"details": details
	}
	return res

func apply_filter(filter: String, descriptions: bool):
	if filter.is_empty():
		visible = true
		return
	
	var title_simple := __simplify_string(title)
	var details_simple := __simplify_string(details)
	var filter_simple := __simplify_string(filter)
	
	if (
			title_simple.matchn("*"+filter_simple+"*")
			or 
			(details_simple.matchn("*"+filter_simple+"*")
			and descriptions)
	):
		visible = true
	else:
		visible = false

func __simplify_string(string: String) -> String:
	return string.replace(" ", "").replace("\t", "")

func show_details():
	var d = board.get_details_dialog()
	d.show_popup(title, details, category)
	d.connect("change", Callable(self, "details_changed"))
	d.connect("popup_hide", Callable(self, "details_hidden").bind(), CONNECT_ONE_SHOT)

func details_changed():
	var d = board.get_details_dialog()
	set_title(d.title)
	set_details(d.details)
	set_category(d.category)
	emit_signal("change")

func details_hidden():
	var d = board.get_details_dialog()
	d.disconnect("change", Callable(self, "details_changed"))

func edit_label_entered():
	grab_focus()

func _ready() -> void:
	title_label.text = title
	title_label.connect("text_changed", Callable(self, "set_title"))
	title_label.connect("text_submitted", Callable(self, "edit_label_entered"))
	
	details_label.visible = board.show_details_preview and not details.strip_edges().is_empty()
	details_label.text = details
	
	edit_button.connect("pressed", Callable(self, "show_details"))
	
	board.connect("changed", Callable(self, "__on_settings_changed"))
	
	context_menu.connect("id_pressed", Callable(self, "action"))
	
	style_box_focus = StyleBoxFlat.new()
	style_box_focus.set_border_width_all(1)
	style_box_focus.draw_center = false
	style_box_focus.border_color = category.color
	
	style_box_panel = StyleBoxFlat.new()
	style_box_panel.set_border_width_all(0)
	style_box_panel.border_width_left = color_width
	style_box_panel.border_color = category.color
	style_box_panel.draw_center = false
	panel_container.add_theme_stylebox_override("panel", style_box_panel)
	
	#notification(NOTIFICATION_THEME_CHANGED)
	update()
	propagate_notification(NOTIFICATION_THEME_CHANGED)

func __on_settings_changed():
	details_label.visible = board.show_details_preview and not details.strip_edges().is_empty()
	details_label.text = details

#func get_tooltip(at: Vector2 = Vector2.ZERO):
#	return category.title+": "+title
func update():
	tooltip_text = category.title+": "+title
	
	if is_instance_valid(style_box_focus):
		style_box_focus.border_color = category.color
	if is_instance_valid(style_box_panel):
		style_box_panel.border_color = category.color

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		accept_event()
		__update_context_menu()
		context_menu.position = get_global_mouse_position()
		context_menu.popup()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and event.is_double_click():
		action(ACTIONS.DETAILS)

func _unhandled_key_input(event):
	if not board.can_handle_shortcut(self):
		return
	if not event.is_echo() and event.is_pressed():
		if board.shortcut_delete.matches_event(event):
			get_viewport().set_input_as_handled()
			action(ACTIONS.DELETE)
		elif board.shortcut_rename.matches_event(event):
			get_viewport().set_input_as_handled()
			action(ACTIONS.RENAME)
		elif board.shortcut_confirm.matches_event(event):
			get_viewport().set_input_as_handled()
			action(ACTIONS.DETAILS)
		elif board.shortcut_duplicate.matches_event(event):
			get_viewport().set_input_as_handled()
			action(ACTIONS.DUPLICATE)

func _get_drag_data(position):
	var control = Control.new()
	var rect = ColorRect.new()
	control.add_child(rect)
	rect.size = get_rect().size
	rect.position = -position
	rect.color = category.color
	set_drag_preview(control)
	return self

enum ACTIONS {
	DETAILS,
	RENAME,
	DELETE,
	DUPLICATE
}

func __update_context_menu():
	context_menu.clear()
	context_menu.add_item("Details", ACTIONS.DETAILS)
	
	context_menu.add_separator()
	
	context_menu.add_icon_item(get_icon("Rename", "EditorIcons"), "Rename", ACTIONS.RENAME)
	context_menu.set_item_shortcut(context_menu.get_item_index(ACTIONS.RENAME), board.shortcut_rename)
		
	context_menu.add_icon_item(get_icon("Duplicate", "EditorIcons"), "Duplicate", ACTIONS.DUPLICATE)
	context_menu.set_item_shortcut(context_menu.get_item_index(ACTIONS.DUPLICATE), board.shortcut_duplicate)
	
	context_menu.add_icon_item(get_icon("Remove", "EditorIcons"), "Delete", ACTIONS.DELETE)
	context_menu.set_item_shortcut(context_menu.get_item_index(ACTIONS.DELETE), board.shortcut_delete)

func action(action):
	match(action):
		ACTIONS.DELETE:
			board.delete_task(self)
			emit_signal("change")
		ACTIONS.DETAILS:
			show_details()
		ACTIONS.DUPLICATE:
			var n = copy()
			get_owner().add_task(n)
			get_owner().move_task(len(get_owner().tasks)-1, get_owner().tasks.find(self)+1)
			await get_tree().create_timer(0.0).timeout
			n.grab_focus()
		ACTIONS.RENAME:
			if context_menu.visible:
				await context_menu.popup_hide
			title_label.show_edit()

func _notification(what):
	match(what):
		NOTIFICATION_THEME_CHANGED:
			if panel_container:
				var tab_panel = get_stylebox("panel", "TabContainer")
				if tab_panel is StyleBoxFlat:
					style_box_panel.bg_color = tab_panel.bg_color
					style_box_panel.draw_center = true
				else:
					style_box_panel.draw_center = false
			if edit_button:
				edit_button.icon = get_icon("Edit", "EditorIcons")
		NOTIFICATION_DRAW:
			if has_focus():
				style_box_focus.draw(get_canvas_item(), Rect2(panel_container.get_global_rect().position-get_global_rect().position, panel_container.size))
