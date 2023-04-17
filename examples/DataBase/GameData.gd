extends Node

const userPath = "user://"
const seasonFolder = "save/season"
const dotType = ".json"
const default_path = "user://save/defaultData.json"
const data_path = "user://save/baseData.json"
const account_data_path = "user://save/accountData.json"
const player_data_path = "user://playersData.json"
const team_data_path = "user://save/teamData.json"
const seasonName = "seasonData"
const setting_data_path = "user://save/settingData.json"


func get_filelist(scan_dir : String) -> Array:
	var my_files : Array = []
	var dir := DirAccess.open(scan_dir)
	if dir.current_is_dir() == false:
		printerr("Warning: could not open directory: ", scan_dir)
		return []
	
	if dir.list_dir_begin()  != OK:# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		printerr("Warning: could not list contents of: ", scan_dir)
		return []
	
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name)
		else:
			my_files.append(dir.get_current_dir() + "/" + file_name)
	
		file_name = dir.get_next()

	return my_files

func list_files(path):
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func folder_create(folder):
	DirAccess.make_dir_absolute("user://"+folder+"/")

func folder_remove(path):
	DirAccess.remove_absolute(path)

func get_data(data_path):
	var file = FileAccess.open(data_path, FileAccess.READ)
#	file.close()
	
	var json_data = JSON.new()
	json_data.parse(file.get_as_text())
	var parse_result = json_data.get_data()
	
#	if parse_result != OK:
#		print("Error %s reading json file." % parse_result)
#		return
	
	return parse_result

func save_data(data_path,value):
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
#	if Global.device_is_mobile():
#		file.open_encrypted_with_pass(data_path, File.WRITE, Global.password)
#	else:
#		file.open(data_path, File.WRITE)

func check_ver():
	var data = get_data(GameData.data_path)
	var oldVer = data.settings.ver
	var newVer = FileData.db.settings.ver

	if not FileAccess.file_exists(data_path):
		print("New Update")
		create_new_data_ver()
	elif int(newVer) > int(oldVer):
		print("New Update")
		create_new_data_ver()
	elif int(newVer) < int(oldVer):
		print("Error, update")
		create_new_data_ver()
	else:
		print("Check Done")
		
	newVer = oldVer
	
	SeasonData.ss = data.settings.season
	return newVer

func create_file_data():
	folder_create("save")
	if not FileAccess.file_exists(default_path):
		save_data(default_path,FileData.db)
	if not FileAccess.file_exists(data_path):
		save_data(data_path,FileData.db)

func data_clear_all(path):
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	SeasonData.isSkip = false
	
	var files = get_filelist(path)
	for i in files.size():
		var clearPath = files[i]
		DirAccess.remove_absolute(clearPath)
	
	create_file_data()

func create_new_data_ver():
	data_clear_all(userPath)
	save_data(default_path,FileData.db)
	save_data(data_path,FileData.db)

func save_game_speed(value):
	var data = get_data(GameData.data_path)
	data.settings.gameSpeed = str(value)
	
	save_data(data_path,data)

func return_game_speed_data():
	var gameData = get_data(GameData.data_path)
	var speedData = gameData.settings.gameSpeed
	return speedData

func season_get_file_path():
	folder_create(seasonFolder)
	var data = get_data(data_path)
	var season = data.settings.season
	if data.settings.seasons.size()>0:
		var seasons = data.settings.seasons[season]
		var filePath = userPath + seasonFolder + "/" + seasonName + str(seasons)+ dotType
		return filePath
	else:
		return data_path
#	return data_path

func fix_data():
	var data = get_data(data_path)
#	var season = data.settings.season
	var seasons = data.settings.seasons
#	print(season," ",seasons)
	if seasons.size()>0:
		var files = list_files(userPath + seasonFolder + "/")
		if seasons.size() > files.size():
			var count = seasons.size()-files.size()
			for i in count:
				seasons.pop_back()
			data.settings.season = files.size()-1
#			print(season," ",seasons)
			GameData.save_data(GameData.data_path,data)

func season_load_data():
	return get_data(season_get_file_path())

func season_save_data(save):
	save_data(season_get_file_path(),save)

func formation_load_data():
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		return get_data(season_get_file_path())
	else:
		return get_data(data_path)

