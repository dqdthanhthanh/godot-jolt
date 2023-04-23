extends Node3D

@onready var voicebox: ACVoiceBox = $ACVoicebox

## Cau thoai
var playerTalk:Array = [
	"Stop right here",
	"I don't feel good",
	"What the hell is it",
	"Good Luck",
	"It's not too bad, is it?",
	"That's a brilliant time to score",
	"We can get back into this now!",
	"I think we're going to win this",
	"We can turn this around, you know",
	"There's no way back for them now",
	"We've broken the deadlock at last",
]

@export var gradient:Gradient

@onready var current_label: = $Sprite3D/Label3D
@onready var powerBar: = $SubViewport/ProgressBar
@onready var teamColor: = $Viewport1/TextureRect

@onready var shader_bar: = preload("res://Assets2D/Theme/FormationStaminaShader.tres").duplicate()

var tween:Tween

func _ready() -> void:
#	powerBar.get_stylebox("fg").duplicate(true)
	current_label.text = ""
	voicebox.connect("characters_sounded", Callable(self, "_on_voicebox_characters_sounded"))

func set_team_color(value) -> void:
	teamColor.modulate = value

func _on_voicebox_characters_sounded(characters: String) -> void:
	current_label.text += characters

func player_talk() -> void:
	current_label.text = ""
	var text = playerTalk
	randomize()
	var rand_value = text[randi() % text.size()]
	voicebox.stop()
	voicebox.play_string(rand_value,get_parent().playerData.Voice[0])

func player_mute() -> void:
	current_label.text = ""

func update_powerbar(value) -> void:
	powerBar.value = value
	tween_value(powerBar,0)

func tween_value(obj,x,time:float = 1.0) -> void:
	pass
	tween = get_tree().create_tween()
	tween.tween_property(obj,"value",x,time)
	tween.tween_callback(queue_free)

func _on_ProgressBar_value_changed(value) -> void:
	pass
#	set("theme_override_styles/fg",shader_bar)
#	shader_bar.bg_color = gradient.sample(value/100)

func _exit_tree():
	queue_free()
