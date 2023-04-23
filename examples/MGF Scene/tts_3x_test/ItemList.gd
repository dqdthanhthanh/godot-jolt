extends Control

var id = 0 #utterance id
var ut_map = {}
var vs

func _ready():
	# get voice data
	vs = OS.tts_get_voices()
	var root = $Tree.create_item()
	$Tree.set_hide_root(true)
	$Tree.set_column_title(0, "Name")
	$Tree.set_column_title(1, "Language")
	$Tree.set_column_titles_visible(true)
	for v in vs:
		var child = $Tree.create_item(root)
		child.set_text(0, v["name"])
		child.set_metadata(0, v["id"])
		child.set_text(1, v["language"])
	$Log.text += "%d voices available\n" % [vs.size()]
	$Log.text += "=======\n"

	# add callbacks
	OS.tts_set_utterance_callback(OS.TTS_UTTERANCE_STARTED, self, "_on_utterance_start")
	OS.tts_set_utterance_callback(OS.TTS_UTTERANCE_ENDED, self, "_on_utterance_end")
	OS.tts_set_utterance_callback(OS.TTS_UTTERANCE_CANCELED, self, "_on_utterance_error")
	OS.tts_set_utterance_callback(OS.TTS_UTTERANCE_BOUNDARY, self, "_on_utterance_boundary")
	set_process(true)

func _process(delta):
	$ButtonPause.button_pressed = OS.tts_is_paused()
	if OS.tts_is_speaking():
		$ColorRect.color = Color(1, 0, 0)
	else:
		$ColorRect.color = Color(1, 1, 1)

func _on_utterance_boundary(pos, id):
	$RichTextLabel.text = "[color=red]" + ut_map[id].substr(0, pos) + "[/color]" + ut_map[id].substr(pos, -1)

func _on_utterance_start(id):
	$Log.text += "utterance %d started\n" % [id]

func _on_utterance_end(id):
	$RichTextLabel.text = "[color=red]" + ut_map[id] + "[/color]"
	$Log.text += "utterance %d ended\n" % [id]
	ut_map.erase(id)

func _on_utterance_error(id):
	$RichTextLabel.text = ""
	$Log.text += "utterance %d canceled/failed\n" % [id]
	ut_map.erase(id)

func _on_ButtonStop_pressed():
	OS.tts_stop()

func _on_ButtonPause_pressed():
	if $ButtonPause.pressed:
		OS.tts_pause()
	else:
		OS.tts_resume()

func _on_ButtonSpeak_pressed():
	if $Tree.get_selected():
		$Log.text += "utterance %d queried\n" % [id]
		ut_map[id] = $Utterance.text
		OS.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, false)
		id += 1
	else:
		OS.alert("Select voice.")
	prints($Tree.get_selected().get_metadata(0),"id")

func _on_ButtonIntSpeak_pressed():
	if $Tree.get_selected():
		$Log.text += "utterance %d interrupt\n" % [id]
		ut_map[id] = $Utterance.text
		OS.tts_speak($Utterance.text, $Tree.get_selected().get_metadata(0), $HSliderVolume.value, $HSliderPitch.value, $HSliderRate.value, id, true)
		id += 1
	else:
		OS.alert("Select voice.")

func _on_ButtonClearLog_pressed():
	$Log.text = ""

func _on_HSliderRate_value_changed(value):
	$HSliderRate/Value.text = "%.2fx" % [value]

func _on_HSliderPitch_value_changed(value):
	$HSliderPitch/Value.text = "%.2fx" % [value]

func _on_HSliderVolume_value_changed(value):
	$HSliderVolume/Value.text = "%d%%" % [value]

func _on_Button_pressed():
	var vc
	#demo - en
	vc = OS.tts_get_voices_for_language("en")
	if !vc.is_empty():
		ut_map[id] = "Beware the Jabberwock, my son!"
		ut_map[id + 1] = "The jaws that bite, the claws that catch!"
		OS.tts_speak("Beware the Jabberwock, my son!", vc[0], 50, 1, 1, id)
		OS.tts_speak("The jaws that bite, the claws that catch!", vc[0], 50, 1, 1, id + 1)
		id += 2
	#demo - es
	vc = OS.tts_get_voices_for_language("es")
	if !vc.is_empty():
		ut_map[id] = "¡Cuidado, hijo, con el Fablistanón!"
		ut_map[id + 1] = "¡Con sus dientes y garras, muerde, apresa!"
		OS.tts_speak("¡Cuidado, hijo, con el Fablistanón!", vc[0], 50, 1, 1, id)
		OS.tts_speak("¡Con sus dientes y garras, muerde, apresa!", vc[0], 50, 1, 1, id + 1)
		id += 2
	#demo - ru
	vc = OS.tts_get_voices_for_language("ru")
	if !vc.is_empty():
		ut_map[id] = "О, бойся Бармаглота, сын!"
		ut_map[id + 1] = "Он так свирлеп и дик!"
		OS.tts_speak("О, бойся Бармаглота, сын!", vc[0], 50, 1, 1, id)
		OS.tts_speak("Он так свирлеп и дик!", vc[0], 50, 1, 1, id + 1)
		id += 2

func _on_LineEditFilterName_text_changed(new_text):
	$Tree.clear()
	var root = $Tree.create_item()
	for v in vs:
		if ($LineEditFilterName.text.is_empty() || $LineEditFilterName.text.to_lower() in v["name"].to_lower()) && ($LineEditFilterLang.text.is_empty() || $LineEditFilterLang.text.to_lower() in v["language"].to_lower()):
			var child = $Tree.create_item(root)
			child.set_text(0, v["name"])
			child.set_metadata(0, v["id"])
			child.set_text(1, v["language"])
