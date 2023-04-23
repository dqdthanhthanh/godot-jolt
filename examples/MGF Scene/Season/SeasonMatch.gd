extends Control


@onready var matchInfo: = get_parent().get_node("MatchInfo")
@onready var MatchList: = $MatchList
@onready var matchReady: = $MatchReady
@onready var seasonTab: = get_parent().get_node("SeasonTab")

func load_setup(value:int = 0) -> void:
	matchInfo.hide()
	if value == 0:
		MatchList.load_setup(0)
		MatchList.show()
		matchReady.hide()
	elif value == 1:
		MatchList.hide()
		matchReady.show()
		matchReady.load_setup()
	else:
		MatchList.hide()
		matchReady.hide()

func _exit_tree():
	queue_free()
