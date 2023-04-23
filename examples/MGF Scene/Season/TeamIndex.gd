extends Panel

@onready var setIndex: = $HBox/Index
@onready var setIcon: = $HBox/Logo/Sprite2D
@onready var setTeamName: = $HBox/Label
@onready var setMatch: = $HBox/Match
@onready var setW: = $HBox/W
@onready var setD: = $HBox/D
@onready var setL: = $HBox/L
@onready var setPoint: = $HBox/Point
@onready var setPointW: = $HBox/PW
@onready var setPointL: = $HBox/PL
@onready var setCup: = $HBox/Cup

var index: int = 0
var id:int = 1000
var teamIcon
var teamName: String = "CB"

var point: int = 0
var pointW: int = 0
var pointL: int = 0

var matchTime: int = 0
var matchW: int = 0
var matchD: int = 0
var matchL: int = 0

var cup: int = 0


func get_team_data() -> void:
	setIndex.text = str(index)
	setIcon.texture = teamIcon
	setTeamName.text = teamName
	
	setMatch.text = str(matchTime)
	setW.text = str(matchW)
	setD.text = str(matchD)
	setL.text = str(matchL)
	
	setPoint.text = str(point)
	setPointW.text = str(pointW)
	setPointL.text = str(pointL)
	
	setCup.text = str(cup)

func _on_BtnFormation_pressed() -> void:
	FormationData.CanFormation = true
	SeasonData.check_team_select(id)
	GlobalTheme.set_color(id)
	Global.MGFMode = Global.Season
	FormationData.teamForm = id
	FormationData.teamFor = 1
	SceneTransition.change_scene_to_file("res://MGF Scene/Formation/Formation.tscn")

func _exit_tree():
	queue_free()
