extends Scene

@export var spawn_point : Node3D

@export var hermit_door : Node3D
@export var hermit_door_interactable : Interactable3D
@export var front_door_interactable : Interactable3D
@export var front_door_knocker : AudioPlayer3D
@export var raincoat_node : Node3D
@export var raincoat_exit : Node3D
@export var raincoat_enter : Node3D

var trigger_raincoat_cutscene : bool = false

func loaded(_last_scene:String) -> void:
	Status.end_day()
	Status.woke_up = true
	Status.completed_tasks_names = Status.ROUTINE_TASKS
	Status.completed_tasks = 3
	Audio.play("someplace_calm", null, true)
	Status.completed_childhood = true
	Status.position_character(spawn_point, character)
	
	if _last_scene == "car_scene" or Status.in_recovery:
		$UpperFloor/Hermit.queue_free()
		$UpperFloor/Furniture/ExitDoor/GoToHome.monitorable = false
		$LowerFloor/FrontDoor/AnswerDoor.monitorable = true
		Audio.play("knock_loop", front_door_knocker, true, 1)
		Status.in_recovery = true


func _on_answer_door_triggered() -> void:
	if trigger_raincoat_cutscene:
		return
	Audio.stop("knock_loop")
	trigger_raincoat_cutscene = true
	progress = 0.0

	await Dialogue.dialogue_finished
	
	#trigger_raincoat_cutscene = false
	invert_raincoat = true
	progress = 1.0
	#progress = 0.0
	front_door_interactable.is_dialogue = false
	front_door_interactable.desc = "Head to Work"
	## Prevent leave the scene triggering happening when you close the dialogue.
	await get_tree().create_timer(1.0).timeout
	front_door_interactable.switch_scenes = true

var invert_raincoat : bool = false
var progress : float = 1.0

func _process(delta: float) -> void:
	
	if door_rise:
		hermit_door.position.y = min(4.153, hermit_door.position.y + 2 * delta)
	
	raincoat_node.look_at(character.global_position)
	raincoat_node.rotation.x = 0
	raincoat_node.rotation.z = 0
	if trigger_raincoat_cutscene:
		progress = min(progress+delta, 1.0) if not invert_raincoat else max(progress-delta, 0.0)
		raincoat_node.position = lerp(raincoat_exit.position, raincoat_enter.position, progress)
	#else:
		#progress = min(progress+delta, 1.0)
		#raincoat_node.position = lerp(raincoat_enter.position, raincoat_exit.position, progress)

var door_rise : bool = false
func _on_talk_triggered() -> void:
	hermit_door.show()
	door_rise = true
	hermit_door_interactable.monitorable = true
