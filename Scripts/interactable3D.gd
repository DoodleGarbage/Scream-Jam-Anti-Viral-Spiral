extends Area3D

class_name Interactable3D

## The text displayed on screen when hovered.
@export var desc : String = ""

@export_subgroup("Scene Switch")
@export var switch_scenes : bool = false
@export var target_scene : String = ""

signal switch_scene
func trigger_effects() -> void:
	if switch_scenes:
		switch_scene.emit(target_scene)
