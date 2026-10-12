extends Scene

@export var spawn_point : Node3D

func loaded(_last_scene:String) -> void:
	Status.end_day()
	Status.woke_up = true
	Status.completed_tasks_names = Status.ROUTINE_TASKS
	Status.completed_tasks = 3
	Audio.play("someplace_calm", null, true)
	Status.completed_childhood = true
	Status.position_character(spawn_point, character)
