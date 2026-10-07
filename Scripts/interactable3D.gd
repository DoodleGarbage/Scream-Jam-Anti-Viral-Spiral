extends Area3D

class_name Interactable3D

## The text displayed on screen when hovered.
@export var desc : String = ""
## Used for any sound effects played.
@export_group("Audio")
@export var audio_player : Node = null
@export var play_audio : bool = false
@export var fade_in : bool = false
@export var audio_track : String = ""
@export var stopped_audio_tracks : Array[String] = []
@export_group("Restrictions")
@export var invert_restrictions : bool = false
@export_subgroup("Routine Task")
@export var required_complete_tasks : int = -1
@export_subgroup("Work Task")
@export var invert_work : bool = false
@export var require_completing_work : bool = false
@export_group("Effects")
@export_subgroup("Scene Switch")
@export var switch_scenes : bool = false
@export var target_scene : String = ""
@export_subgroup("Object")
@export var is_book : bool = false
@export var collects_book : bool = false
@export var is_rock : bool = false
var book_material : Material
var book_title
var book_index : int = -1
@export_subgroup("Morning Routine")
@export var is_routine : bool = false
@export var routine_task : String = ""
@export_subgroup("Dialogue")
@export var is_dialogue : bool = false
@export var event_name : String = ""
@export var dialogue : DialogueResource
@export_subgroup("Day")
@export var end_day : bool = false

func get_restrictions() -> bool:
	var routine : bool = (required_complete_tasks > -1 and not Status.completed_tasks+1 == required_complete_tasks)
	#print("reoutine: ", routine)
	var work : bool = ((require_completing_work and not Status.work_complete) and not invert_work) or (not (require_completing_work and not Status.work_complete) and invert_work)
	#print("Work: ", work)
	var restriction : bool = routine or work or not monitorable
	#print("Restriction: ", rWWWEestriction)
	return (invert_restrictions and !restriction) or (not invert_restrictions and restriction)

signal triggered
signal switch_scene
func trigger_effects() -> void:
	if get_restrictions():
		return
	if is_routine and not Status.complete_routine(routine_task, audio_player):
		return
	if collects_book and not Status.collect_book(book_index):
		return
	# pickup_book returns false when it fails
	if is_book and not Status.pickup_book(book_index, book_material, book_title):
		return
	if is_rock:
		Status.pickup_rock()
	if is_dialogue and dialogue != null:
		Dialogue.trigger_event(event_name, dialogue)
	if end_day:
		monitorable = false # prevent double triggers
		Status.end_day()
	if switch_scenes:
		monitorable = false # prevent double triggers
		switch_scene.emit(target_scene)
	if play_audio and audio_track != "":
		print("playing audio")
		Audio.play(audio_track, audio_player, fade_in)
	for audio in stopped_audio_tracks:
		Audio.stop(audio)
	triggered.emit()
