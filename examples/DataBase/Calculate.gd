extends Node

var rng = RandomNumberGenerator.new()

func return_day():
#	var timeDict = Time.get_datetime_dict_from_system();
#	var day = str(timeDict.day);
#	var month = str(timeDict.month);
#	var year = str(timeDict.year);
#
#	if day.length() < 2:
#		day = "0" + day
#	if month.length() < 2:
#		month = "0" + month
	
#	return day+"/"+month+"/"+year
	return "20/10/2023"

func return_time():
#	var unix_time: float = Time.get_unix_time_from_system()
#	var datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
#
##	var time = OS.get_time()
#	var hour = String(datetime_dict.hour)
#	var minute = String(datetime_dict.minute)
#	var _second = String(datetime_dict.second)
#
#	if hour.length() < 2:
#		hour = "0" + hour
#	if minute.length() < 2:
#		minute = "0" + minute
#
#	return hour+":"+minute
	return "30"+":"+"00"

func tweenUIy(t,a,b,value):
	t.interpolate_property(a, "position",
			a.position, b, value,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t.start()

func tweenFadeOut(t,a,time):
	t.interpolate_property(a, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t.start()

func tweenShowOut(t,a,time):
	t.interpolate_property(a, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t.start()

func tweenValue(t,obj,x):
	t.interpolate_property(obj, "value",
			obj.value, x, 2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t.start()

## Lay huong tu drag input
#if event is InputEventSingleScreenDrag:
#	label.text = str(event.position) + " " + str(event.relative)
#	print(rad_to_deg(event.relative.angle()))

func timeout(value):
	await get_tree().create_timer(value).timeout

func timer(obj,value):
	obj.wait_time = value
	obj.start()

func in_range(value,a,b):
	if value >= float(a) and value < float(b):
		return true
	else:
		return false

func vibrate_set():
	if Global.device_is_mobile():
		Input.vibrate_handheld(500)

func rand_num(value):
	rng.randomize()
	var number = rng.randf_range(-value, value)
	return number

func rand_a_num(a,b):
	rng.randomize()
	var number = rng.randf_range(a, b)
	return number

func rand_int(value):
	rng.randomize()
	var number = rng.randi_range(-value, value)
	return number

static func swap(a, b):
	var tmpA = a
	var tmpB = b
	a = tmpB
	b = tmpA

func return_swap_value(value):
	var A = value
	return A

## Cac Ham xu ly chi so
func return_Overall(playerPosition,playerPositionMatch,fI,shP,iT,pA,sP,bC,sT,pO,bO,rF,dF,pE):
	var value = playerPositionMatch
	var playerOverall
	var statFinishing = float(fI)
	var statShotPower = float(shP)
	var statIntercep = float(iT) 
	var statAccurate = float(pA)
	var statSpeed = float(sP)
	var statBallControl = float(bC)
	var statStamina = float(sT)
	var statPower = float(pO)
	var statBody = float(bO)
	var statReflexes = float(rF)
	var statDefend = float(dF)
	var statSave = float(pE)
#	var statEnergy = eN
#	var statInjuryRate = iJ
	if value == "NON":
		value = playerPosition
	if value == "GK":
		playerOverall = round((statReflexes*8.0+statDefend*8.0+statSave*6.0+statAccurate/2.0+statSpeed/2.0+statStamina*2.0+statPower*2.0+statBody*2.0)/29)
	elif value == "CB" or value == "LB" or value == "RB":
		playerOverall = round((statIntercep*9+statAccurate+statSpeed*2+statBallControl+statStamina+statPower*4+statBody*3)/20)
	elif value == "WB":
		playerOverall = round((((statFinishing*4+statShotPower*2)/6*5+statShotPower*2)/7+statIntercep*6+statAccurate*3+statSpeed*3+statBallControl*2+statStamina*4+statPower+statBody)/20)
	elif value == "DM":
		playerOverall = round(((statFinishing*4+statShotPower*2)/5+statIntercep*4+statAccurate*5+statSpeed*2+statBallControl*4+statStamina*4+statPower+statBody)/21)
	elif value == "CM":
		playerOverall = round(((statFinishing*5+statShotPower)/5*2+statIntercep*3+statAccurate*5+statSpeed*2+statBallControl*3+statStamina*4+statPower+statBody)/20)
	elif value == "AM":
		playerOverall = round(((statFinishing*5+statShotPower*3.5)+statIntercep+statAccurate*4+statSpeed*2.0+statBallControl*2.0+statStamina*2.0+statPower+statBody)/20)
	elif value == "WM":
		playerOverall = round(((statFinishing*5+statShotPower)/6*2+statIntercep+statAccurate*3+statSpeed*8+statBallControl+statStamina*4+statPower+statBody)/20)
	elif value == "WF":
		playerOverall = round((statFinishing*7+statShotPower*2+statIntercep+statAccurate+statSpeed*6+statBallControl+statStamina*2+statPower+statBody)/20.8)
	elif value == "SS":
		playerOverall = round((statFinishing*8+statShotPower*2+statIntercep*2+statAccurate*2+statSpeed*5+statBallControl*2+statStamina+statPower+statBody)/22.5)
	elif value == "CF" or value == "LF" or value == "RF":
		playerOverall = round((statFinishing*21.0+statShotPower*2.0+statIntercep+statAccurate+statSpeed*2.0+statBallControl+statStamina+statPower+statBody)/30)
	elif value == "FW":
		playerOverall = round((statFinishing*8+statShotPower*2+statIntercep*2+statAccurate+statSpeed*2+statBallControl*3+statStamina+statPower*2+statBody)/20)
	if playerOverall > 99:
		playerOverall = 99
	
	return playerOverall

func return_Potential(aG,oV):
	var playerAge = float(aG)
	var playerOverall = float(oV)
	var playerPotential
	
	if playerAge > 35 or playerOverall in range(0,70):
		playerPotential = playerOverall

	elif playerAge in range(16,22) and playerOverall in range(70,80):
		playerPotential = playerOverall + 2
	elif playerAge in range(16,22) and playerOverall in range(80,85):
		playerPotential = playerOverall + 6
	elif playerAge in range(16,22) and playerOverall in range(85,90):
		playerPotential = playerOverall + 10
	elif playerAge in range(16,22) and playerOverall in range(90,100):
		playerPotential = playerOverall + 10

	elif playerAge in range(22,26) and playerOverall in range(70,80):
		playerPotential = playerOverall + 2
	elif playerAge in range(22,26) and playerOverall in range(80,85):
		playerPotential = playerOverall + 4
	elif playerAge in range(22,26) and playerOverall in range(85,90):
		playerPotential = playerOverall + 6
	elif playerAge in range(22,26) and playerOverall in range(90,100):
		playerPotential = playerOverall + 8

	elif playerAge in range(26,30) and playerOverall in range(70,80):
		playerPotential = playerOverall
	elif playerAge in range(26,30) and playerOverall in range(80,85):
		playerPotential = playerOverall + 2
	elif playerAge in range(26,30) and playerOverall in range(85,90):
		playerPotential = playerOverall + 4
	elif playerAge in range(26,30) and playerOverall in range(90,100):
		playerPotential = playerOverall + 5

	elif playerAge in range(30,35) and playerOverall in range(70,80):
		playerPotential = playerOverall
	elif playerAge in range(30,35) and playerOverall in range(80,85):
		playerPotential = playerOverall
	elif playerAge in range(30,35) and playerOverall in range(85,90):
		playerPotential = playerOverall + 2
	elif playerAge in range(30,35) and playerOverall in range(95,100):
		playerPotential = playerOverall + 3

	else:
		playerPotential = playerOverall

	if playerOverall >= 100 or playerPotential >= 100:
		playerPotential = 100
	
	return playerPotential

func stat_color(unit):
	var value = float(unit.text)
	if value >= 100:
		unit.modulate = Color.AQUA
	elif in_range(value,90,100):
		unit.modulate = Color.CYAN
	elif in_range(value,80,90):
		unit.modulate = Color.GREEN
	elif in_range(value,70,80):
		unit.modulate = Color.GOLD
	elif in_range(value,60,70):
		unit.modulate = Color.GOLD
	elif in_range(value,0,60):
		unit.modulate = Color.RED
#	else:
#		unit.modulate = Color.AQUAMARINE

func position_color(unit):
	var value = str(unit.text)
	if value == "GK":
		unit.modulate = Color.CYAN
	elif value == "CB" or value == "LB" or value == "RB" or value == "WB":
		unit.modulate = Color.DODGER_BLUE
	elif value == "CM" or value == "DM" or value == "AM" or value == "WM" or value == "LM" or value == "RM":
		unit.modulate = Color.GREEN
	elif value == "CF" or value == "WF" or value == "SS" or value == "FW" or value == "LF" or value == "RF":
		unit.modulate = Color.RED
	else:
		unit.modulate = Color.GOLD

func price_color(unit):
	unit.modulate = Color.GOLD


func player_point_up(id,point):
#	var pData:String
	if point > 0:
		var all = 0
		var po = 7-float(point)
		all -= float(po)
		point = all
	var data = GameData.season_load_data()
	var playerData = data.players[int(id)]
	var playerPos = playerData.Team[1]
#		pData = str(playerData.Name) + " "
	var o = playerData.Overall
	var oD = []
	for i in o.size():
		var a = o[i]
		oD.append(float(a))
#		pData += str(oD)
	var nD = []
	var n = 0
	for i in o.size():
#		var O = 100
		var O = o[0]
		var g = 22
		var p = point
		if p>0:
			if O < 60:
				n = remap(O,0,60,20*p,15*p)/g
			elif O >=60 and O < 80:
				n = remap(O,60,80,15*p,8*p)/g
			elif O >=80 and O < 90:
				n = remap(O,80,100,8*p,5*p)/g
			elif O >=90 and O < 100:
				n = remap(O,80,100,5*p,1*p)/g
			else:
				n = 0
		else:
			if O < 60:
				n = remap(O,0,60,2*p,3*p)/g
			elif O >=60 and O < 80:
				n = remap(O,60,80,3*p,5*p)/g
			elif O >=80 and O < 90:
				n = remap(O,60,80,8*p,12*p)/g
			elif O >=90 and O < 100:
				n = remap(O,10,100,12*p,15*p)/g
		n = float("%.2f" % n)
		n = clamp(n,-10.0,100.0)
		
		var a = o[i]
		
		if i == 0:
			a += n
		## Tinh theo vt
		if playerPos == "GK":
			if i == 1:
				a += n/4
			elif i == 2:
				a += n/3
			elif i == 3:
				a += n/2
			elif i == 4:
				a += n
		elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
			if i == 1:
				a += n/4
			elif i == 2:
				a += n/2
			elif i == 3:
				a += n
		elif playerPos == "CM":
			if i == 1:
				a += n/2
			elif i == 2:
				a += n
			elif i == 3:
				a += n/4
		elif playerPos == "RF" or playerPos == "LF":
			if i == 1:
				a += n
			elif i == 2:
				a += n/2
			elif i == 3:
				a += n/4
		a = clamp(a,0.0,99.0)
		nD.append(a)
	data.players[id].Overall = nD
	
	## All Stats
	var S = playerData.Stat
	var stats = []
	
	for i in S.size():
		if i < 13:
			var s = S[i]
			if i == 4 or i == 5 or i == 6 or i == 7:
				s += n/2
			elif i == 12:
				s += n/2
			## Tinh theo vt
			if playerPos == "GK":
				if i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n/2
				elif i == 10 or i == 11:
					s += n
			elif playerPos == "CB" or playerPos == "LB" or playerPos == "RB":
				if i == 0 or i == 1:
					s += n/4
				elif i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n
			elif playerPos == "CM":
				if i == 0 or i == 1:
					s += n/2
				elif i == 2 or i == 3:
					s += n
				elif i == 8 or i == 9:
					s += n/2
			elif playerPos == "RF" or playerPos == "LF":
				if i == 0 or i == 1:
					s += n
				elif i == 2 or i == 3:
					s += n/2
				elif i == 8 or i == 9:
					s += n/4
			s = clamp(s,0.0,99.0)
			stats.append(s)
	data.players[id].Stat = stats
	
	GameData.season_save_data(data)

#var playerStats = {
#	"Finishing": 0,"ShotPower": 1,
#
#	"Accurate": 2,"BallControl": 3,
#
#	"Stamina": 4,"Speed": 5,"Power": 6,"Body": 7,
#
#	"Tackle": 8,"Defend": 9,
#
#	"Save": 10,"Reflexes": 11}
