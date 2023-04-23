extends Panel

@onready var MainGame: = get_parent().get_parent().get_parent()
@onready var UI: = get_parent().get_parent()

@onready var btnClose: = $Panel/Label/ClosePanel

@onready var insRoot: = $Panel/VScrollBarBXH/GridContainer

var insID:int = 0
var teamID:int
var test:bool = false
var data:Dictionary
var points:Array
var pointstest:Array
var newpoints:Array

@onready var tween:Tween = $Tween

func _ready() -> void:
	if test == true:
		load_setup(0)

func load_setup(team) -> void:
	show()
	creat_player_data(team)

func str_round(value) -> String:
	return str(round(float(value)))

func creat_player_data(team) -> void:
	teamID = team
	if insRoot.get_child_count()>0:
		for i in insRoot.get_children():
			i.queue_free()
		
	data = GameData.season_load_data()
# warning-ignore:shadowed_variable
	for i in data.teams[team].Fid.size():
		var id  = data.teams[team].Fid[i]
		var playerData = data.players[id]
		var creStats
		if playerData.Available == true:
			insID = int(playerData.PlayerID)
			creStats = load("res://MGF Scene/Market/PlayerData.tscn").instantiate()
			creStats.get_node("Button/name").text = str(playerData.Name)
			creStats.get_node("Button/id").text = str(playerData.PlayerID)
			creStats.get_node("Button/pos").text = str(playerData.Team[2])
			creStats.get_node("Button/check").text = str(playerData.Team[0])
			creStats.get_node("Button/price/transfer").text = str(playerData.Price[1])
			creStats.get_node("Button/price/transfer").hide()
			creStats.get_node("Button/price/Icon").hide()
			creStats.get_node("Button/image").texture = Player.load_image(playerData.Icon)
			
#	["statFinishing": 0,"statShotPower": 1,"statAccurate": 2,"statBallControl": 3,
#	"statStamina": 4,"statSpeed": 5,"statPower": 6,"statBody": 7,
#	"statTackle": 8,"statDefend": 9,"statSave": 10,"statReflexes": 11]
			creStats.get_node("Button/ov").text = str_round(playerData.Overall[0])
			creStats.get_node("Button/f").text = str_round(playerData.Overall[1])
			creStats.get_node("Button/m").text = str_round(playerData.Overall[2])
			if creStats.get_node("Button/pos").text != "GK":
				creStats.get_node("Button/d").text = str_round(playerData.Overall[3])
			else:
				creStats.get_node("Button/d").text = str_round(playerData.Overall[4])
			
			Calculate.stat_color(creStats.get_node("Button/ov"))
			Calculate.stat_color(creStats.get_node("Button/f"))
			Calculate.stat_color(creStats.get_node("Button/m"))
			Calculate.stat_color(creStats.get_node("Button/d"))
			Calculate.position_color(creStats.get_node("Button/pos"))
			
			creStats.get_node("Button/background").texture = Team.load_team_icon(data.teams[team].icon)
			
			creStats.get_node("Button/point").show()
			creStats.get_node("Button/point/info/=").text = str(abs(playerData.Performance[0]))
			if playerData.Performance[0] >= 0:
				creStats.get_node("Button/point/info/+").text = "+"
			else:
				creStats.get_node("Button/point/info/+").text = "-"
			
			newpoints.append([0,0,0,0,0])
			for n in playerData.Overall.size():
				if playerData.Overall[n]-int(playerData.Overall[n]) > 0:
					newpoints[i][n] = (playerData.Overall[n]-int(playerData.Overall[n]))*100
			
			points.append(playerData.Performance)
			
			value(tween,creStats.get_node("Button/point/timeBar"),0,100)
			
			insRoot.call_deferred("add_child", creStats)
			creStats.get_node("Button/point/bar").value = newpoints[i][0]
	if test == false:
		save_player_performance(team)

func _on_ClosePanel_pressed() -> void:
	if test == false:
		hide()
		SceneTransition.transition()
		await get_tree().create_timer(0.5).timeout
		UI.MatchList.show()

