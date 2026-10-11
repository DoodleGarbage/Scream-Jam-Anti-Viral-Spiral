extends RigidBody3D

func _physics_process(_delta: float) -> void:
	if global_position.y < -10:
		queue_free()
