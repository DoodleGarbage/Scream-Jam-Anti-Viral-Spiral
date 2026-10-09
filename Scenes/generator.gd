extends Node3D

@export var audio_player : AudioPlayer3D
@export var broken_particles : GPUParticles3D

func _ready() -> void:
	match(Status.current_day_string):
		"day1":
			Audio.play("generator", audio_player)
		_:
			Audio.play("broken_generator", audio_player)
			broken_particles.show()
