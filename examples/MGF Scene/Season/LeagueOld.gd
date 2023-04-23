extends Control

var team123 = ["CB",86,82,88]
var team0 = ["CB",86,82,88]
var team1 = ["KH",82,82,82]
var team2 = ["QP",77,78,77]
var team3 = ["New",60,60,60]
var team = [1,2,3,4,5,6,7,8,9,10,11,12]
var array = [0,1,2,2,2]
var arrayTest = [0,1,2,3,4,5,6,6,7,8,9,5,5,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

@onready var cont = $VScrollBar/VBoxContainer
@onready var bxh = $VScrollBarBXH/VBoxContainer
var insLabel = preload("res://MGF Scene/Season/Label.tscn")
var insMatch = preload("res://MGF Scene/Season/Match.tscn")
var insTeamIndex = preload("res://MGF Scene/Season/TeamIndex.tscn")

var fixtures = []

var arr = []

var newArr = FileData.db.teamDetail

var item = array[randi() % array.size()]

var teams = [
	"CB",
	"DV",
	"KH",
	"NM",
	"QB",
	"QD",
	"QP",
	"QV",
	"RB",
	"RO",
	"ST",
	"VT"
]

var ww = 0
var dd = 0
var ll = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_team_data()
	randomize()
	arrayTest.shuffle()
	round_robin_gen()
#	print("___________")
	get_fixtures_data()
#	print("___________")


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func caculate_score(team1, team2):
	var t1Goal = 0
	var t2Goal = 0
	
# warning-ignore:unused_variable
	for i in range(10):
		if array[randi() % array.size()] == 0:
			t1Goal += 1
		elif array[randi() % array.size()] == 1:
			t2Goal += 1
		else:
			pass
	
	print("Ket Qua Tran Dau: "+team1[0]+" "+str(t1Goal)+" - "+str(t2Goal)+" "+team2[0])

func caculate(value1, value2):
	if value1 > value2:
		return true
	elif value1 < value2:
		return false

func round_robin_gen():
	if len(teams) % 2:
		teams.append('Day off')
	var n = len(teams)
	var matchs = []
	var return_matchs = []
# warning-ignore:unused_variable
	for fixture in range(1, n):
		for i in range(n/2):
			matchs += [[teams[i],teams[n - 1 - i]]]
			return_matchs += [[teams[n - 1 - i], teams[i]]]
		teams.insert(1, teams.pop_back())
# warning-ignore:integer_division
		fixtures.insert(len(fixtures)/2, matchs)
		fixtures.append(return_matchs)
		matchs = []
		return_matchs = []

func get_fixtures_data():
	for i in range(fixtures.size()):
		var turn = insLabel.instantiate()
		turn.text = "Round " + str(i+1)
		cont.add_child(turn)
		for n in range(fixtures[i].size()):
			var creMatch = insMatch.instantiate()
			var count = creMatch.get_child(2)
			var logoA = creMatch.get_child(3)
			var logoB = creMatch.get_child(4)
			var goalA = creMatch.get_child(5)
			var goalB = creMatch.get_child(6)
			
			count.text = "   " + str(n+1)
			logoA.texture = Global.logoTeam[str(fixtures[i][n][0])]
			logoB.texture = Global.logoTeam[str(fixtures[i][n][1])]
			goalA.text = str(arrayTest[randi() % arrayTest.size()])
			goalB.text = str(arrayTest[randi() % arrayTest.size()])

			cont.add_child(creMatch)

			for e in range(newArr.size()):
				e += 1
				
				if (teams[e-1] == fixtures[i][n][0]):
					newArr[e-1].teamMatch += 1
					if (int(goalA.text) > int(goalB.text)):
						newArr[e-1].teamW += 1
						newArr[e-1].teamPoint += 3
					elif (int(goalA.text) == int(goalB.text)):
						newArr[e-1].teamD += 1
						newArr[e-1].teamPoint += 1
					elif (int(goalA.text) < int(goalB.text)):
						newArr[e-1].teamL += 1
						
					newArr[e-1].teamPointW += int(goalA.text)
					newArr[e-1].teamPointL += int(goalB.text)
					
				if (teams[e-1] == fixtures[i][n][1]):
					newArr[e-1].teamMatch += 1
					if (int(goalB.text) > int(goalA.text)):
						newArr[e-1].teamW += 1
						newArr[e-1].teamPoint += 3
					elif (int(goalB.text) == int(goalA.text)):
						newArr[e-1].teamD += 1
						newArr[e-1].teamPoint += 1
					elif (int(goalB.text) < int(goalA.text)):
						newArr[e-1].teamL += 1

					newArr[e-1].teamPointW += int(goalB.text)
					newArr[e-1].teamPointL += int(goalA.text)

	newArr.sort_custom(Callable(MyCustomSorter, "sort_ascending"))
	
	for n in range(newArr.size()):
		n+=1
# warning-ignore:shadowed_variable
		var team = insTeamIndex.instantiate()
		bxh.add_child(team)
		team.index = n
		team.teamName = newArr[n-1].teamName
		team.teamIcon = load(newArr[n-1].teamIcon)

		team.matchTime = newArr[n-1].teamMatch
		team.matchW = newArr[n-1].teamW
		team.matchD = newArr[n-1].teamD
		team.matchL = newArr[n-1].teamL

		team.point = newArr[n-1].teamPoint
		team.pointW = newArr[n-1].teamPointW
		team.pointL = newArr[n-1].teamPointL
		team.get_team_data()

	for child in bxh.get_children():
		child.cup = newArr[child.index-1].teamCup
		child.get_team_data()

	newArr[0].teamCup = str(int(newArr[0].teamCup) + 1)
	bxh.get_child(1).cup = newArr[0].teamCup
	bxh.get_child(1).get_team_data()

func reset_team_data():
	newArr.sort_custom(Callable(MyCustomSorter, "sort_reset"))
	for n in range(newArr.size()):
		n+=1
		newArr[n-1].teamIndex = str(n-1)
		newArr[n-1].teamMatch = 0
		newArr[n-1].teamW = 0
		newArr[n-1].teamD = 0
		newArr[n-1].teamL = 0
		newArr[n-1].teamPoint = 0
		newArr[n-1].teamPointW = 0
		newArr[n-1].teamPointL = 0

class MyCustomSorter:
	static func sort_ascending(a, b):
		if int(a.teamPoint) > int(b.teamPoint):
			return true
		return false

	static func sort_reset(a, b):
		if int(a.team) < int(b.team):
			return true
		return false

	static func customComparison(a, b):
		if typeof(a) == typeof(b):
			return a > b
		else:
			return typeof(a) < typeof(b)

func _exit_tree():
	queue_free()
