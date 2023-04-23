extends Node


static func talk(in_string: String, voiceId:int = 20) -> void:
	var voices = DisplayServer.tts_get_voices_for_language("en")
	
	var data = GameData.get_data(GameData.setting_data_path)
	var vol = data.sound[4]
	
	DisplayServer.tts_stop()
	if DisplayServer.get_name() == "iOS" or OS.get_name() == "OSX":
		DisplayServer.tts_speak(in_string,"com.apple.voice.compact.en-GB.Daniel", vol)
#		"Android", "iOS", "HTML5", "OSX", "Server", "Windows", "UWP", "X11".
	else:
		DisplayServer.tts_speak(in_string,voices[0], vol)
