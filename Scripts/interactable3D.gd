extends Area3D

class_name Interactable3D

## The text displayed on screen when hovered.
@export var desc : String = ""
## Used for any sound effects played.
@export var audio_player : Node = null
@export_group("Effects")
@export_subgroup("Scene Switch")
@export var switch_scenes : bool = false
@export var target_scene : String = ""
@export_subgroup("Book")
@export var is_book : bool = false
@export var collects_book : bool = false
var book_material : Material
var book_index : int = -1
@export_subgroup("Morning Routine")
@export var is_routine : bool = false
@export var routine_task : String = ""
@export_subgroup("Dialogue")
@export var is_dialogue : bool = false
@export var dialogue : Dialogue

signal triggered
signal switch_scene
func trigger_effects() -> void:
	if switch_scenes:
		switch_scene.emit(target_scene)
	if is_routine and not Status.complete_routine(routine_task, audio_player):
		return
	if collects_book and not Status.collect_book(book_index):
		return
	# pickup_book returns false when it fails
	if is_book and not Status.pickup_book(book_index, book_material):
		return
	triggered.emit()
