extends Control


@onready var voicebox = $ACVoicebox
@onready var current_label = $VBoxContainer/RichTextLabel

@onready var groupFeedBack = $FeedBack/Group/Icon
@onready var groupSocial = $VBoxContainer/Social/Group/Icon
@onready var groupDownload = $VBoxContainer/Download/Group/Icon

var social_data = [
	"https://twitter.com/mgf_game",
	"https://www.facebook.com/mgfgame",
	"https://www.youtube.com/channel/UC6dvGg2DzwfhtXFKM-7ec3A",
	"https://mgf-game.itch.io/mgf",
	"https://gotm.io/mgf-game/mgf"
]

var download_link = [
	"https://mgf-game.itch.io/mgf",
	"https://mgf-game.itch.io/mgf",
	"https://mgf-game.itch.io/mgf",
	"https://mgf-game.itch.io/mgf",
	"https://play.google.com/store/apps/details?id=mgfgame.magicfootballworld"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))
	talk("Magic FootBall World - Football Fantasy Turnbase Game." + "\n" + 
	"Hope you like it and please follow for news and new updates!!!" + "\n" + 
	"Your feedback is invaluable! Thanks!!!")
	
	for i in groupSocial.get_child_count():
		groupSocial.get_child(i).connect("pressed", Callable(self, "open_link").bind(social_data[i]))
	for i in groupDownload.get_child_count():
		groupDownload.get_child(i).connect("pressed", Callable(self, "open_link").bind(download_link[i]))

func open_link(link):
	OS.shell_open(link)

func _on_voicebox_characters_sounded(characters: String) -> void:
	current_label.text += characters

func talk(value:String, type:bool = true) -> void:
	voicebox.stop()
	current_label.text = ""
	voicebox.play_string(value,0.2,30)
#	if Global.device_is_mobile() and type == true:
#		voicebox.volume_db = -5
#	else:
#		voicebox.volume_db = -80

func _exit_tree():
	queue_free()

