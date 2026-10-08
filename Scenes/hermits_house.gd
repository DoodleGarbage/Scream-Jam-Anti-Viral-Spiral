extends Node3D

@export var folly_spawn : Node3D
var character : Node3D

func loaded(_last_scene:String) -> void:
	Audio.play("through_the_tunnels", null, true, 3.5)
	var spawn_pos = folly_spawn
	Status.position_character(spawn_pos, character)
