extends Node3D

var crowdRatio:float = 98
var crowdSize:float = 0.17
@export var row:int = 15
@export var collum:int = 3
var dis:Vector2 = Vector2(5,5)
var ranDisX:float = 0.1

var shader

func create_crowd(crowdRatio) -> void:
	if Global.gameModeCur < 2:
		var player: = load("res://MGF Scene/Main Game/Crowd.tscn")
		var data:FileData = FileData.new()
		var files = data.item.cards
		
		if files.size()>0:
			for a in range(collum):
				for b in range(row):
					if Calculate.rand_ratio(crowdRatio) == true:
						var ins = player.instantiate()
						add_child(ins)
						ins.position.x += b * 1.0 / Calculate.rand_a_num(dis.x,dis.x+ranDisX)
						ins.position.z -= a * 1.0 / dis.y
						ins.position.y += 0.05
						
						##Add Mat
						var count = abs(round(Calculate.rand_a_num(0,files.size()-1)))
#						shader = load("res://Assets3D/Shader/Crowds_mat.tres").duplicate(true)
						shader = load("res://Assets3D/Shader/CrowdShader.tres").duplicate(true)
						shader.albedo_texture = Player.load_icon(files[count].file)
						shader.set_metallic(0)
						shader.set_roughness(0.8)
#						if OS.get_current_video_driver() == 0:
##							shader.set("shader_param/texture_albedo",Player.load_icon(files[count].file).duplicate(true))
#							shader.albedo_texture = Player.load_icon(files[count].file).duplicate(true)
#							shader.set_metallic(1.0)
#							shader.set_roughness(1.0)
#						else:
##							shader.set("shader_param/texture_albedo",Player.load_icon(files[count].file))
#							shader.albedo_texture = Player.load_icon(files[count].file)
#							shader.set_metallic(0)
#							shader.set_roughness(0.8)
						ins.get_child(0).material_override = shader
						ins.get_child(0).scale = Vector3(crowdSize,1,crowdSize)
						if OS.get_name() == "iOS":
							shader.set_metallic(0.3)

func _exit_tree():
	queue_free()
