extends Button

@onready var time = $time
@onready var day = $day
@onready var label = $label
@onready var info = $info

@onready var btnDelete = $ButtonClose

@onready var account = get_parent().get_parent().get_parent().get_parent()

var id

func _on_NotifiItem_pressed():
	NotiData.new_active(id)
	account.panelNotiItem.show()
	account.panelNotiItem.day.text = day.text
	account.panelNotiItem.time.text = time.text
	account.panelNotiItem.label.text = label.text
	account.panelNotiItem.info.text = info.text


func _on_ButtonClose_pressed():
	account.noti_delete_id(id)
