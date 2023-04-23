extends Sprite2D

@onready var units:Array = get_tree().get_nodes_in_group("units")
var id:int = 0

@onready var teamAMat:Color = GlobalTheme.teamColor[Global.teamID1][1]
@onready var teamBMat:Color = GlobalTheme.teamColor[Global.teamID2][1]


func _ready() -> void:
	set_team_color()

func set_team_color() -> void:
	teamAMat.a = 0.6
	teamBMat.a = 0.6
	if units[id].team == 1:
		self.modulate = teamAMat
	else:
		self.modulate = teamBMat

func _process(delta) -> void:
	position = vector_convert(units[id].position)

func vector_convert(vec) -> Vector2:
	var x = remap(vec.x,-14.25,14.25,0,256)
	var y = remap(vec.z,-6.9,6.9,0,150)
	x = clamp(x,0,256)
	y = clamp(y,0,150)
	return Vector2(x,y)

func _exit_tree():
	queue_free()
