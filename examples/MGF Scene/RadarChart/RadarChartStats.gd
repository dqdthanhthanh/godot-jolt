@tool
extends Control

var lineCount = 8
var labels = ["MID","TEC","PHY","DEF","GK","SPE","SHO","ATK"]
var stats = [50,50,50,50,50,50,50,50]
var labelPos = 1.4

@onready var base = $RadarChart/Base
@onready var main = $RadarChart/Stats

#export var lineCount = 8 # (int, 0, 100)
#export var labels = ["MID","SPE","POW","DEF","GK","BOD","SHO","ATK"] # (Array, String)
#export var stats = [50,50,50,50,50,50,50,50] # (Array, int)
#export var labelPos = 1.3 # (float, 0, 2)

func update_radar_stats():
	base.queue_redraw()
	main.queue_redraw()
	

