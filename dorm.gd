extends Scene

@export var wake_point : Node3D

func loaded(_last_scene:String) -> void:
	Status.position_character(wake_point, character)
