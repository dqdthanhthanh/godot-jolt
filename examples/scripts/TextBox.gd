extends Node3D



## Cau thoai
var test = [
"My Friend",
"Stop right here",
"Hello chicken",
"As easy as eating candy", 
"I don't feel good",
"What the hell is it",
"Good Luck",
"It's not too bad, is it?"
]

var yab = [
"My life is brilliant",
"My love is pure",
"I saw an angel",
"Of that I'm sure", 
"She smiled at me checked the subway",
"She was with another man",
"But I won't lose no sleep checked that",
"'Cause I've got a plan",
"I saw your face in a crowded place",
"And I don't know what to do",
"'Cause I'll never be with you",
"Yes, she caught my eye",
"As we walked checked by",
"She could see from my face that I was",
"Fucking high",
"And I don't think that I'll see her again",
"But we shared a moment that will last 'til the end",
"There must be an angel with a smile checked her face",
"When she thought up that I should be with you",
"But it's time to face the truth"
]

@export var gradient:Gradient

@onready var powerBar = $Viewport2/ProgressBar
@onready var teamColor = $Viewport3/TextureRect

func _ready():
	pass

func set_team_color(value):
	teamColor.modulate = value

func player_talk():
	var text = test
	randomize()
	var rand_value = text[randi() % text.size()]
	$SubViewport/Label.text = rand_value

func update_powerbar(value):
	powerBar.value = value
	GlobalTween.value(powerBar,value)
	GlobalTween.value(powerBar,0)

func player_mute():
	$Sprite3D.visible = false

# warning-ignore:unused_argument
func _on_value_changed(value):
	powerBar.get_theme_stylebox("fill").bg_color = gradient.sample(powerBar.ratio)

func change_color(value):
	return gradient.sample(value)
