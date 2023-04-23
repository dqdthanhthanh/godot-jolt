extends Popup


@onready var icon: = $main/VBoxContainer/icon
@onready var label: = $main/VBoxContainer/label
@onready var info: = $main/VBoxContainer/info
@onready var top: = $main/icon


@onready var btnClose: = $main/ButtonClose

var test:bool = false

func _ready() -> void:
	if test == true:
		show()
		return_result_reward()

func reward():
	show()
	return_result_reward()

func _on_ButtonClose_pressed() -> void:
	SceneTransition.transition()
	await get_tree().create_timer(0.2).timeout
	hide()

func return_result_reward(type:int = 0,text:String = "") -> void:
	var data
	var index:int = 0
	
#	if SeasonData.check_season_mode() == true:
	data = GameData.season_load_data()
	index = data.teams[SeasonData.teamA].index
	if test == true:
		index = 15
	info.get_node("top").text = str(index)
	
	var reward:int = int(remap(index,1,20,100000,20000))
	reward = clamp(reward,0,100000)
	reward += int(Calculate.rand_num(1000))
	
	var fan:int = int(remap(index,1,20,10000,-5000))
	fan = clamp(fan,-5000,10000)
	fan += int(Calculate.rand_num(1000))
	
	if index == 1:
		top.texture = load("res://Assets2D/UI/IconCup.png")
		top.get_node("label").show()
		top.get_node("label").text = str(1)
		reward += 50000
		fan += 10000
	else:
		top.texture = load("res://Assets2D/UI/iconStar.png")
	
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
