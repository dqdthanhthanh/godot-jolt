extends Node2D

var points = []
var id: int = 0
var size: float = 20
var lineColor = Color.BLACK
var polyColor = [Color.RED]

var posFix = Vector2(900,800)

func _input(event: InputEvent):
	if event is InputEventSingleScreenTap:
		var pos = Vector2((event.position.x-900),(event.position.y-800))
		points.append(pos)
		update()

func _draw():
	for i in points.size():
		draw_circle(points[i],size/2,lineColor)
	if points.size() > 1:
		var p1 = points[0]
		var p2 = points[points.size()-1]
		draw_line(p1,p2,lineColor,size)
	draw_polyline(points,lineColor,size)
	draw_polygon(points,polyColor)
