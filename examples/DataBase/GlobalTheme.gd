extends Node

var UIBGNormal:StyleBoxFlat
var UINormal:StyleBoxFlat
var UIPressed:StyleBoxFlat
var UIVuongNormal:StyleBoxFlat
var UIVuongPressed:StyleBoxFlat
var UIOpNormal:StyleBoxFlat
var UIOpPressed:StyleBoxFlat
var UICNormal:StyleBoxFlat
var UICPressed:StyleBoxFlat
var UIDisable:StyleBoxFlat
var UITeam:StyleBoxFlat
var UICardNormal:StyleBoxFlat
var UICardPressed:StyleBoxFlat

var teamColor:Array = [
	[Color.DARK_BLUE,Color.DODGER_BLUE],
	[Color.SIENNA,Color.PERU],
	[Color.TEAL,Color.DARK_TURQUOISE],
	[Color.DIM_GRAY,Color.GRAY],
	[Color.ROYAL_BLUE,Color.CORNFLOWER_BLUE],
	[Color.WEB_MAROON,Color.RED],
	[Color.FOREST_GREEN,Color.LIME_GREEN],
	[Color.REBECCA_PURPLE,Color.MEDIUM_ORCHID],
	[Color.STEEL_BLUE,Color.SKY_BLUE],
	[Color.FIREBRICK,Color.INDIAN_RED],
	[Color.INDIGO,Color.MEDIUM_SLATE_BLUE],
	[Color.CHOCOLATE,Color.ORANGE]
]

var color:Array = teamColor[0]

var ColorUIN:Color = color[0]
var ColorUIP:Color = color[1]

func set_color(value,time:float = 1.0) -> void:
	UIBGNormal = load("res://Assets2D/Theme/btnUIBGN.tres")
	UINormal = load("res://Assets2D/Theme/btnUIN.tres")
	UIPressed = load("res://Assets2D/Theme/btnUIP.tres")
	UIVuongNormal = load("res://Assets2D/Theme/btnUIVNO.tres")
	UIVuongPressed = load("res://Assets2D/Theme/btnUIVPO.tres")
	UIOpNormal = load("res://Assets2D/Theme/btnUINO.tres")
	UIOpPressed = load("res://Assets2D/Theme/btnUIPO.tres")
	UICNormal = load("res://Assets2D/Theme/btnUICN.tres")
	UICPressed = load("res://Assets2D/Theme/btnUICP.tres")
	UIDisable = load("res://Assets2D/Theme/btnUID.tres")
	UITeam = load("res://Assets2D/Theme/btnUITeam.tres")
	UICardNormal = load("res://Assets2D/Theme/btnCardN.tres")
	UICardPressed = load("res://Assets2D/Theme/btnCardP.tres")

	color = teamColor[int(value)]
	
	ColorUIN = color[0]
	ColorUIP = color[1]
	
#	UINormal.set("bg_color",ColorUIN)
#	UICNormal.set("bg_color",ColorUIN)
	
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
	
	color_UI(UIOpNormal,ColorUIN,time)
	color_UI(UIOpPressed,ColorUIP,time)

func color_UI(a,b,time) -> void:
	var tween: = get_tree().create_tween()
	tween.tween_property(a, "bg_color", b, time)
