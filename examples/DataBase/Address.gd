extends Node

var MGFMode: = MainUI
enum {
	MainUI,
	Rank,
	Setting,
	MainGame,
	Career,
	Season,
	SeasonMatch,
	Market,
	Match,
	Formation,
	Trainning,
	FreeMode
}

var btntime:int = 0

var ver: String = "100012"
var password:String = ":mgf?dqd!13%11*95@"
var MatchPlay:int = 0
var isQuit:bool = false
var autoMode:bool = false
var camHeight:float = 20
var isPlayerCreate: bool = true
var isDebug: bool = true
var isFoul: bool = false
var isStamina: bool = false
var isFixPosY: bool = true
#Swipe Mode in Config
var optionSelect:int = 0

##Test mode
var isGuide:bool = false
var GuideIndex:int = 0
var GuideData:Array = [
	{"label":"SHOOT","info":"QUICK SWIPE to SHOOT.","check":[0,1],"active":false,"file":"shoot_pc.ogv","length":4,"pc":"QUICK DRAG(Hold mouse left and quick drag) to SHOOT."},
	{"label":"SELECT","info":"TOUCH on the player to SELECT.","check":[0,5],"active":false,"file":"select_pc.ogv","length":5,"pc":"CLICK on the player to SELECT."},
	{"label":"PASS","info":"TOUCH on the player with the BALL then QUICK SWIPE to PASS.","check":[0,5],"active":false,"file":"pass_pc.ogv","length":5,"pc":"CLICK on the player with the BALL then QUICK DRAG(Hold mouse left and quick drag) to PASS."},
	{"label":"MOVE","info":"TOUCH on the player without the BALL then QUICK SWIPE to MOVE.","check":[0,5],"active":false,"file":"move_pc.ogv","length":7,"pc":"CLICK on the player without the BALL then QUICK DRAG(Hold mouse left and quick drag) to MOVE."},
	{"label":"GOAL","info":"TOUCH on the player with the BALL then QUICK SWIPE to SHOOT the ball to GOAL.","check":[0,3],"active":false,"file":"goal_pc.ogv","length":7,"pc":"CLICK on the player with the BALL then QUICK DRAG(Hold mouse left and quick drag) to SHOOT the ball to GOAL."},
]

var isAIState: = false
var isChange: = true
var isShootTest: = false
var BallStart: = Vector3(0,0,0)
var TeamAPlay: = "RF"
var TeamAPos: = "LF"
var TeamBPlay: = "GK"
var TeamBPos: = "GK"
var powerTest: = 0
var randomShot: = false
var footSize: = 0
var footFix: = 0
var footAngle: = 0.01

#GK stats
var maxS:float = 6.0
var minH:float = 200.0
var maxH:float = 80.0
var minD:float = 1.0
var maxD:float = 4.0

#AI behaviour
var AIState:int = 2
enum {AI_PASS, AI_CREATE, AI_SHOOT, AI_MOVE, AI_FIGHT, AI_COVER, AI_CELEBRATE}

var State:Array = ["AI_PASS","AI_CREATE","AI_SHOT","AI_MOVE","AI_FIGHT","AI_GOAL","AI_CELEBRATE"]

#export(String, "CB", "DV", "KH", "NM", "QB", "QD", "QP", "QV", "RB", "R0", "ST", "VT") var teamID1 = 0
var teamID1:int = 0
var teamID2:int = 5

var team:int = 0
var team1:int = 1
var team2:int = 2

func is_test_mode() -> bool:
	var value:bool = false
	if gameModeCur == 3:
		value = true
	return value

var gameModeCur: int = 1

