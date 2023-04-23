class_name Calculate


static func remove_children(obj) -> void:
	if obj.get_child_count()>0:
		for child in obj.get_children():
			child.queue_free()

static func return_day() -> String:
#	var timeDict = Time.get_datetime_dict_from_system();
#	var day = str(timeDict.day);
#	var month = str(timeDict.month);
#	var year = str(timeDict.year);
#
#	if day.length() < 2:
#		day = "0" + day
#	if month.length() < 2:
#		month = "0" + month
#
#	return day+"/"+month+"/"+year
	return "20/10/2023"

static func return_time() -> String:
#	var time = OS.get_time()
#	var hour = String(time.hour)
#	var minute = String(time.minute)
#	var _second = String(time.second)
#
#	if hour.length() < 2:
#		hour = "0" + hour
#	if minute.length() < 2:
#		minute = "0" + minute
	
#	return hour+":"+minute
	return "30"+":"+"00"

static func timer(obj,value) -> void:
	obj.wait_time = value
	obj.start()

static func in_range(value,a,b):
	if value >= float(a) and value < float(b):
		return true
	else:
		return false

static func vibrate_set() -> void:
	if Global.device_is_mobile():
		Input.vibrate_handheld(500)

static func rand_ratio(ratio) -> bool:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var ss = abs(rng.randf_range(-10, 10))
	if ss < ratio/10:
		return true
	else:
		return false

static func vector3_convert(vector:Vector3) -> Vector2:
	return Vector2(vector.x,vector.z)

static func random_in_size(size):
	randomize()
	var rand_value = size[randi() % size.size()]
	return rand_value

static func rand_num_f0(value):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randf_range(0, value)
	return number

static func rand_num(value):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randf_range(-value, value)
	return number

static func rand_int(value):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randi_range(-value, value)
	return number

static func rand_a_num(a,b):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randf_range(a, b)
	return number

static func swap(a, b) -> void:
	var tmpA = a
	var tmpB = b
	a = tmpB
	b = tmpA

static func return_swap_value(value):
	var A = value
	return A

## Cac Ham xu ly chi so
static func return_Overall(playerPosition,playerPositionMatch,fI,shP,iT,pA,sP,bC,sT,pO,bO,rF,dF,pE):
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

static func return_Potential(aG,oV):
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

static func stat_color(unit) -> void:
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

static func position_color(unit) -> void:
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

static func price_color(unit) -> void:
	unit.modulate = Color.GOLD