func formation_save_data(save):
	if Global.MGFMode == Global.Season or Global.MGFMode == Global.SeasonMatch:
		save_data(season_get_file_path(),save)
	else:
		save_data(data_path,save)

func load_teamStats_data(obj,value):
	var playerData = formation_load_data()
	var teamData = playerData.teams[value].Fid
	var newPlayer
	var playerID
	
	if teamData.size() > 0:
		newPlayer = int(teamData[0])
		playerID = playerData.players[newPlayer]

		var atk = 0
		var mid = 0
		var def = 0

		var _atkCount = 0
		var _midCount = 0
		var _defCount = 0

		## Tao cau thu lay chi so
		for i in teamData.size():
			newPlayer = teamData[i]
			playerID = playerData.players[int(newPlayer)]
			var playerPos = playerID.Team[1]
			if playerPos == "GK":
				def += float(playerID.Overall[4])
				_defCount += 1
			elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
				def += float(playerID.Overall[3])
				obj.get_node("teamDef").text = str(round(def/4))
				_defCount += 1
			elif playerPos == "CM":
				mid += float(playerID.Overall[2])
				obj.get_node("teamMid").text = str(round(mid/1))
				_midCount += 1
			elif playerPos == "LF" or playerPos == "RF":
				atk += float(playerID.Overall[1])
				obj.get_node("teamAtk").text = str(round(atk/2))
				_atkCount += 1
		## Khong co cau thu chi so = 0
		if _defCount == 0:
			obj.get_node("teamDef").text = str(0)
		if _midCount == 0:
			obj.get_node("teamMid").text = str(0)
		if _atkCount == 0:
			obj.get_node("teamAtk").text = str(0)
		
		atk = float(obj.get_node("teamAtk").text)
		mid = float(obj.get_node("teamMid").text)
		def = float(obj.get_node("teamDef").text)

		obj.get_node("teamOve").text = str(round((atk + mid + def)/3))

		Calculate.stat_color(obj.get_node("teamOve"))
		Calculate.stat_color(obj.get_node("teamAtk"))
		Calculate.stat_color(obj.get_node("teamMid"))
		Calculate.stat_color(obj.get_node("teamDef"))

func return_radarStats_data(obj,value):
	var playerData = formation_load_data()
	var teamData = playerData.teams[value].Fid
	var newPlayer
	var playerID
	
	if teamData.size() > 0:
		newPlayer = int(teamData[0])
		playerID = playerData.players[newPlayer]

		var atk = 0
		var mid = 0
		var def = 0
		var gk = 0
		var spe = 0
		var sho = 0
		var tec = 0
		var phy = 0

		var _atkCount = 0
		var _midCount = 0
		var _defCount = 0
		var _gkCount = 0
		
		## Tao cau thu lay chi so
		for i in teamData.size():
			newPlayer = teamData[i]
			playerID = playerData.players[int(newPlayer)]
			var playerPos = playerID.Team[1]
			
			if playerPos == "GK":
				gk += float(playerID.Overall[4])
				obj.stats[4] = (gk/1)
				_gkCount += 1
			elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
				def += float(playerID.Overall[3])
				tec += float((playerID.Stat[2]+playerID.Stat[3])/2.0)
				phy += float((playerID.Stat[7]+playerID.Stat[6]+playerID.Stat[4])/3.0)
				obj.stats[1] = (tec/3)
				obj.stats[2] = (phy/3)
				obj.stats[3] = (def/3)
				_defCount += 1
			elif playerPos == "CM" or playerPos == "LF" or playerPos == "RF":
				atk += float(playerID.Overall[1])
				mid += float(playerID.Overall[2])
				sho += float((playerID.Stat[0]+playerID.Stat[1])/2.0)
				spe += float(playerID.Stat[5])
				obj.stats[0] = (mid/3)
				obj.stats[5] = (spe/3)
				obj.stats[6] = (sho/3)
				obj.stats[7] = (atk/3)
				_atkCount += 1
				#["MID","TEC","PHY","DEF","GK","SPE","SHO","ATK"]
			
			
		if _gkCount == 0:
			obj.stats[4] = 0
		if _defCount == 0:
			obj.stats[1] = 0
			obj.stats[2] = 0
			obj.stats[3] = 0
		if _atkCount == 0:
			obj.stats[0] = 0
			obj.stats[5] = 0
			obj.stats[6] = 0
			obj.stats[7] = 0
		
		obj.update_radar_stats()

