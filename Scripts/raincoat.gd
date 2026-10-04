extends Node3D

@export var player : Node3D

func _process(_delta: float) -> void:
	if player == null:
		return
	var look_point : Vector3 = player.position
	look_point.y = position.y
	look_at(look_point)
