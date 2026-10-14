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

var triggered_genny_room_audio : bool = false
func _on_entered_genny_room_body_entered(body: Node3D) -> void:
	if body != character or triggered_genny_room_audio:
		return
	Audio.stop_themes(true, 16)
	Audio.play("tunnels_of_dread", null, true, 10)
	triggered_genny_room_audio = true
