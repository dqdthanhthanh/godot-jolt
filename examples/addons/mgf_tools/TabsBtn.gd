extends Node

@export var groupPath: NodePath
var group
@export var tabPath: NodePath
var tab

@export var n = preload("res://Assets2D/Theme/btnUIN.tres")
@export var p = preload("res://Assets2D/Theme/btnUIP.tres")

@export var isIns = false

var isTab:bool = false
@export var current_tab:int = 0
@export var ins_max:int = 5
@export var current_ins:int = 0
@export var ins_size:int = 0

signal on_tab_select(id)

func _ready():
	if isIns == false:
		group = get_node(groupPath)
		await get_tree().create_timer(0).timeout
		for i in group.get_child_count():
			set_btn_dis(i)
			group.get_child(i).connect("pressed", Callable(self, "tab_select").bind(i))
		tab_set_up()
		set_btn_active(current_tab)

func tab_set_up():
	if get_node(tabPath) != null:
		tab = get_node(tabPath)
		isTab = true
		await get_tree().create_timer(0).timeout
		for i in tab.get_child_count():
			tab.get_child(i).hide()
			set_btn_dis(i)
		tab.get_child(current_tab).show()

func tab_select(id):
	await get_tree().create_timer(0).timeout
	if current_tab != id:
		if isTab == true:
			tab.get_child(current_tab).hide()
			tab.get_child(id).show()

		if isIns == false:
			set_btn_dis(current_tab)
			set_btn_active(id)
#		else:
#			print(current_tab-(current_ins*ins_max))
#			yield(get_tree().create_timer(0), "timeout")
#			set_btn_dis(current_tab-(current_ins*ins_max))
#			set_btn_active(id-(current_ins*ins_max))

		current_tab = id

		emit_signal("on_tab_select",id)

func set_btn_active(i):
	group.get_child(i).set("theme_override_styles/normal",p)
	group.get_child(i).set("theme_override_styles/hover",p)
	group.get_child(i).set("theme_override_styles/pressed",p)
	group.get_child(i).set("theme_override_styles/focus",p)

func set_btn_dis(i):
	group.get_child(i).set("theme_override_styles/normal",n)
	group.get_child(i).set("theme_override_styles/hover",p)
	group.get_child(i).set("theme_override_styles/pressed",p)
	group.get_child(i).set("theme_override_styles/focus",p)

func _on_BtnL_pressed():
	var cur:int
	if current_ins > 0:
		current_ins -= 1
	else:
		current_ins = int(ins_size/5)
	if ins_size < ins_max:
		cur = ins_size
	else:
		cur = ins_size-((current_ins)*ins_max)
	if ins_size >= ins_max and current_ins == 0:
		cur = ins_max
#	prints(current_ins,ins_size,cur)
	create_btn(cur,true)

	await get_tree().create_timer(0.1).timeout
	for i in group.get_child_count():
		set_btn_dis(i)


func _on_BtnR_pressed():
	var cur:int
	if current_ins < int(ins_size/ins_max):
		current_ins += 1
	else:
		current_ins = 0
	if ins_size < ins_max:
		cur = ins_size
	else:
		cur = ins_size-((current_ins)*ins_max)
	if ins_size >= ins_max and current_ins == 0:
		cur = ins_max
#	prints(current_ins,ins_size,cur)
	create_btn(cur,true)

	await get_tree().create_timer(0.1).timeout
	for i in group.get_child_count():
		set_btn_dis(i)

func create_btn(size,type:bool = false):
	group = get_node(groupPath)
	if type == false:
		ins_size = size
	if size > ins_max:
		if current_ins == 0:
			size = ins_max
		else:
			size = ins_size-((current_ins)*ins_max)
	Calculate.remove_children(group)
	if size > 0:
		var btn = load("res://addons/mgf_tools/BtnStt.tscn")
		var ins
		await get_tree().create_timer(0).timeout
		for i in size:
			ins = btn.instantiate()
			group.add_child(ins)
			ins.text = str(i+1+current_ins*ins_max)
			ins.connect("pressed", Callable(self, "tab_select").bind(int(ins.text)-1))
		await get_tree().create_timer(0).timeout
		if isIns == false:
			set_btn_active(current_tab)
		else:
			var x = abs(current_tab-(current_ins*ins_max))
			if x >= group.get_child_count():
				x = 0
			set_btn_active(x)

func btn_ins_visible(value:bool = false):
	$BtnL.visible = value
	$BtnR.visible = value
