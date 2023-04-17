@tool
extends Node

var default_data = {"path":"","maxLoad":10}
var data = {}

var data_path = "res://addons/mgf_json_table/data/mgf_Json_table_data.js"
var default_data_path = "res://addons/mgf_json_table/data/mgf_Json_table_data.js"

func get_data():
#	var testPath = "res://DataBase/dataBaseDefault.json"
	var file = FileAccess.open(data_path, FileAccess.READ)
#	file = null
	
	var json_data = JSON.new()
	json_data.parse(file.get_as_text())
	var parse_result = json_data.get_data()
	
#	if parse_result != OK:
#		print("Error %s reading json file." % parse_result)
#		return
	
	return parse_result

func save_data(value):
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(JSON.new().stringify(value))
#	file = null

func create_file_data():
	if not FileAccess.file_exists(data_path):
		save_data(default_data)
