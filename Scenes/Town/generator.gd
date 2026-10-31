extends Node3D

@export var audio_player : AudioPlayer3D
@export var broken_particles : GPUParticles3D

func _ready() -> void:
	if Status.in_recovery:
		working()
		return
	
	match(Status.current_day_string):
		"day1", "night1", "recovery", "recoverynight":
			working()
		_:
			broken()


func working() -> void:
	Audio.play("generator", audio_player)
	$generator.show()
	$generator_broken.hide()
	return


func broken() -> void:
	Audio.play("broken_generator", audio_player)
	broken_particles.show()
	$generator_broken.show()
	$generator.hide()
	return
