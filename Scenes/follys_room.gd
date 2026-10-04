extends Node3D

@export var character : Node3D
@export_group("Wakeup Sequence")
@export var blackout_screen : ColorRect
@export var wakeup_notice : Control
@export var alarm_sound : AudioStreamPlayer3D
@export var alarm_clunk : AudioStreamPlayer3D

@export_group("Spawn Points")
@export var loading_point : Node3D
@export var wakeup_point : Node3D





func _ready() -> void:
	pass

func loaded() -> void:
	if not Status.woke_up:
		character.global_position = wakeup_point.global_position
	else:
		character.global_position = loading_point.global_position

func _process(delta: float) -> void:
	if Status.waking_up:
		wakeup_notice.hide()
		blackout_screen.color.a -= delta / 5
		if blackout_screen.color.a <= 0.05:
			blackout_screen.hide()
			Status.waking_up = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and not Status.woke_up:
		alarm_clunk.play()
		alarm_sound.stop()
		Status.woke_up = true
		Status.waking_up = true