func return_radarStats_player(obj,value):
	var playerData = formation_load_data()
	
	## Tao cau thu lay chi so
	var playerID = playerData.players[int(value)]
	
#	["MID","TEC","PHY","DEF","GK","SPE","SHO","ATK"]
#	["statFinishing": 0,"statShotPower": 1,"statAccurate": 2,"statBallControl": 3,
#	"statStamina": 4,"statSpeed": 5,"statPower": 6,"statBody": 7,
#	"statTackle": 8,"statDefend": 9,"statSave": 10,"statReflexes": 11]
	obj.stats[0] = playerID.Overall[2]
	obj.stats[1] = round((playerID.Stat[2]+playerID.Stat[3])/2.0)
	obj.stats[2] = round((playerID.Stat[7]+playerID.Stat[6]+playerID.Stat[4])/3.0)
	obj.stats[3] = playerID.Overall[3]
	obj.stats[4] = playerID.Overall[4]
	obj.stats[5] = playerID.Stat[5]
	obj.stats[6] = round((playerID.Stat[0]+playerID.Stat[1])/2.0)
	obj.stats[7] = playerID.Overall[1]
	
	obj.update_radar_stats()

func return_teamStats_data(team, stats):
	var data = formation_load_data()
	var teamData = data.teams[team].Fid
	var newPlayer
	var playerID
	if teamData.size() > 0:
		newPlayer = int(teamData[0])
		playerID = data.players[newPlayer]
		
#		var obj = 0
		var atk = 0
		var mid = 0
		var def = 0
		var gk = 0

		var _gkCount = 0
		var _atkCount = 0
		var _midCount = 0
		var _defCount = 0
	
		## Tao cau thu lay chi so
		for i in teamData.size():
#		for i in count:
			newPlayer = teamData[i]
			playerID = data.players[int(newPlayer)]
			var playerPos = playerID.Team[1]
			if playerPos == "GK":
				gk += float(playerID.Overall[4])*2.0
				def += float(playerID.Overall[3])
				mid += float(playerID.Overall[2])
#				_gkCount += 1
			elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
				def += float(playerID.Overall[3])*3.0
				mid += float(playerID.Overall[2])
				atk += float(playerID.Overall[1])
#				_defCount += 1
			elif playerPos == "CM":
				def += float(playerID.Overall[3])*2
				mid += float(playerID.Overall[2])*3.0
				atk += float(playerID.Overall[1])*2
#				_midCount += 1
			elif playerPos == "LF" or playerPos == "RF":
				mid += float(playerID.Overall[2])
				atk += float(playerID.Overall[1])*3.0
				def += float(playerID.Overall[3])
#				_atkCount += 1
		## Khong co cau thu chi so = 0
#		if _gkCount == 0:
#			gk = 0
#		if _defCount == 0:
#			def = 0
#		elif _midCount == 0:
#			mid = 0
#		elif _atkCount == 0:
#			atk = 0
		
		match stats:
			0:
				return round(((gk/2.0) + (atk/10.0) + (mid/9.0) + (def/14.0))/4)
			1:
				return round(def/13.7)
			2:
				return round(mid/9.0)
			3:
				return round(atk/10.2)
			4:
				return round(gk/2.0)

func load_game_settings():
	var data = get_data(GameData.data_path).settings
	Global.teamID1 = int(data.teamA)
	Global.teamID2 = int(data.teamB)
	Global.gameModeCur = int(data.gameMode)
	Global.SetTime = int(data.timeMode)
	Global.staCur = int(data.stadiumSet)
#	Global.ball = data.ballSet
#	Global.staCur = data.isVolume
#	Global.staCur = data.isMusic
#	Global.staCur = data.isTutorial
	pass

func save_game_settings():
	var data = get_data(GameData.data_path)
	var save_game_Data = data.settings
	save_game_Data.teamA = Global.teamID1
	save_game_Data.teamB = Global.teamID2
	save_game_Data.gameMode = Global.gameModeCur
	save_game_Data.timeMode = Global.SetTime
	save_game_Data.stadiumSet = Global.staCur
#	save_game_Data.ballSet = Global.ball
#	save_game_Data.isVolume = Global.staCur
#	save_game_Data.isMusic = Global.staCur
#	save_game_Data.isTutorial = Global.staCur
	save_data(GameData.data_path,data)
