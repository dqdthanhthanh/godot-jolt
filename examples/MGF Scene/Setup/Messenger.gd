extends CanvasLayer

@onready var panel = $Popup
@onready var label = $Popup/Panel/VBoxContainer/Label
@onready var btnYes = $Popup/Panel/VBoxContainer/HBoxContainer/BtnYes
@onready var btnNo = $Popup/Panel/VBoxContainer/HBoxContainer/BtnNo
@onready var allBtn = $Popup/Panel/VBoxContainer/HBoxContainer


func _ready():
	panel.show()
	var data = GameData.get_data(GameData.data_path)
	var oldVer = data.settings.ver
	var newVer = FileData.db.settings.ver
	Global.ver = newVer
	
	#Force Update
	if str(newVer) != str(oldVer):
		push_notification(0,"You have new update version " + newVer)
		GameData.create_file_data()
	else:
		push_notification(0,"Version " + newVer)

func push_notification(type = 0, value = "",funcType=null,obj=null,Func=null,param=null):
	panel.show()
	btnYes.show()
	btnNo.show()
	allBtn.show()
	label.text = value
	match type:
		0:
			btnNo.hide()
		1:
			btnNo.show()
		2:
			allBtn.hide()
			
	if funcType != null:
		var btn
		
		if type == 0:
			btn = btnYes
		else:
			btn = btnNo
		
#		btn.disconnect("pressed",Callable(obj,Func))
		if param != null:
			btn.connect("pressed",Callable(obj,Func).bind(param))
		else:
			btn.connect("pressed",Callable(obj,Func))


func _on_ButtonClose_pressed():
	panel.hide()


func _on_btn_yes_pressed():
	panel.hide()


func _on_btn_no_pressed():
	panel.hide()
