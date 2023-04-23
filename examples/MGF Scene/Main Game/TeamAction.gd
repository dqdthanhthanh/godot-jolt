extends Control


@onready var teamASub:Label = $teamA/sub/label
@onready var teamBSub:Label = $teamB/sub/label

@onready var teamATac:Label = $teamA/tactic/label
@onready var teamBTac:Label = $teamB/tactic/label

@onready var teamAFoul:Label = $teamA/foul/label
@onready var teamBFoul:Label = $teamB/foul/label

@onready var shader = preload("res://Assets2D/Shader/ShaderRadianBar.tres")

@export var isVisible:bool = true

@onready var UITeamA:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamAC.tres")
@onready var UITeamB:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeamBC.tres")
@onready var teamAMat:Color = GlobalTheme.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = GlobalTheme.teamColor[Global.teamID2][1]

@onready var tween:Tween

func _ready() -> void:
	teamAMat.a = 0.4
	GlobalTheme.color_UI(UITeamA,teamAMat,0.5)
	teamBMat.a = 0.4
	GlobalTheme.color_UI(UITeamB,teamBMat,0.5)
	show()
	ui_visible(isVisible)
	reset_action()

func update_team_action(data,team) -> void:
	if team == 1:
		data = data.teamAData
		teamASub.text = str(data[0])
		teamATac.text = str(data[2])
		teamAFoul.text = str(data[1])
	else:
		data = data.teamBData
		teamBSub.text = str(data[0])
		teamBTac.text = str(data[2])
		teamBFoul.text = str(data[1])

func _on_BtnTeamAction_pressed():
	if isVisible == false:
		isVisible = true
	else:
		isVisible = false
	ui_visible(isVisible)

func ui_visible(value):
	$teamA.visible = value
	$teamB.visible = value
	$Panel.visible = value
	$Panel2.visible = value

func update_action(team,type,value):
	var group:Control
	var index:int
	if team == 1:
		group = $teamA
		match type:
			0:
				index = 2
			1:
				index = 0
			2:
				index = 1
	else:
		group = $teamB
		match type:
			0:
				index = 0
			1:
				index = 2
			2:
				index = 1
#	group.get_child(type).get_node("RadialBar").material.set("shader_param/value",value)
	tween_value(group.get_child(index).get_node("RadialBar"),value)

func reset_action():
	for child in $teamA.get_children():
		child.get_node("RadialBar").material = shader.duplicate(true)
		child.get_node("RadialBar").material.set("shader_param/value",0)
	for child in $teamB.get_children():
		child.get_node("RadialBar").material = shader.duplicate(true)
		child.get_node("RadialBar").material.set("shader_param/value",0)

func tween_value(obj,x,time:float = 1.0) -> void:
	tween = get_tree().create_tween()
	tween.tween_property(obj,"material:shader_param/value",x,time)
	tween.tween_callback(queue_free)
