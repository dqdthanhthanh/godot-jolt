extends Node

var MGFMode = MainUI
enum {
	MainUI,
	Account,
	Setting,
	MainGame,
	Career,
	Season,
	SeasonMatch,
	Market,
	Match,
	Formation,
	Trainning
}

var ver: String = "100012"
var MatchPlay = 0
var autoMode:bool = false
var camHeight:float = 3.8
var isPlayerCreate: bool = true
var isDebug: bool = true
var isSimulateShoot: bool = true
var isStamina: bool = false
var isCheck: bool = false
var isFixPosY: bool = true
#Swipe Mode in Config
var optionSelect = 0

##Test mode
var isAIState = false
var isChange = true
var isShootTest = false
var BallStart = Vector3(-2,0,0)
var TeamAPlay = "RF"
var TeamAPos = "LF"
var TeamBPlay = "GK"
var TeamBPos = "GK"
var powerTest = 0
var randomShot = false
var footSize = 0
var footFix = 0
var footAngle = 0.01

#GK stats
var maxS:float = 6.0
var minH:float = 200.0
var maxH:float = 80.0
var minD:float = 1.0
var maxD:float = 4.0

#AI behaviour
var AIState = 2
enum {AI_PASS, AI_CREATE, AI_SHOOT, AI_MOVE, AI_FIGHT, AI_COVER, AI_CELEBRATE}

var State = {
	0 : "AI_PASS",
	1 : "AI_CREATE",
	2 : "AI_SHOT",
	3 : "AI_MOVE",
	4 : "AI_FIGHT",
	5 : "AI_GOAL",
	6 : "AI_CELEBRATE"
}

#export var teamID1 = 0 # (String, "CB", "DV", "KH", "NM", "QB", "QD", "QP", "QV", "RB", "R0", "ST", "VT")
var teamID1 = 0
var teamID2 = 5

var team = 0
var team1 = 1
var team2 = 2

func is_test_mode():
	if gameModeCur == 3:
		return true

var itemSize:Array = range(0,1)

var gameModeCur: int = 1

var gameModeName = {
	0 : "Player vs Player",
	1 : "Match",
	2 : "Trainng",
	3 : "Test Mode"
}

var gameModeImg = {
	0 : preload("res://Assets2D/UI/user.png"),
	1 : preload("res://Assets2D/UI/iconBall.png"),
	2 : preload("res://Assets2D/UI/iconTrain.png"),
	3 : preload("res://Assets2D/UI/iconTest.png")
}

var setFor = {
	0 : "3-1-2",
	1 : "3-2-1",
	2 : "2-2-2",
	3 : "1-3-2",
	4 : "0-3-3"
}

var SetTime: int = 0
var time = {
	0 : 45,
	1 : 3
}

var timePlus = {
	0 : 2,
	1 : 4,
	2 : 5,
	3 : 5,
	4 : 0,
	5 : 0
}

var staCur: int = 0

var staName = {
	0 : "Green",
	1 : "Ground",
	2 : "Blue",
	3 : "Sand"
}

var staImg = {
	0 : preload("res://Assets2D/Stadium/StadiumiconIcon1.jpg"),
	1 : preload("res://Assets2D/Stadium/StadiumiconIcon2.jpg"),
	2 : preload("res://Assets2D/Stadium/StadiumiconIcon3.jpg"),
	3 : preload("res://Assets2D/Stadium/StadiumiconIcon4.jpg")
}

var staLineMa = {
	0 : preload("res://Assets3D/Grass/M_line.tres"),
	1 : preload("res://Assets3D/Grass/M_line.tres"),
	2 : preload("res://Assets3D/Grass/M_line.tres"),
	3 : preload("res://Assets3D/Grass/M_line.tres")
}

var fieldMat = {
	0 : preload("res://Assets3D/Grass/M_Field_00.tres"),
	1 : preload("res://Assets3D/Grass/M_Field_01.tres"),
	2 : preload("res://Assets3D/Grass/M_Field_02.tres"),
	3 : preload("res://Assets3D/Grass/M_Field_03.tres")
}

var Pos = {
	0 : "GK",
	1 : "CB",
	2 : "RB",
	3 : "LB",
	4 : "CM",
	5 : "LF",
	6 : "RF",
	7 : "NON"
}

var PosName = {
	"GK":0,
	"CB":1,
	"RB":2,
	"LB":3,
	"CM":4,
	"LF":5,
	"RF":6,
	"NON":7
}

func device_is_mobile():
	return OS.get_name() == "Android" or OS.get_name() == "iOS"
