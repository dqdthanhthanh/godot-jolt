extends Panel


@onready var voicebox = $ACVoicebox
@onready var current_label = $Label
@onready var icon = $Icon

var goal:Array = [
	"What a goal!",
	"What a beauty goal!",
	"What a belter goal!",
	"What a pearler goal!",
	"What a screamer goal!",
	"What a cracker goal!",
	"That's an absolute beauty goal!",
	"That's an absolute screamer goal!",
	"That's an asolute pearler goal!"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))

func _on_voicebox_characters_sounded(characters: String) -> void:
	current_label.text += characters

func talk(value:String, type:bool = true) -> void:
	voicebox.stop()
	current_label.text = ""
	voicebox.play_string(value,0.26)
	voicebox.volume_db = -80

func _exit_tree():
	queue_free()
