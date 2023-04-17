@tool
extends Control

@onready var table = $Data/TabContainer
@onready var btnGroup = $Data/GroupBtn
@onready var filePopup = $FileDialog
@onready var pathInput = $Data/GroupFile/DataPathInput
@onready var saveData = $SaveData
@onready var maxText = $Data/GroupFile/MaxLoad
@onready var groups = $Data/GroupFile/Groups

var maxLoad = 10
var btnCount = 0

var default_data = {}
var data = {}

var groupID = 0

#var data_path = ""

var column = 0
@onready var tabs = preload("res://addons/mgf_json_table/assets/Tabs.tscn")
@onready var label = preload("res://addons/mgf_json_table/assets/Label.tscn")
@onready var box = preload("res://addons/mgf_json_table/assets/Box.tscn")
@onready var btn = preload("res://addons/mgf_json_table/assets/Button.tscn")
@onready var btnGroups = preload("res://addons/mgf_Json_table/assets/ButtonGroup.tscn")

func _ready():
	saveData.create_file_data()
	var SaveData = saveData.get_data()
	pathInput.text = SaveData.path
	table.current_tab = 0
	maxText.text = str(SaveData.maxLoad)
	maxLoad = int(maxText.text)
	if SaveData.path != "":
		data = get_data()
		if typeof(data) == 19:
			for i in get_data().size():
				var btnIns = btnGroups.instantiate()
				groups.add_child(btnIns)
				btnIns.text = str(i+1)
				btnIns.id = i
			data = get_data()[groupID]
#			print("true")
			for i in data.size():
				var tabsName = data.keys()[i]
				var tabsData = data.values()[i]
#				print(tabsName)
				var tabsIns = tabs.instantiate()
				table.add_child(tabsIns)
				tabsIns.name = tabsName
		else:
			for i in data.size():
				var tabsName = data.keys()[i]
				var tabsData = data.values()[i]
				var tabsIns = tabs.instantiate()
				table.add_child(tabsIns)
				tabsIns.name = tabsName
		reload_data(0,0)

func reload_data(id,btnID):
	if btnGroup.get_child_count()>0:
		for unit in btnGroup.get_children():
			unit.queue_free()
	var tableData = table.get_child(id).get_child(0).get_node("Table")
	if tableData.get_child_count() > 0:
		for unit in tableData.get_children():
			unit.queue_free()
	create_table_data(id,btnID)

func create_table_data(tbIndex, btnId):
	var tabCur = table.get_child(tbIndex)
#	if tabCur.get_child(0).get_child_count() > 0:
#		for unit in tabCur.get_child(0).get_children():
#			unit.queue_free()
#
	var tabCurData = data.values()[tbIndex]
	if typeof(tabCurData) == TYPE_ARRAY:
		print("tabCurData")
		var tabLabel = tabCurData[0].keys()
		var tableCollum = tabCur.get_child(0).get_node("Table")
		tableCollum.columns = tabLabel.size()+1
		
		var labelIns = label.instantiate()
		tableCollum.add_child(labelIns)
		labelIns.text = str("")
		
		for i in tabLabel.size():
			labelIns = label.instantiate()
			tableCollum.add_child(labelIns)
			labelIns.text = tabLabel[i]
		
		## Next Button
		if tabCurData.size() > maxLoad:
			btnCount = float(tabCurData.size())/float(maxLoad)
			btnCount = int(btnCount) + 1
			for i in btnCount:
				var btnIns = btn.instantiate()
				btnGroup.add_child(btnIns)
				btnIns.text = str(i)
				btnIns.id = i
