extends Node3D



func _on_interactable_3d_triggered() -> void:
	if Status.current_day_string == "recoverynight":
		$fire.emitting = true
		$smokestack.emitting = true
		$firelight.show()
