extends CanvasLayer


var team:int = 10
var state = "Start"

var stats:Array = []

func _ready() -> void:
	if Global.isDebug == false:
		queue_free()

func add_stat(stat_name, object, stat_ref, is_method) -> void:
	stats.append([stat_name, object, stat_ref, is_method])

func _process(delta) -> void:
#	if OS.has_feature("editor"):
	if Global.isDebug == true:
		var label_text = ""
		
		label_text += str("mode",": " ,str(Global.MGFMode))
		label_text += "\n"
		
		var fps = Engine.get_frames_per_second()
#		label_text += str("FPS: ", fps)
		label_text += str(state,": " ,fps)
		label_text += "\n"
		
		var mem = OS.get_static_memory_usage()
		label_text += str("Static Memory: ", String.humanize_size(mem))
#		label_text += "\n"
		
		for s in stats:
			var value = null
			
			if s[1] and weakref(s[1]).get_ref():
				if s[3]:
					value = s[1].call(s[2])
				else:
					value = s[1].get(s[2])
			label_text += str(s[0], ": ", value)
			label_text += "\n"
		
		$Label.text = label_text
	else:
		$Label.text = ""

func _exit_tree():
	queue_free()
