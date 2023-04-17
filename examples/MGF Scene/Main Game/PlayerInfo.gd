extends Panel

@onready var playersA = $PlayerA
@onready var playersB = $PlayerB

@onready var insPlayer = load("res://MGF Scene/Season/PlayerStats.tscn")


func _ready():
	pass
	var data = GameData.season_load_data()
	var playerDataA = data.teams[Global.teamID1].Fid
	var playerDataB = data.teams[Global.teamID2].Fid

	create_player_stats(playersA,playerDataA,data)
	create_player_stats(playersB,playerDataB,data)

func create_player_stats(parent,teamData, data):
	if parent.get_child_count() > 0:
		for i in parent.get_children():
			i.queue_free()
	
	for i in teamData.size()+1:
		var player = data.players[teamData[i-1]]
		var ins = insPlayer.instantiate()
		parent.add_child(ins)
		ins.get_node("pos").text = "P"
		if i > 0:
			ins.get_node("name").text = str(player.PlayerID) + " " +str(player.Name)
			ins.get_node("team/team").texture = load(data.teams[int(player.Team[0])].icon)
			ins.get_node("team").text = ""
			ins.get_node("pos").text = str(player.Season[0])
			if int(player.Season[0]) > 0:
				ins.get_node("pos").text = str("%.1f" % (float(player.Season[1])/float(player.Season[0])))
				ins.get_node("saves").text = str("%.0f" % (float(player.Season[10])/float(player.Season[0])))
			else:
				ins.get_node("saves").text = "0"
	#			ins.get_node("pos").text = str(float(player.Season[1]))
	#		ins.get_node("pos").text = str(player.Season[0])
	#		ins.get_node("pos").text = str(float(player.Season[1]))
			ins.get_node("goal").text = str(player.Season[2])
			ins.get_node("assits").text = str(player.Season[3])
			ins.get_node("shots").text = str(player.Season[4])
			ins.get_node("passes").text = str(player.Season[5])
			ins.get_node("blocks").text = str(player.Season[8])
#			ins.get_node("saves").text = str(player.Season[9])
#			ins.get_node("saves").text = str(player.Season[10])
