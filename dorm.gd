extends Scene

@export var wake_point : Node3D
@export var wakeup_scene : Node
@export var alarm_player : AudioPlayer3D

func loaded(_last_scene:String) -> void:
	Status.position_character(wake_point, character)
	#Audio.play("pop_song")
	Audio.play("alarm_sound", alarm_player)
	wakeup_scene.start_wakeup()

func get_your_life_back_on_track() -> void:
	get_tree().quit(420)
