extends RichTextLabel


var stats:Dictionary = {
	"Stat[0]": 0,
	"Stat[1]": 1,
	
	"Stat[2]": 2,
	"Stat[3]": 3,
	
	"Stat[4]": 4,
	"Stat[5]": 5,
	"Stat[6]": 6,
	"Stat[7]": 7,
	
	"Stat[8]ion": 8,
	"Stat[9]": 9,
	
	"statSave": 10,
	"Stat[11]": 11
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file_data:FileData = FileData.new()
	for i in range(100,file_data.players.size()):
		var players =  file_data.players[i]
		var stats = []
		##Shot
		stats.append(players.Stat[0])
		stats.append(players.Stat[1])
		##Speed
		stats.append(players.Stat[2])
		##Tech
		stats.append(players.Stat[3])
		stats.append(players.Stat[4])
		##Physic
		stats.append(players.Stat[5])
		stats.append(players.Stat[6])
		stats.append(players.Stat[7])
		##Def
		stats.append(players.Stat[8])
		stats.append(players.Stat[9])
		##GK
		stats.append(players.Stat[10])
		stats.append(players.Stat[11])
		##Else
		stats.append(0)
		stats.append(0)
		stats.append(0)
#		text += "\n" + " " + str(i) + " " + str(stats)
		print(str(i) + "\"Stats\": " + str(stats) + ",")
		print("\"Train\": " + "[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]" + ",")
