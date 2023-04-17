extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.create_new_data()
	if 5 in range(5,7):
		print(true)
	else:
		print(false)


func _on_Button_pressed():
	var getData = float($LineEdit.text)
	var calculate
	var maxS = 100
	var minD = 0
	var maxD = 100
#	if getData <= 5:
	calculate = remap(getData,0,100,15,20)
#	else:
#		calculate = maxD
	$Label.text = str(calculate)
	print(calculate)