var gameModeList:Array = [
	{"id": 0, "name": "Player vs Player", "icon": "res://Assets2D/UI/user.png","info":"Match with other player"},
	{"id": 1, "name": "Match Mode", "icon": "res://Assets2D/UI/iconBall.png","info":"Match with AI"},
	{"id": 2, "name": "Trainng Mode", "icon": "res://Assets2D/UI/iconTrain.png","info":"Train your Skill"},
	{"id": 3, "name": "Test Mode", "icon": "res://Assets2D/UI/iconSettings.png","info":"Some Tests in MGF"},
	{"id": 3, "name": "Guild Mode", "icon": "res://Assets2D/UI/iconTest.png","info":"Basic Controller Guide"},
]

var timeCur: int = 0

var timeList:Array = [
	{"time":45,"plus":2},
	{"time":90,"plus":5},
	{"time":180,"plus":5},
]

var staCur: int = 0

var staList:Array = [
	{"name":"Green","icon":"res://Assets2D/Stadium/StadiumiconIcon1.jpg","mat":"res://Assets3D/Grass/M_Field_00.tres"},
	{"name":"Ground","icon":"res://Assets2D/Stadium/StadiumiconIcon2.jpg","mat":"res://Assets3D/Grass/M_Field_01.tres"},
	{"name":"Blue","icon":"res://Assets2D/Stadium/StadiumiconIcon3.jpg","mat":"res://Assets3D/Grass/M_Field_02.tres"},
	{"name":"Sand","icon":"res://Assets2D/Stadium/StadiumiconIcon4.jpg","mat":"res://Assets3D/Grass/M_Field_03.tres"},
]

var Pos: Array = [
	{"name":"GK","id":0},
	{"name":"CB","id":1},
	{"name":"RB","id":2},
	{"name":"LB","id":3},
	{"name":"CM","id":4},
	{"name":"LF","id":5},
	{"name":"RF","id":6},
	{"name":"NON","id":7},
]

var PosName: = {
	"GK":0,
	"CB":1,
	"RB":2,
	"LB":3,
	"CM":4,
	"LF":5,
	"RF":6,
	"NON":7
}

static func device_is_mobile():
#	"Android", "iOS", "HTML5", "OSX", "Server", "Windows", "UWP", "X11"
	return OS.get_name() == "Android" or OS.get_name() == "iOS"

func check_match_mode() -> bool:
	var value:bool
	if gameModeCur != 1:
		value = false
	else:
		value = true
	return value

var weather:Dictionary = {
	"day": true,
	"rain": false,
	"snow": false,
	"count": 0, ##200-500 1000-5000
	"crowd": [80],
	"stadium": "MGF Stadium",
}

func weather_setup():
	## Weather 
	var day:float = Calculate.rand_num(8)
	var sun:float = Calculate.rand_num(8)
	var night:float = Calculate.rand_num(7)
	var rain:float = Calculate.rand_num(5)
	var snow:float = Calculate.rand_num(3)
	
	weather.rain = false
	weather.snow = false
	weather.count = 0
	
	if sun > night:
		weather.day = true
	else:
		weather.day = false
	if rain > day or snow > day:
		if rain > snow:
			weather.rain = true
		else:
			weather.snow = true
		if Calculate.rand_num(7) > Calculate.rand_num(3):
			weather.count = int(abs(Calculate.rand_a_num(200,500)))
		else:
			weather.count = int(abs(Calculate.rand_a_num(1000,5000)))
	## Crowd
	var data = GameData.get_data(GameData.account_data_path)
	var Min:float = 0
	var Max:float = 100
	
	if isDebug == false:
		if data.Diamond < 100000:
			Min = remap(data.Diamond,0,100000,40,50)
			Min = clamp(Min,40,50)
			Max = remap(data.Diamond,0,100000,60,70)
			Max = clamp(Max,60,70)
		elif data.Diamond >= 100000:
			Min = remap(data.Diamond,100000,1000000,80,100)
			Min = clamp(Min,80,90)
			Max = remap(data.Diamond,100000,1000000,90,100)
			Max = clamp(Max,90,100)
	else:
		Min = 80
		Min = 100
	
	weather.crowd[0] = Calculate.rand_a_num(Min,Max)

func _ready() -> void:
	weather_setup()
