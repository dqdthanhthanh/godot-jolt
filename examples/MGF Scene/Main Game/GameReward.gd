extends Popup


@onready var icon: = $main/VBoxContainer/icon
@onready var label: = $main/VBoxContainer/label
@onready var info: = $main/VBoxContainer/info
@onready var UI: = get_parent()

@onready var btnClose: = $main/ButtonClose

var test:bool = false

func _ready() -> void:
	if test == true:
		show()
		return_result_match(0,"3-0")

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(0.2).timeout
	hide()

func return_result_match(type:int = 0,text:String = "") -> void:
	var data
	var index:int = 0
	var addon:int = 0
	var labelText:String
	
	if SeasonData.check_season_mode() == true:
		labelText = "Season Match"
		data = GameData.season_load_data()
		if Global.MatchPlay == 1:
			index = data.teams[Global.teamID1].index
		else:
			index = data.teams[Global.teamID2].index
		addon = int(remap(index,1,20,500,0))
		addon = clamp(addon,0,500)
		info.get_node("top").text = str(index)
		node_visible(5,false)
		node_visible(1,true)
	else:
		labelText = "Match"
		node_visible(5,true)
		node_visible(1,false)
	
	var reward:int = 0
	var fan:int = 0
	var infoText:String = ""
	
	match type:
		0:#Win
			labelText += " Win"
			Notification.create_noti(labelText,[text])
			Notification.create_achi(7,"Frist Win Achievement", [text])
			if SeasonData.check_season_mode() == true:
				reward = 2000 + addon
				fan = 1000
			else:
				reward = 1000
				fan = 500
		1:#Loose
			labelText += " Loose"
			Notification.create_noti(labelText,[text])
			Notification.create_achi(8,"Frist Loose Achievement", [text])
			if SeasonData.check_season_mode() == true:
				addon = int(addon/5)
				reward = 500 + addon
				fan = -500
			else:
				reward = 200
				fan = -200
		2:#Draw
			labelText += " Draw"
			Notification.create_noti(labelText,[text])
			Notification.create_achi(9,"Frist Draw Achievement", [text])
			if SeasonData.check_season_mode() == true:
				addon = int(addon/2)
				reward = 1000 + addon
				fan = 0
			else:
				reward = 500
				fan = 0
	
	fan += int(Calculate.rand_num(100))
	var bonus:int = 0
	data = GameData.get_data(GameData.account_data_path)
	var count:int = data.Diamond
	if count > 0:
		bonus = int(count/100)
		reward += bonus
	
	btnClose.connect("pressed", Callable(self, "click_reward").bind(reward,fan))
	
	info.get_node("match").text = text
	info.get_node("gold/info").text = "+ " + str(reward)
	if fan > 0:
		info.get_node("fan/info").text = "+ " + str(abs(fan))
	else:
		info.get_node("fan/info").text = "- " + str(abs(fan))
	info.get_node("all/info").text = "+ " + str(reward)
	show()

func node_visible(type:int = 0,visible:bool = false) -> void:
	icon.get_child(type).visible = visible
	label.get_child(type).visible = visible
	info.get_child(type).visible = visible

func click_reward(reward,fan) -> void:
	btnClose.disconnect("pressed", Callable(self, "click_reward"))
	Account.gold(reward)
	Account.diamond(fan)

func _exit_tree():
	queue_free()