func save_player_performance(team) -> void:
	var newdata = GameData.formation_load_data()
	for i in newdata.teams[team].Fid.size():
		var id  = newdata.teams[team].Fid[i]
		var playerData = newdata.players[id]
		var point = playerData.Performance
		var stat = playerData.Max
		## Tinh stats
		playerData.Stat[2] += float((point[0] + point[1])*1.0/2.0)
		playerData.Stat[5] += point[0]
		# ATK
		playerData.Stat[0] += point[1]
		playerData.Stat[1] += float((point[1] + point[2])*1.0/2.0)
		# Mid
		playerData.Stat[3] += point[2]
		playerData.Stat[4] += point[2]
		# Def
		playerData.Stat[6] += point[3]
		playerData.Stat[7] += point[3]
		playerData.Stat[8] += point[3]
		playerData.Stat[9] += point[3]
		#GK
		if playerData.Team[1] == "GK":
			playerData.Stat[10] += point[4]
			playerData.Stat[11] += point[4]
		for n in playerData.Overall.size():
			playerData.Overall[n] += point[n]
			playerData.Performance[n] = 0
		
	GameData.formation_save_data(newdata)

func save_player_point() -> void:
	var fulltime = MainGame.gameRound * 2.0
	var newdata = GameData.season_load_data()
	for unit in MainGame.units:
		var ID = unit.playerID
		var playerPoint = newdata.players[ID].Performance
		var stat = newdata.players[ID].Max
		var ratio:float = 1.5
		var Max = remap(unit.playerData.Overall[0],40,100,1.0,0.5)
		Max = clamp(Max,0.5,1.0)
		var Base = remap(unit.playerData.Overall[0],40,100,2.0,3.0)
		Base = clamp(Base,2.0,4.0)
		var point = remap(unit.matchPoints,Base,10.0,-Max/ratio,Max/ratio)
		if unit.statsPlayTime > 0:
			var time = unit.statsPlayTime/fulltime
			playerPoint[0] = float("%.2f" % (point*stat[0]/90*time))
			playerPoint[1] = float("%.2f" % (point*stat[1]/90*time))
			playerPoint[2] = float("%.2f" % (point*stat[2]/90*time))
			playerPoint[3] = float("%.2f" % (point*stat[3]/90*time))
			if newdata.players[ID].Team[1] == "GK":
				playerPoint[4] = float("%.2f" % (point*stat[4]/90*time))
			else:
				playerPoint[4] = 0
		else:
			playerPoint = [0,0,0,0,0]
	GameData.season_save_data(newdata)

func _on_Tween_tween_all_completed() -> void:
	for i in data.teams[teamID].Fid.size():
		var id  = data.teams[teamID].Fid[i]
		var playerData = data.players[id]
		var child = insRoot.get_child(i)
		
		if check(child) == true:
			stats_value(child.get_node("Button/ov"),1,i,0,true)
			stats_value(child.get_node("Button/f"),1,i,1)
			stats_value(child.get_node("Button/m"),1,i,2)
			if child.get_node("Button/pos").text != "GK":
				stats_value(child.get_node("Button/d"),1,i,3)
			else:
				stats_value(child.get_node("Button/d"),1,i,4)
			
			Calculate.stat_color(child.get_node("Button/ov"))
			Calculate.stat_color(child.get_node("Button/f"))
			Calculate.stat_color(child.get_node("Button/m"))
			Calculate.stat_color(child.get_node("Button/d"))
			
			if points[i][0] > 0.1:
				value(tween,child.get_node("Button/point/timeBar"),0,100)
			elif points[i][0] < 0:
				value(tween,child.get_node("Button/point/timeBar"),0,100)

func value(t,obj,x,y) -> void:
	t.interpolate_property(obj, "value",
			x, y, 0.01,
			Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	t.start()

func stats_value(stats,value,i,child,up:bool = false) -> void:
	if int(stats.text) < 99:
		if points[i][child] > 0:
			points[i][child] -= 0.1
			newpoints[i][child] += 10
			if up == true:
				points[i][child] = 0
				insRoot.get_child(i).get_node("Button/point/bar").value = newpoints[i][child]
			if newpoints[i][child] >= 100:
				newpoints[i][child] = 0
				stats.text = str(int(stats.text) + 1)
		elif points[i][child] < 0:
			points[i][child] += 0.1
			newpoints[i][child] -= 10
			if up == true:
				points[i][child] = 0
				insRoot.get_child(i).get_node("Button/point/bar").value = newpoints[i][child]
			if newpoints[i][child] < 0:
				newpoints[i][child] = 90
				stats.text = str(int(stats.text) - 1)

func check(child,Max:int = 99) -> bool:
	var value:bool
	if (int(child.get_node("Button/ov").text) == Max):
		value = false
	else:
		value = true
	return value

func stats_point(stats,value,Max:int = 99) -> void:
	if int(stats.text) < Max:
		stats.text = str(int(stats.text) + value)

func _exit_tree():
	queue_free()
