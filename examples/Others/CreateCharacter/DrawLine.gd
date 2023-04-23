@tool
extends Node2D

func _ready() -> void:
	update()

func _draw():
	var points = get_parent().polygon
	var lineColor = get_parent().lineColor
	var polyColor = [get_parent().polyColor]
	var size = get_parent().size
	for i in points.size():
		draw_circle(points[i],size/2,lineColor)
	if points.size() > 1:
		var p1 = points[0]
		var p2 = points[points.size()-1]
		draw_line(p1,p2,lineColor,size)
	draw_polyline(points,lineColor,size)
	draw_polygon(points,polyColor)
