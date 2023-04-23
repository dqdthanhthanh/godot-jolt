extends Control


@onready var voicebox: ACVoiceBox = $ACVoicebox


@onready var conversation: = [
	[$Label1, "1234567890 Hey look 1234567890", 0.3],
#	[$Label1, "Hey look, I've made this Animal Crossing style conversation player in Godot!", 0.3],
	[$Label2, "Wow, this would be great for placeholder dialogue sounds in my project! How can I use this?", 0.3],
	[$Label3, "Check out the instructions on the repo at https://github.com/mattmarch/ACVoicebox", 0.3],
	[$Label4, "Awesome, I'll have a look. Thanks a lot!", 0.3]
	]


var current_label: Label


func _ready() -> void:
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))
	voicebox.connect("finished_phrase", Callable(self, "_on_voicebox_finished_phrase"))
	play_next_in_conversation()


func _on_voicebox_characters_sounded(characters: String):
	current_label.text += characters

func _on_voicebox_finished_phrase() -> void:
	if conversation.size() > 0:
		play_next_in_conversation()

func play_next_in_conversation() -> void:
	var next_conversation = conversation.pop_front()
	current_label = next_conversation[0]
	voicebox.play_string(next_conversation[1],next_conversation[2])

func _exit_tree():
	queue_free()
