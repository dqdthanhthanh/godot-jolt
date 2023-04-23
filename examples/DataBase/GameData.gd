extends FileData

const user_path:String = "user://"
const dot_type:String = ".json"
const default_path:String = "user://save/default.json"
const data_path:String = "user://save/base.json"
const setting_data_path:String = "user://save/setting.json"
const account_data_path:String = "user://save/account.json"
const player_data_path:String = "user://save/player.json"
const team_data_path:String = "user://save/team.json"
const item_data_path:String = "user://save/item.json"
const achi_data_path:String = "user://save/achi.json"
const noti_data_path:String = "user://save/noti.json"
const season_file:String = "seasonData"
const season_folder:String = "save/season"

static func get_filelist(scan_dir : String) -> Array:
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

static func list_files(path) -> Array:
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

static func folder_create(folder) -> void:
	DirAccess.make_dir_absolute("user://"+folder+"/")

static func folder_remove(path) -> void:
	DirAccess.remove_absolute(path)

static func get_data(data_path):
	var file
	if Global.device_is_mobile():
		file = FileAccess.open(data_path, FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(data_path, FileAccess.READ, Global.password)
#		OS.get_unique_ID()
	file = FileAccess.open_encrypted_with_pass(data_path, FileAccess.READ, Global.password)
	var json_data = JSON.new()
	json_data.parse(file.get_as_text())
	var parse_result = json_data.get_data()
	return parse_result

static func save_data(data_path,value) -> void:
	var file
	if Global.device_is_mobile():
		file = FileAccess.open(data_path, FileAccess.WRITE)
	else:
		file = FileAccess.open_encrypted_with_pass(data_path, FileAccess.WRITE, Global.password)
	file.store_string(JSON.stringify(value))

func create_file_data() -> void:
	folder_create("save")
	folder_create("save/replay")
	folder_create("save/season")
#	if not FileAccess.file_exists(default_path):
#		save_data(default_path,self.db)
	if not FileAccess.file_exists(data_path):
		save_data(data_path,self.base)
	if not FileAccess.file_exists(account_data_path):
		save_data(account_data_path,self.account)
	if not FileAccess.file_exists(setting_data_path):
		save_data(setting_data_path,self.settings)
	if not FileAccess.file_exists(player_data_path):
		save_data(player_data_path,self.players)
	if not FileAccess.file_exists(team_data_path):
		save_data(team_data_path,self.teams)
	if not FileAccess.file_exists(achi_data_path):
		save_data(achi_data_path,self.achievement)
	if not FileAccess.file_exists(noti_data_path):
		save_data(noti_data_path,[])
	if not FileAccess.file_exists(item_data_path):
		save_data(item_data_path,self.item)

func data_clear_all(path) -> void:
	SeasonData.TabManager = 0
	SeasonData.MatchDay = 0
	SeasonData.isSkip = false
	
	var files = get_filelist(path)
	for i in files.size():
		var clearPath = files[i]
		DirAccess.remove_absolute(clearPath)
	
	create_file_data()

func create_new_data_ver() -> void:
	data_clear_all(user_path)
#	save_data(default_path,self.db)
	save_data(data_path,self.base)
	save_data(account_data_path,self.account)
	save_data(setting_data_path,self.settings)
	save_data(player_data_path,self.players)
	save_data(team_data_path,self.teams)
	save_data(achi_data_path,self.achievement)
	save_data(noti_data_path,[])
	save_data(item_data_path,self.item)

static func save_game_speed(value) -> void:
	var data = get_data(setting_data_path)
	data.gameSpeed = str(value)
	
	save_data(setting_data_path,data)

static func return_game_speed_data():
	var gameData = get_data(setting_data_path)
	var speedData = gameData.gameSpeed
	return speedData

static func season_get_file_path():
	folder_create(season_folder)
	var data = get_data(setting_data_path)
	var season = data.season
	if data.seasons.size()>0:
		var seasons = data.seasons[season]
		var filePath = user_path + season_folder + "/" + season_file + str(seasons)+ dot_type
		return filePath
	else:
		return data_path

static func fix_data() -> void:
	var data = get_data(setting_data_path)
	var seasons = data.seasons
	if seasons.size()>0:
		var files = list_files(user_path + season_folder + "/")
		if seasons.size() > files.size():
			var count = seasons.size()-files.size()
			for i in count:
				seasons.pop_back()
			data.season = files.size()-1
			save_data(setting_data_path,data)

static func season_load_data():
	return get_data(season_get_file_path())

static func season_save_data(save) -> void:
	save_data(season_get_file_path(),save)

static func formation_load_data():
	if SeasonData.check_season_mode() == true:
		return get_data(season_get_file_path())
	else:
		return get_data(data_path)

static func formation_save_data(save) -> void:
	if SeasonData.check_season_mode() == true:
		save_data(season_get_file_path(),save)
	else:
		save_data(data_path,save)

static func load_teamStats_data(obj,value) -> void:
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

static func return_radarStats_data(obj,value) -> void:
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
				tec += float((playerID.Stat[3]+playerID.Stat[4])/2.0)
				phy += float((playerID.Stat[7]+playerID.Stat[6]+playerID.Stat[5])/3.0)
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

static func return_radarStats_player(obj,value) -> void:
	var playerData = formation_load_data()
	
	## Tao cau thu lay chi so
	var playerID = playerData.players[int(value)]
	
#	["MID","TEC","PHY","DEF","GK","SPE","SHO","ATK"]
#	["statFinishing": 0,"statShotPower": 1,"statSpeed": 2,"statAccurate": 3,
#	"statBallControl": 4,"statStamina": 5,"statPower": 6,"statBody": 7,
#	"statTackle": 8,"statDefend": 9,"statSave": 10,"statReflexes": 11]
	obj.extra.show()
	
	obj.statsMax[0] = playerID.Max[2]
	obj.statsMax[1] = playerID.Max[2]
	obj.statsMax[2] = playerID.Max[3]
	obj.statsMax[3] = playerID.Max[3]
	obj.statsMax[4] = playerID.Max[4]
	obj.statsMax[5] = round((playerID.Max[0]+playerID.Max[1])/2)
	obj.statsMax[6] = playerID.Max[1]
	obj.statsMax[7] = playerID.Max[1]

	obj.stats[0] = playerID.Overall[2]
	obj.stats[1] = round((playerID.Stat[3]+playerID.Stat[4])/2.0)
	obj.stats[2] = round((playerID.Stat[7]+playerID.Stat[6]+playerID.Stat[5])/3.0)
	obj.stats[3] = playerID.Overall[3]
	obj.stats[4] = playerID.Overall[4]
	obj.stats[5] = playerID.Stat[2]
	obj.stats[6] = round((playerID.Stat[0]+playerID.Stat[1])/2.0)
	obj.stats[7] = playerID.Overall[1]
	
	obj.update_radar_stats()

static func return_teamStats_data(team, stats):
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

static func sound_set(bus, data) -> void:
	if data > 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), remap(data,0,100,-16,0))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), false)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), true)

