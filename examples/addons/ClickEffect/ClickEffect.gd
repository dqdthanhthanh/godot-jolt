extends CanvasLayer

@onready var spriteIns = preload("res://addons/ClickEffect/ClickSprite.tscn")
@onready var addEffect = $AddEffectClick
@onready var drawForce = $DrawForce
@onready var drawForceAI = $DrawForceAI
@onready var tween: Tween

func _ready():
#	UINormal.get_theme_stylebox("panel").bg_color = Color.NAVY_BLUE
	$AddEffectClick/Sprite2D.hide()
	$AddEffectClick/Sprite2D.queue_free()

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("click"):
			SoundGlobal.get_node("SfxrClick").play()
			create_ins_effect(event)

	if event is InputEventScreenTouch:
		if event.index == 1 and event.is_pressed():
			SoundGlobal.get_node("SfxrClick").play()
			create_ins_effect(event)

func create_ins_effect(event):
	var ins = spriteIns.instantiate()
	addEffect.add_child(ins)
	ins.position = event.position
	GlobalTween.rot(ins,360)
	await get_tree().create_timer(0.5).timeout
	GlobalTween.fade_out(ins,0.5)

func stop_effect_click():
	if addEffect.get_child_count() > 0:
		for unit in addEffect.get_children():
			unit.hide()
