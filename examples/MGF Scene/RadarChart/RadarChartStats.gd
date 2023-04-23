@tool
extends Control

var lineCount:int = 8
var labels:Array = ["MID","TEC","PHY","DEF","GK","SPE","SHO","ATK"]
var stats:Array = [50,50,50,50,50,50,50,50]
var statsMax:Array = [50,50,50,50,50,50,50,50]
var labelPos:float = 1.3

@onready var base: = $RadarChart/Base
@onready var main: = $RadarChart/Stats
@onready var extra: = $RadarChart/StatsMax

#export(int, 0, 100) var lineCount = 8
#export(Array, String) var labels = ["MID","SPE","POW","DEF","GK","BOD","SHO","ATK"]
#export(Array, int) var stats = [50,50,50,50,50,50,50,50]
#export(float, 0, 2) var labelPos = 1.3

func update_radar_stats() -> void:
	base.queue_redraw()
	main.queue_redraw()
	extra.queue_redraw()
