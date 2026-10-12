extends Scene

@export var spawn_point : Node3D
@export var car : Node3D
@export var blackout : Control
@export var car_horn_audio_player : AudioPlayer3D
@export var car_crash_audio_player : AudioPlayer3D
@export var car_speed : float = 60
## When to trigger the horn (in seconds), based on the car speed and distance from player
@export var horn_time : float = 4.5
## Same as horn time
@export var crash_time : float = 1.8
#@export var crash


var car_active : bool = true
var horn_triggered : bool = false
var crash_triggered : bool = false

func loaded(_last_scene:String) -> void:
	character.in_air_momentum = true
	Status.position_character(spawn_point, character)


func _on_player_fall() -> void:
	print("player has fallen")
	character.base_speed = Status.character_base_speed * 0.25
	character.sprint_speed = Status.character_sprint_speed * 0.25
	character.jumping_enabled = false
	#car_active = true

func _process(_delta: float) -> void:
	if car_active:
		if not horn_triggered and (car.global_position.distance_to(character.global_position) / car_speed) <= horn_time:
			horn_triggered = true
			Audio.play("car_horn", car_horn_audio_player)
		if not crash_triggered and (car.global_position.distance_to(character.global_position) / car_speed) <= crash_time:
			crash_triggered = true
			Audio.stop("car_horn", true, 1.0)
			Audio.play("car_crash", car_crash_audio_player)
			await get_tree().create_timer(0.8).timeout
			blackout.show()
			character.in_air_momentum = false
			character.base_speed = Status.character_base_speed
			character.sprint_speed = Status.character_sprint_speed
		car.position.z -= car_speed * _delta


#func _on_ground_detector_body_entered() -> void:
	#car_active = true
	#total_dist = car.global_position.distance_to(character.global_position)