#			print(maxLoad*btnId," ",maxLoad*(btnId+1))
			var btnMin = maxLoad*btnId
			var btnMax = maxLoad*(btnId+1)
			if btnMax > tabCurData.size():
				btnMax = tabCurData.size()
			for i in range(btnMin,btnMax):
				labelIns = label.instantiate()
				tableCollum.add_child(labelIns)
				labelIns.text = str(i)
				for n in tabCurData[i].values():
					var boxIns = box.instantiate()
					tableCollum.add_child(boxIns)
					boxIns.text = str(n)
		else:
			for i in tabCurData.size():
				labelIns = label.instantiate()
				tableCollum.add_child(labelIns)
				labelIns.text = str(i)
				for n in tabCurData[i].values():
					var boxIns = box.instantiate()
					tableCollum.add_child(boxIns)
					boxIns.text = str(n)
	
	elif typeof(tabCurData) == TYPE_DICTIONARY:
		var tabLabel = tabCurData.keys()
		var tableCollum = tabCur.get_child(0).get_node("Table")
		tableCollum.columns = tabLabel.size()+1
		
		var labelIns = label.instantiate()
		tableCollum.add_child(labelIns)
		labelIns.text = str("")
		
		for i in tabLabel.size():
			labelIns = label.instantiate()
			tableCollum.add_child(labelIns)
			labelIns.text = tabLabel[i]
			
		labelIns = label.instantiate()
		tableCollum.add_child(labelIns)
		labelIns.text = str("0")
			
		for n in tabCurData.values():
			var boxIns = box.instantiate()
			tableCollum.add_child(boxIns)
			boxIns.text = str(n)

func get_data():
#	var testPath = "res://DataBase/dataBaseDefault.json"
	var file = FileAccess.open(pathInput.text, FileAccess.READ)
#	file = null
	
	var json_data = JSON.new()
	json_data.parse(file.get_as_text())
	var parse_result = json_data.get_data()
	
#	if parse_result != OK:
#		print("Error %s reading json file." % parse_result)
#		return
	
	return parse_result

func reload_new_table():
	for i in data.size():
		var tabsName = data.keys()[i]
		var tabsData = data.values()[i]
		var tabsIns = tabs.instantiate()
		table.add_child(tabsIns)
		tabsIns.name = tabsName

func _on_Create_pressed():
	reload_data(0,0)

func _on_TabContainer_tab_selected(tab):
	reload_data(tab,0)

func _on_FileDialog_file_selected(path):
	maxLoad = int(maxText.text)
	var SaveData = saveData.get_data()
	SaveData.path = path
	saveData.save_data(SaveData)
	pathInput.text = SaveData.path
	if table.get_child_count()>0:
		for unit in table.get_children():
			unit.queue_free()
	
	data = get_data()
	if typeof(data) == 19:
		data = get_data()[groupID]
	
	reload_new_table()
	reload_data(table.current_tab,0)
#	OS.shell_open(path)

func _on_GameData_pressed():
	filePopup.popup()
	filePopup.access = 1

func _on_LoadProject_pressed():
	filePopup.popup()
	filePopup.access = 0

func _on_LoadLocal_pressed():
	filePopup.popup()
	filePopup.access = 2

func _on_Reload_pressed():
	var SaveData = saveData.get_data()
	SaveData.maxLoad = int(maxText.text)
	maxLoad = int(maxText.text)
	saveData.save_data(SaveData)
	
	data = get_data()
	if typeof(data) == 19:
		data = get_data()[groupID]
	reload_data(table.current_tab,0)

func _on_Continue_pressed():
#	print(data.values()[table.current_tab])
	var tach = table.get_child(table.current_tab).get_child(0).get_node("Table")
	var dat = data.values()[table.current_tab]
#	print(data.values()[3])
	var ss = dat[0].values()
	if tach.get_child_count() > 1:
		for unit in tach.get_children():
			unit.queue_free()
	tach.columns = 1
	for i in ss.size():
#		print(ss[2][0])
		if typeof(ss[i]) == 19:
			for n in ss[i].size():
	#			print(ss[0][n])
				var ins = box.instantiate()
				tach.add_child(ins)
				ins.text = str(ss[i][n])
