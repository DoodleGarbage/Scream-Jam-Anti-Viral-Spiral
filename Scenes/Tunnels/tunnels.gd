extends Scene

#var character : Node3D

@export var flourescent_buzzer : AudioPlayer3D
@export var spawnpoint : Node3D

func loaded(_last_scene:String) -> void:
	Audio.play("tunneling_through", null, false)
	#Audio.play("flourescent_buzz", flourescent_buzzer, false)
	var spawn_pos : Node3D = spawnpoint
	Status.position_character(spawn_pos, character)

func _process(_delta: float) -> void:
	flourescent_buzzer.global_position = character.global_position + Vector3(0, 3, 0)
