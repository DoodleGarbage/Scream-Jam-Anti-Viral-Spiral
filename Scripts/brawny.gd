extends Node3D

@export var follow_player : bool = false
@export var move_with_player : bool = false
@export var walk_path : Path3D
@export var collider : StaticBody3D
@export var bridge_incident : Node3D
@export var bridge_collider : StaticBody3D

var player : Node3D

func _ready() -> void:
	match(Status.current_day_string):
		"day1": day_1()
		"day2": day_2()
		"day3": day_3()
		"night1": disable()
		"night2": disable()
		"night3": disable()

func _process(_delta: float) -> void:
	if not player:
		return
	if follow_player:
		var look_point : Vector3 = player.position
		look_point.y = position.y
		look_at(look_point)
	if move_with_player:
		global_position = walk_path.curve.get_closest_point(player.global_position)

func day_1() -> void:
	follow_player = true
	collider.process_mode = Node.PROCESS_MODE_DISABLED
	#move_with_player = true
	return
func day_2() -> void:
	follow_player = true
	move_with_player = true
	return
func day_3() -> void:
	follow_player = true
	global_position = bridge_incident.global_position
	rotation = bridge_incident.position
	bridge_collider.process_mode = Node.PROCESS_MODE_INHERIT
	return

func disable() -> void:
	global_position = Vector3(0,0,0)
	hide()
	collider.process_mode = Node.PROCESS_MODE_DISABLED


func _on_brawny_interact_triggered() -> void:
	match(Status.current_day_string):
		"day2":
			collider.process_mode = Node.PROCESS_MODE_DISABLED
			move_with_player = false
