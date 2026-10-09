extends Node3D

@export var character : Node3D

@export_group("Wakeup Sequence")
@export var blackout_screen : ColorRect
@export var wakeup_notice : Control
@export var alarm_player : AudioStreamPlayer3D
#@export var alarm_sound : AudioStreamPlayer3D
#@export var alarm_clunk : AudioStreamPlayer3D

@export_group("Spawn Points")
@export var loading_point : Node3D
@export var wakeup_point : Node3D


func loaded(_last_scene:String) -> void:
	var spawn_pos : Node3D
	if not Status.woke_up and not Status.work_complete:
		Audio.play("alarm_sound", alarm_player)
		spawn_pos = wakeup_point
	else:
		Audio.play("someplace_calm", null, true)
		spawn_pos = loading_point
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
