extends Node

## Chien Thuat
var teamFor:int = 0
var teamFor1:int = 0
var teamFor2:int = 0

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
var timeSub:int = 0
var pOut:Vector3 = Vector3.ZERO
var pIn:Vector3 = Vector3.ZERO

## BroadPos
var GKBroad:Vector2 = Vector2(832,620)
var CBBroad:Vector2 = Vector2(832,450)
var RBBroad:Vector2 = Vector2(1032,450)
var LBBroad:Vector2 = Vector2(640,450)
var CMBroad:Vector2 = Vector2(832,260)
var CMRBroad:Vector2 = Vector2(1032,260)
var CMLBroad:Vector2 = Vector2(640,260)
var RFBroad:Vector2 = Vector2(1032,80)
var LFBroad:Vector2 = Vector2(640,80)
var CFBroad:Vector2 = Vector2(832,80)

## MatchPos
var GKMatch:Vector3 = Vector3(-2.65,0,0)
var CBMatch:Vector3 = Vector3(-2,0,0)
var RBMatch:Vector3 = Vector3(-2.2,0,0.5)
var LBMatch:Vector3 = Vector3(-2.2,0,-0.5)
var CMMatch:Vector3 = Vector3(-1.2,0,0)
var CMRMatch:Vector3 = Vector3(-1.2,0,0.8)
var CMLMatch:Vector3 = Vector3(-1.2,0,-0.8)
var RFMatch:Vector3 = Vector3(-0.5,0,0.75)
var LFMatch:Vector3 = Vector3(-0.5,0,-0.75)
var CFMatch:Vector3 = Vector3(-0.5,0,0)

#3-1-2
var playerMaPos0 = {
	"GK" : GKMatch,
	"CB" : CBMatch,
	"LB" : LBMatch,
	"RB" : RBMatch,
	"CM" : CMMatch,
	"LF" : LFMatch,
	"RF" : RFMatch
}
var playerFoPos0 = {
	"GK" : GKBroad,
	"CB" : CBBroad,
	"LB" : LBBroad,
	"RB" : RBBroad,
	"CM" : CMBroad,
	"LF" : LFBroad,
	"RF" : RFBroad
}
#3-2-1
var playerMaPos1 = {
	"GK" : GKMatch,
	"CB" : CBMatch,
	"LB" : LBMatch,
	"RB" : RBMatch,
	"CM" : CMRMatch,
	"LF" : CMLMatch,
	"RF" : CFMatch
}
var playerFoPos1 = {
	"GK" : GKBroad,
	"CB" : CBBroad,
	"LB" : LBBroad,
	"RB" : RBBroad,
	"CM" : CMRBroad,
	"LF" : CMLBroad,
	"RF" : CFBroad
}
#2-2-2
var playerMaPos2 = {
	"GK" : GKMatch,
	"CB" : CMLMatch,
	"LB" : LBMatch,
	"RB" : RBMatch,
	"CM" : CMRMatch,
	"LF" : LFMatch,
	"RF" : RFMatch
}
var playerFoPos2 = {
	"GK" : GKBroad,
	"CB" : CMLBroad,
	"LB" : LBBroad,
	"RB" : RBBroad,
	"CM" : CMRBroad,
	"LF" : LFBroad,
	"RF" : RFBroad
}
#1-3-2
var playerMaPos3 = {
	"GK" : GKMatch,
	"CB" : CBMatch,
	"LB" : CMLMatch,
	"RB" : CMRMatch,
	"CM" : CMMatch,
	"LF" : LFMatch,
	"RF" : RFMatch
}
var playerFoPos3 = {
	"GK" : GKBroad,
	"CB" : CBBroad,
	"LB" : CMLBroad,
	"RB" : CMRBroad,
	"CM" : CMBroad,
	"LF" : LFBroad,
	"RF" : RFBroad
}
#0-3-3
var playerMaPos4 = {
	"GK" : GKMatch,
	"CB" : CMMatch,
	"LB" : CMLMatch,
	"RB" : CMRMatch,
	"CM" : CFMatch,
	"LF" : LFMatch,
	"RF" : RFMatch
}
var playerFoPos4 = {
	"GK" : GKBroad,
	"CB" : CMBroad,
	"LB" : CMLBroad,
	"RB" : CMRBroad,
	"CM" : CFBroad,
	"LF" : LFBroad,
	"RF" : RFBroad
}

var formationMatch = {
	0 : playerMaPos0,
	1 : playerMaPos1,
	2 : playerMaPos2,
	3 : playerMaPos3,
	4 : playerMaPos4
}

var formationBroad = {
	0 : playerFoPos0,
	1 : playerFoPos1,
	2 : playerFoPos2,
	3 : playerFoPos3,
	4 : playerFoPos4
}
