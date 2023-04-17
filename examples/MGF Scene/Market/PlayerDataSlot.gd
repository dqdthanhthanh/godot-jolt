extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.isCheck == true:
		$Button/id.show()
		$Button/check.show()

func str_round(value):
	return str(round(float(value)))

# warning-ignore:unused_variable
func _on_Button_pressed():
	if Global.MGFMode != Global.Market:
		var forNode = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GroupSlots")
		var slotNode = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("GroupSlots").changeSlot
		for i in forNode.get_children():
			if i.uid == slotNode:
				i.get_node("id").text = $Button/id.text
				i.get_node("check").text = $Button/check.text
				if i.get_node("check").text != "NON":
					print("Buy player")
					if Global.isPlayerCreate == true:
						i.get_node("id").text = $Button/id.text
						i.get_node("name").text = $Button/name.text
						i.get_node("pos").text = $Button/pos.text
						i.get_node("check").text = $Button/check.text
						i.get_node("image").texture = $Button/image.texture
						i.get_node("ov").text = $Button/ov.text
						i.get_node("f").text = $Button/f.text
						i.get_node("m").text = $Button/m.text
						i.get_node("d").text = $Button/d.text
						Calculate.stat_color(i.get_node("ov"))
						Calculate.stat_color(i.get_node("f"))
						Calculate.stat_color(i.get_node("m"))
						Calculate.stat_color(i.get_node("d"))
						if i.get_node("id").text != "":
							i.edit_player_data(1,$Button/id.text)
					else:
						i.get_node("id").text = ""
						i.get_node("check").text = ""
						if i.get_node("id").text != "":
							i.edit_player_data(1,$Button/id.text)
				else:
					print("Buy Done")
					i.get_node("id").text = $Button/id.text
					i.get_node("name").text = $Button/name.text
					i.get_node("pos").text = $Button/pos.text
					i.get_node("check").text = $Button/check.text
					i.get_node("image").texture = $Button/image.texture
					i.get_node("ov").text = str_round($Button/ov.text)
					i.get_node("f").text = str_round($Button/f.text)
					i.get_node("m").text = str_round($Button/m.text)
					i.get_node("d").text = str_round($Button/d.text)
					Calculate.stat_color(i.get_node("ov"))
					Calculate.stat_color(i.get_node("f"))
					Calculate.stat_color(i.get_node("m"))
					Calculate.stat_color(i.get_node("d"))
					i.edit_player_data(2,$Button/id.text)
		
	# warning-ignore:unused_variable
		var panelPlayerData = get_parent().get_parent().get_parent().get_parent()
		panelPlayerData.hide()
