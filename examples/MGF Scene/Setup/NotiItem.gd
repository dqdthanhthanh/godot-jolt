extends Button

@onready var time: = $time
@onready var day: = $day
@onready var label: = $label
@onready var info: = $info

@onready var btnDelete: = $ButtonClose

var id:int

func _on_NotifiItem_pressed() -> void:
	Notification.new_active(id)
	Account.panelNotiItem.show()
	Account.panelNotiItem.day.text = day.text
	Account.panelNotiItem.time.text = time.text
	Account.panelNotiItem.label.text = label.text
	Account.panelNotiItem.info.text = info.text

func _on_ButtonClose_pressed() -> void:
	Account.noti_delete_id(id)

func _exit_tree():
	queue_free()
