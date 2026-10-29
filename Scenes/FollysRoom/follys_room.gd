extends Scene

#@export var character : Node3D

@export_group("Recovery")
@export var flower : Node3D
@export var flower_interactable : Interactable3D

@export_group("Childhood Sequence")
@export var childhood_door : Node3D
@export var broken_window : Node3D
@export var replaced_window : Node3D
@export var break_the_cycle : Interactable3D
@export var front_door : Interactable3D

@export_group("Wakeup Sequence")
#@export var blackout_screen : ColorRect
#@export var wakeup_notice : Control
@export var wakeup_node : Node
@export var alarm_player : AudioStreamPlayer3D
#@export var alarm_sound : AudioStreamPlayer3D
#@export var alarm_clunk : AudioStreamPlayer3D
@export var alarmface_morning : MeshInstance3D
@export var alarmface_afternoon : MeshInstance3D

@export_group("Spawn Points")
@export var loading_point : Node3D
@export var wakeup_point : Node3D
@export var childhood_point : Node3D


func loaded(_last_scene:String) -> void:
	var spawn_pos : Node3D = loading_point
	var waking : bool = false
	if Status.completed_childhood and not Status.in_recovery:
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
	if Status.in_recovery:
		flower.show()
		flower_interactable.monitorable = true
		$Furniture/bed/Sleep.monitorable = false
		spawn_pos = loading_point
	if not waking:
		Audio.play("someplace_calm", null, true)
		wakeup_node.close_wakeup()
	if Status.work_complete:
		$door/FrontDoor.monitorable = false
		alarmface_afternoon.show()
		alarmface_morning.hide()
	else:
		alarmface_morning.show()
		alarmface_afternoon.hide()
	Status.position_character(spawn_pos, character)
