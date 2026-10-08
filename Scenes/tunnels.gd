extends Node3D

var character : Node3D

@export var spawnpoint : Node3D

func loaded(_last_scene:String) -> void:
	Audio.play("through_the_tunnels", null, false)
	var spawn_pos : Node3D = spawnpoint
	Status.position_character(spawn_pos, character)
