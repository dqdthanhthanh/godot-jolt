extends Control

var rng = RandomNumberGenerator.new()

"""
teamData form

Bo sung cau thu tre:
	random 2 cau thu

Tim cac vi tri can bo sung
	vi tri yeu
	vi tri tren 30t
	tim so vi tri can mua

Lay ngan sach chuyen nhuong
	ngan sach toi da can mua / so vi tri
	ngan sach 1 cau thu

Gui loi hoi mua cau thu
	Tra loi hoi dap:
		dong y
		tu choi

ket thuc chuyen nhuong

"""

class MyCustomSorter:
	static func sort_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			return true
		return false
		
	static func sort_gk_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			if a.Team[1] == "GK":
				return true
		return false
	static func sort_cb_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			if a.Team[1] == "CB" or a.Team[1] == "RB" or a.Team[1] == "LB":
				return true
		return false
	static func sort_cm_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			if a.Team[1] == "CM":
				return true
		return false
	static func sort_cf_stat(a,b):
		if float(a.Stat[0]) > float(b.Stat[0]):
			if a.Team[1] == "RF" or a.Team[1] == "LF":
				return true
		return false

func _ready() -> void:
	team_find_slot()

func team_find_slot():
	var data = GameData.season_load_data()
	var teamData = data.teams
	var playerData = data.players
	var team = 11
	var allPosOld = teamData[team].Fid
	var posNeed = []
	var mainTeam = [0,1,2,3,4,5,6,7]
	var finance = teamData[team].finance
	var popular = teamData[team].stats #teamStats,#damphan
	var teamStat = teamData[team].stats
	var teamPos = ["OV","CF","CM","CB","GK"]
	
	var dsBuy = []
	
	## Tim vi tri can mua
	for i in teamPos.size():
		if i > 0:
			var n = teamStat[i]
			if n < popular[1]:
				posNeed.append(teamPos[i])
	
	prints("_cac vi tri:",posNeed)
	## Lay ngan sach
	var ns = (finance[0]-finance[1])/1.5
	var allns = finance[0]-ns
	var nsTb = 0
	var size = 0
	
	## Lay danh sach can mua
#	for pN in posNeed.size():
	for n in posNeed.size():
#		print(posNeed[n])
		if ns > finance[1]/2:
			data = GameData.season_load_data()
			teamData = data.teams
			playerData = data.players
			size = (posNeed.size()-n)
			nsTb = ns/size
			prints("_ngan sach",round(nsTb),round(ns))
			var lhm = []
			var lhms = []
			## Tim cac doi tuong
			playerData.sort_custom(Callable(MyCustomSorter, "sort_stat"))
			for pl in playerData.size():
				var player = playerData[pl]
				if typeof(player.Team[0]) != 4:
					if posNeed[n] == "CF":
						if ((player.Team[1] == "RF" or player.Team[1] == "LF")):
							if playerData[pl].Team[0] != team:
								lhm = [playerData[pl].Team[0],playerData[pl].PlayerID,playerData[pl].Name]
								lhms.append(lhm)
					elif posNeed[n] == "CM":
						if ((player.Team[1] == "CM")):
							if playerData[pl].Team[0] != team:
								lhm = [playerData[pl].Team[0],playerData[pl].PlayerID,playerData[pl].Name]
								lhms.append(lhm)
					elif posNeed[n] == "CB":
						if ((player.Team[1] == "CB" or player.Team[1] == "RB" or player.Team[1] == "LB")):
							if playerData[pl].Team[0] != team:
								lhm = [playerData[pl].Team[0],playerData[pl].PlayerID,playerData[pl].Name]
								lhms.append(lhm)
					else:
						if ((player.Team[1] == "GK")):
							if playerData[pl].Team[0] != team:
								lhm = [playerData[pl].Team[0],playerData[pl].PlayerID,playerData[pl].Name]
								lhms.append(lhm)

			## Reload ds player
			data = GameData.season_load_data()
			teamData = data.teams
			playerData = data.players
			
			prints("_cac loi de nghi",lhms)
			
			## Loc danh sach tim dc:
			var dsMax = 3
			if lhms.size()>dsMax:
				for i in lhms.size():
					var player = round(Calculate.rand_a_num(0,lhms.size()))
					if i>2:
						if player<lhms.size():
							lhms.erase(lhms[lhms.size()-1])
			prints("_de nghi mua",lhms)
			
			var dsDone = []
			var time = 0
			var val = 0.0
			
			## Gui loi de nghi
			while dsDone.size()==0:
				time+=1
				for i in lhms.size():
					var a = rand_num(popular[0]/10)
					var b = rand_num(80/3)
					if a > b:
						dsDone.append(lhms[i])
						break
			
			## Mua cau thu:
			for i in dsDone.size():
				var player = playerData[dsDone[i][1]]
				val = ((time+1)*player.Price[1])/30.0
				var price = player.Price[1]/1.5+val
				var pName = player.Name
				ns -= round(price)
				prints("_tra gia: ",pName,round(price))
			
			prints("_so lan mua:",time,"gia them:",round(val))
			dsBuy.append(dsDone[0])
			prints("_mua duoc",dsDone)
			print("___")
		else:
			break
	prints("_all buy",dsBuy,allns+ns)
	print("___")

func rand_num(value):
	rng.randomize()
	var number = rng.randf_range(0, value)
	return number






