extends AudioStreamPlayer
class_name ACVoiceBox

signal characters_sounded(characters)
signal finished_phrase()

var effect = AudioServer.get_bus_effect(4, 0)

const PITCH_MULTIPLIER_RANGE := 0.3
const INFLECTION_SHIFT := 0.4

@export var voiceSpeed := 3.5 # (float, 2, 5)
@export var voiceType := 0.5 # (float, 0, 2)

const maleSounds = {
	'a': preload('res://addons/ACVoice/Sounds/a.wav'),
	'b': preload('res://addons/ACVoice/Sounds/b.wav'),
	'c': preload('res://addons/ACVoice/Sounds/c.wav'),
	'd': preload('res://addons/ACVoice/Sounds/d.wav'),
	'e': preload('res://addons/ACVoice/Sounds/e.wav'),
	'f': preload('res://addons/ACVoice/Sounds/f.wav'),
	'g': preload('res://addons/ACVoice/Sounds/g.wav'),
	'h': preload('res://addons/ACVoice/Sounds/h.wav'),
	'i': preload('res://addons/ACVoice/Sounds/i.wav'),
	'j': preload('res://addons/ACVoice/Sounds/j.wav'),
	'k': preload('res://addons/ACVoice/Sounds/k.wav'),
	'l': preload('res://addons/ACVoice/Sounds/l.wav'),
	'm': preload('res://addons/ACVoice/Sounds/m.wav'),
	'n': preload('res://addons/ACVoice/Sounds/n.wav'),
	'o': preload('res://addons/ACVoice/Sounds/o.wav'),
	'p': preload('res://addons/ACVoice/Sounds/p.wav'),
	'q': preload('res://addons/ACVoice/Sounds/q.wav'),
	'r': preload('res://addons/ACVoice/Sounds/r.wav'),
	's': preload('res://addons/ACVoice/Sounds/s.wav'),
	't': preload('res://addons/ACVoice/Sounds/t.wav'),
	'u': preload('res://addons/ACVoice/Sounds/u.wav'),
	'v': preload('res://addons/ACVoice/Sounds/v.wav'),
	'w': preload('res://addons/ACVoice/Sounds/w.wav'),
	'x': preload('res://addons/ACVoice/Sounds/x.wav'),
	'y': preload('res://addons/ACVoice/Sounds/y.wav'),
	'z': preload('res://addons/ACVoice/Sounds/z.wav'),
	'th': preload('res://addons/ACVoice/Sounds/th.wav'),
	'sh': preload('res://addons/ACVoice/Sounds/sh.wav'),
	' ': preload('res://addons/ACVoice/Sounds/blank.wav'),
	'.': preload('res://addons/ACVoice/Sounds/longblank.wav'),
}

const numberSound = {
	'0': [maleSounds.z,maleSounds.e,maleSounds.r,maleSounds.o],
	'1': [maleSounds.o,maleSounds.n,maleSounds.e],
	'2': [maleSounds.t,maleSounds.w,maleSounds.o],
	'3': [maleSounds.t,maleSounds.h,maleSounds.r,maleSounds.e,maleSounds.e],
	'4': [maleSounds.f,maleSounds.o,maleSounds.u,maleSounds.r],
	'5': [maleSounds.f,maleSounds.i,maleSounds.v,maleSounds.e],
	'6': [maleSounds.s,maleSounds.i,maleSounds.x],
	'7': [maleSounds.s,maleSounds.e,maleSounds.v,maleSounds.e,maleSounds.n],
	'8': [maleSounds.e,maleSounds.i,maleSounds.g,maleSounds.h,maleSounds.t],
	'9': [maleSounds.n,maleSounds.i,maleSounds.n,maleSounds.e],
	}

var remaining_sounds := []

var soundsDic
var voiceSex:bool = true

func _ready() -> void:
	soundsDic = maleSounds
	connect("finished", Callable(self, "play_next_sound"))

func play_string(in_string: String,voice:float = 0.3,speed:float = 3.5) -> void:
	voiceSpeed = speed
	effect.pitch_scale = voice
	parse_input_string(in_string)
	play_next_sound()

func play_next_sound(type:bool = true) -> void:
	if len(remaining_sounds) == 0:
		emit_signal("finished_phrase")
		return
	var next_symbol = remaining_sounds.pop_front()
	emit_signal("characters_sounded", next_symbol.characters)
	# Skip to next sound if no sound exists for text
	if next_symbol.sound == '':
		play_next_sound()
		return
	var sound = soundsDic[next_symbol.sound]
	if next_symbol.sound in ["0","1","2","3","4","5","6","7","8","9","10"]:
#		print(numberSound.get(next_symbol.sound))
		for i in numberSound.get(next_symbol.sound).size():
			pitch_scale = voiceSpeed + (PITCH_MULTIPLIER_RANGE * randf()) + (INFLECTION_SHIFT if next_symbol.inflective else 0.0)	
			stream = numberSound.get(next_symbol.sound)[i]
			play()
			await get_tree().create_timer(0.1).timeout
	else:
#		print(next_symbol.sound)
#		print(numberSound.get("0"))
#		sound.mix_rate = 55000
	# Add some randomness to pitch plus optional inflection for end word in questions
		pitch_scale = voiceSpeed + (PITCH_MULTIPLIER_RANGE * randf()) + (INFLECTION_SHIFT if next_symbol.inflective else 0.0)	
		stream = sound
		play()


func parse_input_string(in_string: String) -> void:
	for word in in_string.split(' '):
		parse_word(word)
		add_symbol(' ', ' ', false)
	

func parse_word(word: String) -> void:
	var skip_char := false
	var is_inflective := word[-1] == '?'
	for i in range(len(word)):
		if skip_char:
			skip_char = false
			continue
		# If not the last letter, check if next letter makes a two letter substring, e.g. 'th'
		if i < len(word) - 1:
			var two_character_substring = word.substr(i, i+2)
			if two_character_substring.to_lower() in soundsDic.keys():
				add_symbol(two_character_substring.to_lower(), two_character_substring, is_inflective)
				skip_char = true
				continue
		# Otherwise check if single character has matching sound, otherwise add a blank character
		if word[i].to_lower() in soundsDic.keys():
			add_symbol(word[i].to_lower(), word[i], is_inflective)
		else:
			add_symbol('', word[i], false)


func add_symbol(sound: String, characters: String, inflective: bool) -> void:
	remaining_sounds.append({
		'sound': sound,
		'characters': characters,
		'inflective': inflective
	})

func _exit_tree():
	queue_free()
