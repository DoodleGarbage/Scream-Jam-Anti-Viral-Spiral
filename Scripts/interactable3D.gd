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
@export_flags("Require Work Completed") var enabled_restrictions : int = 0b0
@export var require_day : Array[String] = []
#@export_subgroup("Routine Task")
@export var required_complete_tasks : int = -1
#@export_subgroup("Work Task")
#@export var require_completing_work : bool = false
@export_group("Effects")
@export_subgroup("Teleport")
@export var is_teleport : bool = false
@export var teleport_point : Node3D
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
	var _enabled_restrictions : int = 0b0000
	var restrictions : int = 0b00000
	if require_day.size():
		_enabled_restrictions += 0b01000
	if not require_day.has(Status.current_day_string):
		restrictions += 0b1000
	if required_complete_tasks > -1:
		_enabled_restrictions += 0b0100
	if not Status.completed_tasks_names.size() >= required_complete_tasks:
		restrictions += 0b00100
	if is_routine:
		_enabled_restrictions += 0b00010
	if Status.completed_tasks_names.has(routine_task):
		restrictions += 0b00010
	if collects_book:
		_enabled_restrictions += 0b10000
	if (Status.holding_book == false or Status.held_book_index != book_index):
		restrictions += 0b10000
	#if require_completing_work:
		#enabled_restrictions += 0b0001
	if not Status.work_complete:
		restrictions += 0b00001
	_enabled_restrictions += enabled_restrictions
	
	if invert_restrictions:
		restrictions = restrictions ^ 0b11111 # xor operator - false if 0 = 0, 1 = 1, true for 0 = 1 or 1 = 0
	var total_restrictions : int = _enabled_restrictions & restrictions # If a restriction is enabled, and the restriction is also active, then it will evaluate to 1, and if total_restrictions != 0 (anything is enabled and restricted) will return restricted
	#print("enableds ", _enabled_restrictions)
	#print("restri ", restrictions)
	#print("tot rest ", total_restrictions)
	return bool(total_restrictions)
	
	#var routine : bool = (required_complete_tasks > -1 and not Status.completed_tasks_names.size() >= required_complete_tasks) or (is_routine and Status.completed_tasks_names.has(routine_task)) or (require_day > -1 and require_day != Status.current_day)
	##print("reoutine: ", routine)
	#var work : bool = ((require_completing_work and not Status.work_complete) and not invert_work) or (not (require_completing_work and not Status.work_complete) and invert_work)
	##print("Work: ", work)
	#var restriction : bool = routine or work or not monitorable
	##print("Restriction: ", rWWWEestriction)
	#return (invert_restrictions and !restriction) or (not invert_restrictions and restriction)

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
	if is_teleport:
		Status.position_character(teleport_point, Status.game_node.character)
	if is_rock:
		Status.pickup_rock()
	if is_dialogue and dialogue != null and Status.allow_dialogue:
		Dialogue.trigger_event(event_name, dialogue)
	if is_dialogue and not Status.allow_dialogue:
		return
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
