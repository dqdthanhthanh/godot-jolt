extends MeshInstance3D

func mesh_select(alpha) -> void:
	var teamAMat:Color = GlobalTheme.teamColor[Global.teamID1][1]
	var teamBMat:Color = GlobalTheme.teamColor[Global.teamID2][1]
	teamAMat.a = 0.6
	teamBMat.a = 0.6
	if get_parent().team == 1:
		material_override.albedo_color = teamAMat
	else:
		material_override.albedo_color = teamBMat
	GlobalTween.mesh_tween_color(material_override,alpha,1)

func _process(delta) -> void:
	if material_override.albedo_color.a != 0:
		rotation_degrees.y += delta*40

func _exit_tree():
	queue_free()
