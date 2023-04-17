extends Node2D

var points = []
var id: int = 0
var size: float = 20
var lineColor = Color.BLACK
var polyColor = [Color.WHITE]


func _draw():
	for i in points.size():
		draw_circle(points[i],size/2,lineColor)
	if points.size() > 1:
		var p1 = points[0]
		var p2 = points[points.size()-1]
		draw_line(p1,p2,lineColor,size)
	draw_polyline(points,lineColor,size)
	draw_polygon(points,polyColor)