static func load_game_settings() -> void:
	var data = get_data(setting_data_path)
	Global.teamID1 = int(data.teamA)
	Global.teamID2 = int(data.teamB)
#	Global.gameModeCur = int(data.gameMode)
	Global.timeCur = int(data.timeMode)
	Global.staCur = int(data.stadiumSet)
#	Global.ball = data.ballSet
#	Global.staCur = data.isTutorial
	sound_set("Master",data.sound[0])
	sound_set("Music",data.sound[1])
	sound_set("Sound",data.sound[2])
	sound_set("GameSFX",data.sound[3])
	sound_set("MatchVoice",data.sound[4])

static func save_game_settings() -> void:
	var data = get_data(setting_data_path)
	data.teamA = Global.teamID1
	data.teamB = Global.teamID2
#	data.gameMode = Global.gameModeCur
	data.timeMode = Global.timeCur
	data.stadiumSet = Global.staCur
#	data.ballSet = Global.ball
#	data.isVolume = Global.staCur
#	data.isMusic = Global.staCur
#	data.isTutorial = Global.staCur
	save_data(setting_data_path,data)

static func player_data_synchronization() -> void:
	var data = formation_load_data()
	var basedata = get_data(data_path)
	var new:Array = []
	var count:int
	if data.players.size() < basedata.players.size():
		count = basedata.players.size() - data.players.size()
		prints("Run",count)
		for i in count:
			new.append(basedata.players[data.players.size()+i])
	for i in new.size():
		data.players.append(new[i])
	formation_save_data(data)

static func play_game_guide(value:bool = false) -> void:
	var data = get_data(setting_data_path)
	if data.Guide == false or value == true:
		Global.isGuide = true
		Global.GuideIndex = 0
		Global.gameModeCur = 2
		Global.timeCur = 0
		Global.MatchPlay = 1
		SceneTransition.change_scene_to_file("res://MGF Scene/MainGame.tscn")
