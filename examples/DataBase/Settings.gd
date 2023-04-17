extends Node

@onready var UIBGNormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIBGN.tres")
@onready var UINormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIN.tres")
@onready var UIPressed:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIP.tres")
@onready var UIVuongNormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIVNO.tres")
@onready var UIVuongPressed:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIVPO.tres")
@onready var UIOpNormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUINO.tres")
@onready var UIOpPressed:StyleBoxFlat = preload("res://Assets2D/Theme/btnUIPO.tres")
@onready var UICNormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnUICN.tres")
@onready var UICPressed:StyleBoxFlat = preload("res://Assets2D/Theme/btnUICP.tres")
@onready var UIDisable:StyleBoxFlat = preload("res://Assets2D/Theme/btnUID.tres")
@onready var UITeam:StyleBoxFlat = preload("res://Assets2D/Theme/btnUITeam.tres")
@onready var UICardNormal:StyleBoxFlat = preload("res://Assets2D/Theme/btnCardN.tres")
@onready var UICardPressed:StyleBoxFlat = preload("res://Assets2D/Theme/btnCardP.tres")

var time:float = 1

var teamColor = {
	0 : [Color.DARK_BLUE,Color.DODGER_BLUE],
	1 : [Color.SIENNA,Color.PERU],
	2 : [Color.TEAL,Color.DARK_TURQUOISE],
	3 : [Color.DIM_GRAY,Color.GRAY],
	4 : [Color.ROYAL_BLUE,Color.CORNFLOWER_BLUE],
	5 : [Color.WEB_MAROON,Color.RED],
	6 : [Color.FOREST_GREEN,Color.LIME_GREEN],
	7 : [Color.REBECCA_PURPLE,Color.MEDIUM_ORCHID],
	8 : [Color.STEEL_BLUE,Color.SKY_BLUE],
	9 : [Color.FIREBRICK,Color.INDIAN_RED],
	10 : [Color.INDIGO,Color.MEDIUM_SLATE_BLUE],
	11 : [Color.CHOCOLATE,Color.ORANGE]
}

var color = teamColor[0]

var ColorUIN:Color = color[0]
var ColorUIP:Color = color[1]

func set_color(value):
	color = teamColor[value]
	
	ColorUIN = color[0]
	ColorUIP = color[1]
	
#	UITeam.set("bg_color",ColorUIN)
#	UIBGNormal.set("bg_color",ColorUIN)
#
#	UINormal.set("bg_color",ColorUIN)
#	UICNormal.set("bg_color",ColorUIN)
#	UIVuongNormal.set("bg_color",ColorUIN)
#	UICardPressed.set("bg_color",ColorUIP)
#
#	UIPressed.set("bg_color",ColorUIP)
#	UICPressed.set("bg_color",ColorUIP)
#	UIVuongPressed.set("bg_color",ColorUIP)
#	UICardNormal.set("bg_color",ColorUIN)
	
	
	color_UI(UIBGNormal,ColorUIN,time)
	color_UI(UITeam,ColorUIN,time)

	color_UI(UINormal,ColorUIN,time)
	color_UI(UICNormal,ColorUIN,time)
	color_UI(UIVuongNormal,ColorUIN,time)
	color_UI(UICardNormal,ColorUIN,time)

	color_UI(UIPressed,ColorUIP,time)
	color_UI(UICPressed,ColorUIP,time)
	color_UI(UIVuongPressed,ColorUIP,time)
	color_UI(UICardPressed,ColorUIP,time)
	
	ColorUIN.a = 0.6
	ColorUIP.a = 0.6
	
#	UIOpNormal.set("bg_color",ColorUIN)
#	UIOpPressed.set("bg_color",ColorUIP)
	
	color_UI(UIOpNormal,ColorUIN,time)
	color_UI(UIOpPressed,ColorUIP,time)

func color_UI(a,b,time):
	var tween: = get_tree().create_tween()
	tween.tween_property(a, "bg_color", b, time)
#	tween.tween_callback(a.queue_free)
