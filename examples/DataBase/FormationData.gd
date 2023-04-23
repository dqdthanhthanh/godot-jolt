extends Node

## Chien Thuat
var teamFor:int = 1

var tacData = [0,0,0]

var AI_tac:int = 0
var teamTac:int = 0
var teamTac1:int = 0
var teamTac2:int = 0

var teamV:float = 0
var teamV1:float = 0
var teamV2:float = 0

var teamH:float = 0
var teamH1:float = 0
var teamH2:float = 0

## Team formation
var teamForm:int = 0
var isDisable: bool = false
var CanFormation: bool = false

##Sub
var teamTimeSub:int = 3
var teamMain1:Array = []
var teamSub1:Array = []
var teamIn1:Array = []
var teamOut1:Array = []
var teamPos1:Array = []

var teamIn:Array = [47,1995]
var teamOut:Array = [45,46]

var isSub:bool = false
var isTac:bool = false
var timeSub:int = 0
var timeTac:int = 0
var pOut:Vector3 = Vector3.ZERO
var pIn:Vector3 = Vector3.ZERO

## MatchPos
var GKMatch:Vector3 = Vector3(-13.25,0,0)
var CBMatch:Vector3 = Vector3(-10,0,0)
var RBMatch:Vector3 = Vector3(-11,0,3)
var LBMatch:Vector3 = Vector3(-11,0,-3)
var CMMatch:Vector3 = Vector3(-6,0,0)
var CMRMatch:Vector3 = Vector3(-6,0,4)
var CMLMatch:Vector3 = Vector3(-6,0,-4)
var RFMatch:Vector3 = Vector3(-2.5,0,3.75)
var LFMatch:Vector3 = Vector3(-2.5,0,-3.75)
var CFMatch:Vector3 = Vector3(-2.5,0,0)

func get_formation():
	var formationMatch = [
		#3-1-2
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : CMMatch,
			"LF" : LFMatch,
			"RF" : RFMatch
		},

		#3-2-1
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : CMRMatch,
			"LF" : CMLMatch,
			"RF" : CFMatch
		},

		#2-3-1
		{
			"GK" : GKMatch,
			"CB" : CMLMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : CMRMatch,
			"LF" : CMMatch,
			"RF" : CFMatch
		},

		#2-2-2
		{
			"GK" : GKMatch,
			"CB" : CMLMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : CMRMatch,
			"LF" : LFMatch,
			"RF" : RFMatch
		},
		#2-1-3
		{
			"GK" : GKMatch,
			"CB" : CMMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : RFMatch,
			"LF" : LFMatch,
			"RF" : CFMatch
		},

		#1-2-3
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : CMLMatch,
			"RB" : CMRMatch,
			"CM" : RFMatch,
			"LF" : LFMatch,
			"RF" : CFMatch
		},

		#1-3-2
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : CMLMatch,
			"RB" : CMRMatch,
			"CM" : CMMatch,
			"LF" : LFMatch,
			"RF" : RFMatch
		},

		#0-3-3
		{
			"GK" : GKMatch,
			"CB" : CMMatch,
			"LB" : CMLMatch,
			"RB" : CMRMatch,
			"CM" : RFMatch,
			"LF" : LFMatch,
			"RF" : CFMatch
		},

		#3-0-3
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : RFMatch,
			"LF" : LFMatch,
			"RF" : CFMatch
		},

		#3-3-0
		{
			"GK" : GKMatch,
			"CB" : CBMatch,
			"LB" : LBMatch,
			"RB" : RBMatch,
			"CM" : CMRMatch,
			"LF" : CMLMatch,
			"RF" : CMMatch
		},
			]
	return formationMatch

var Tatical: = [
	{"text":"Attack","icon":"res://Assets2D/UI/iconMenu.png"},
	{"text":"Balance","icon":"res://Assets2D/UI/iconMenu.png"},
	{"text":"Defend","icon":"res://Assets2D/UI/iconMenu.png"},
	{"text":"Side","icon":"res://Assets2D/UI/iconMenu.png"},
	{"text":"Mid","icon":"res://Assets2D/UI/iconMenu.png"},
	{"text":"Halfspace","icon":"res://Assets2D/UI/iconMenu.png"},
]

var Formation: = [
	{"text":"3-1-2","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"3-2-1","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"2-3-1","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"2-2-2","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"2-1-3","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"1-3-2","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"1-2-3","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"0-3-3","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"3-0-3","icon":"res://Assets2D/UI/iconFormation.png"},
	{"text":"3-3-0","icon":"res://Assets2D/UI/iconFormation.png"},
]


func reload_formation(value:int = 0) -> void:
	var teamV = FormationData.teamV
	var teamH = FormationData.teamH
	if value == 1:
		teamV = FormationData.teamV1
		teamH = FormationData.teamH1
	elif value == 2:
		teamV = FormationData.teamV2
		teamH = FormationData.teamH2
#	FormationData.GKMatch = Vector3(-2.65,0,0)
	FormationData.CBMatch = Vector3(-10+teamV/2,0,0)
	FormationData.RBMatch = Vector3(-11+teamV/2,0,3+teamH)
	FormationData.LBMatch = Vector3(-11+teamV/2,0,-3-teamH)
	FormationData.CMMatch = Vector3(-6+teamV,0,0)
	FormationData.CMRMatch = Vector3(-6+teamV,0,4+teamH)
	FormationData.CMLMatch = Vector3(-6+teamV,0,-4-teamH)
	FormationData.RFMatch = Vector3(-2.5+teamV,0,3.75+teamH)
	FormationData.LFMatch = Vector3(-2.5+teamV,0,-3.75-teamH)
	FormationData.CFMatch = Vector3(-2.5+teamV,0,0)

func load_team_tactic() -> void:
	var data = GameData.formation_load_data()
	var team1Tactic = data.teams[Global.teamID1].tactic
	var team2Tactic = data.teams[Global.teamID2].tactic
	teamTac1 = team1Tactic[0]
	teamTac2 = team2Tactic[0]
	teamV1 = team1Tactic[1]
	teamV2 = team2Tactic[1]
	teamH1 = team1Tactic[2]
	teamH2 = team2Tactic[2]
	if Global.gameModeCur > 0:
		if Global.MatchPlay == 1:
			teamTac2 = AI_tac
		else:
			teamTac1 = AI_tac

func AI_random_tactical() -> void:
	AI_tac = int(Calculate.rand_a_num(0,10))
	print(Global.MatchPlay)
	if Global.MatchPlay == 1:
		teamTac2 = AI_tac
	else:
		teamTac1 = AI_tac

func _ready() -> void:
	AI_random_tactical()
