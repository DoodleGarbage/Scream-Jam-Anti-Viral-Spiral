extends Scene

#@export var character : Node3D

@export_group("Childhood Sequence")
@export var childhood_door : Node3D
@export var broken_window : Node3D
@export var replaced_window : Node3D
@export var break_the_cycle : Interactable3D
@export var front_door : Interactable3D

@export_group("Wakeup Sequence")
@export var blackout_screen : ColorRect
@export var wakeup_notice : Control
@export var alarm_player : AudioStreamPlayer3D
#@export var alarm_sound : AudioStreamPlayer3D
#@export var alarm_clunk : AudioStreamPlayer3D

@export_group("Spawn Points")
@export var loading_point : Node3D
@export var wakeup_point : Node3D
@export var childhood_point : Node3D


func loaded(_last_scene:String) -> void:
	var spawn_pos : Node3D = loading_point
	var waking : bool = false
	if Status.completed_childhood:
		spawn_pos = childhood_point
		childhood_door.show()
		broken_window.show()
		replaced_window.hide()
		break_the_cycle.monitorable = true
		front_door.desc = "Continue the Cycle"
	elif not Status.woke_up and not Status.work_complete:
		waking = true
		Audio.play("alarm_sound", alarm_player)
		spawn_pos = wakeup_point
	if not waking:
		Audio.play("someplace_calm", null, true)
		blackout_screen.hide()
		wakeup_notice.hide()
	if Status.work_complete:
		$door/Interactable3D.monitorable = false
	Status.position_character(spawn_pos, character)

func _process(delta: float) -> void:
	if Status.waking_up:
		wakeup_notice.hide()
		blackout_screen.color.a -= delta / 5
		if blackout_screen.color.a <= 0.05:
			blackout_screen.hide()
			Status.waking_up = false

func _input(_event: InputEvent) -> void:
	if not Status.woke_up and Input.is_action_just_pressed("wakeup"):
		Audio.play("alarm_clunk")
		Audio.stop("alarm_sound")
		Audio.play("someplace_calm", null, true)
		Status.woke_up = true
		Status.waking_up = true
