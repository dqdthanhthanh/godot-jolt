extends CanvasLayer

@onready var lines = $Lines
@onready var layers = $Layers/ScrollContainer/MainBtn

var LineCur:int = 0
@onready var LineIns= preload("res://addons/CreateCharacter/Line.tscn")
var layerCur:int = 0
@onready var layerIns= preload("res://addons/CreateCharacter/Layer.tscn")

var sizeCur: float = 15
var lineColorCur = Color.BLACK
var polyColorCur = [Color.WHITE]

var options:int = 0

func _ready():
	layers.get_child(layerCur).connect("pressed",Callable(self,"layer_select").bind(layers.get_child(layerCur).id))
	layers.get_child(layerCur).get_node("CheckButton").connect("pressed",Callable(self,"layer_visible").bind(layers.get_child(layerCur).id))

func _input(event: InputEvent):
	if event is InputEventSingleScreenTap:
		var myLine = lines.get_child(LineCur)
		myLine.points.append(event.position)
		myLine.update()

func layer_select(id):
	LineCur = id
	GlobalTween.show_out($Tween,lines.get_child(id),0.5)
	match options:
		0:
			$ColorPicker.color = lines.get_child(id).lineColor
		1:
			$ColorPicker.color = lines.get_child(id).polyColor[0]

func layer_visible(id):
	lines.get_child(id).visible = layers.get_child(id).get_node("CheckButton").pressed

func _on_CreateLayer_pressed():
	var insLine = LineIns.instantiate()
	lines.add_child(insLine)
	var insLayer = layerIns.instantiate()
	insLayer.id = layers.get_child_count()
	LineCur = insLayer.id
	insLayer.text = "Layer " + str(layers.get_child_count())
	insLayer.connect("pressed",Callable(self,"layer_select").bind(insLayer.id))
	insLayer.get_node("CheckButton").connect("pressed",Callable(self,"layer_visible").bind(insLayer.id))
	layers.add_child(insLayer)

func _on_Save_pressed():
	# Duplicate the node (prevents an error)
	var blocks = lines.duplicate()

	# Setting it as owner of children
	for child in blocks.get_children():
		child.set_owner(blocks)

	# Continue to save
	var save_build  = PackedScene.new()
	save_build.pack(blocks)
	ResourceSaver.save("res://addons/CreateCharacter/my_character.tscn", save_build)


func _on_ButtonLine_pressed():
	options = 0
	$ColorPicker.color = lines.get_child(LineCur).lineColor

func _on_ButtonColor_pressed():
	options = 1
	$ColorPicker.color = lines.get_child(LineCur).polyColor[0]

func _on_ColorPicker_color_changed(color):
	match options:
		0:
			lines.get_child(LineCur).lineColor = color
		1:
			lines.get_child(LineCur).polyColor = [color]
	lines.get_child(LineCur).update()

func _on_HSlider_value_changed(value):
	lines.get_child(LineCur).size = value
	$Label.text = str(value)
	lines.get_child(LineCur).update()

