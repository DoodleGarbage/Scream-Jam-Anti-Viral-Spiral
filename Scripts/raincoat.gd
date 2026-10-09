extends Node3D

@export var player : Node3D
@export var bounding_box : VisibleOnScreenNotifier3D
@export var static_positions : Array[VisibleOnScreenNotifier3D] = []
@export var stalk_positions : Array[Path3D] = []
@export var bridge_mesh : Node3D
@export var broken_bridge : Node3D
@export var bridge_blocker : StaticBody3D
@export var audio_player : AudioPlayer3D
@export var bridge_audio : AudioPlayer3D
## In meters
@export var stalk_distance : float = 0.0
## Speed to exit a stalk position
@export var stalk_out : float = 0.5
## Speed to enter into a stalk position
@export var stalk_in : float = 1.2
@export var speed_mod : float = 10.0
@export var stalk_path : Path3D
@export var rainy_movementspeed : float = 3.0

var behavior : int = 0
var follow_player : bool = false
var follow_static_position : bool = false
var stalk_player : bool = false
var chase_player : bool = false
var falling : bool = false
const gravity = 9.81
var velocity_y : float = 0.0

## Stalking behavior
var current_stalk_position : int = -1
var waiting_for_walk_out : bool = false
## in meters
var current_offset : float = 0.0

func _process(_delta: float) -> void:
	if not player:
		return
	if follow_player:
		var look_point : Vector3 = player.position
		look_point.y = position.y
		look_at(look_point)
	if follow_static_position and static_positions.size() > 0:
		#if bounding_box and bounding_box.is_on_screen():
			#return
		#print("folling static pos")
		
		#var lowest_node : VisibleOnScreenNotifier3D = static_positions[0]
		#print("static pos: ", static_positions)
		var seen_nodes : Array[VisibleOnScreenNotifier3D] = static_positions.filter(func(node): return node.is_on_screen())
		if not seen_nodes.size() > 0:
			return
		#var lowest_distance : float = player.global_position.distance_to(seen_nodes[0].global_position)
		var lowest_node : VisibleOnScreenNotifier3D = seen_nodes[0]
		#print("seen nodes: ", seen_nodes)
		for node in seen_nodes:
			#print("check node: ", node.name)
			#if node == lowest_node: # Don't move to nodes we can see
				##print("continuing for node: ", node.name)
				#continue
			#print("no cont")
			var dist = player.global_position.distance_to(node.global_position)
			#print("dist: ", dist, " lowest: ", lowest_node.global_position)
			if dist < lowest_node.global_position.distance_to(player.global_position):
				#lowest_distance = dist
				lowest_node = node
		#print("smallest_node: ", lowest_node.name)
		global_position = lowest_node.global_position
	if stalk_player:
		if not stalk_path:
			return
		show()
		if current_stalk_position > -1:
			var dist_to_player : float =  stalk_positions[current_stalk_position].curve.sample_baked(0.0).distance_to(player.global_position)
			#if waiting_for_walk_out:
				#print("true")
			if dist_to_player < stalk_distance or waiting_for_walk_out:
				current_offset = min(current_offset + stalk_out*_delta, stalk_positions[current_stalk_position].curve.get_baked_length())
				#print("offsets ", current_offset, " ", stalk_positions[current_stalk_position].curve.get_baked_length(). stalk_out)
				global_position = stalk_positions[current_stalk_position].curve.sample_baked(current_offset)
				if current_offset >= stalk_positions[current_stalk_position].curve.get_baked_length():
					hide()
					waiting_for_walk_out = false
					current_stalk_position = -1
				#print("return 2")
				return
			current_offset = max(current_offset - stalk_in*_delta, 0.0)
			global_position = stalk_positions[current_stalk_position].curve.sample_baked(current_offset)
			#print("return 1")
			#return
		
		
		var closest : int = -1
		var closest_dist : float = 99999999999.9
		for path in stalk_positions.size():
			var dist_to_player : float = stalk_positions[path].curve.sample_baked(0.0).distance_to(player.global_position)
			if dist_to_player < stalk_distance:
				continue
			if dist_to_player < closest_dist:
				closest = path
				closest_dist = dist_to_player
		if current_stalk_position != closest:
			#print("running")
			waiting_for_walk_out = true if current_stalk_position > -1 else false
			if current_offset >= stalk_positions[current_stalk_position].curve.get_baked_length() or not waiting_for_walk_out:
				current_offset = stalk_positions[closest].curve.get_baked_length()
				current_stalk_position = closest
				waiting_for_walk_out = false
		#if current_stalk_position < 0:
			#global_position = Vector3(0,0,0)
			#hide()
			#return
		## below is the code to follow one long continuous path at a certain distance from the player
		#global_position = stalk_positions[current_stalk_position].curve.sample_baked(0.0)
		#current_offset = 0.0
		
		#var dist_to_player : float = stalk_path.curve.get_closest_point(player.global_position).distance_to(player.global_position)
		#var closest_offset : float = stalk_path.curve.get_closest_offset(player.global_position) - max((stalk_distance)-dist_to_player, 0)
		#if closest_offset <= 0.01 and stalk_path.curve.sample_baked(closest_offset, true).distance_to(player.global_position) < stalk_distance:
			#hide()
		#global_position = stalk_path.curve.sample_baked(closest_offset, true)
		#set_axis_velocity(global_position.direction_to(points[closest_idx_player-1]) * speed_mod)
		
		#global_position = lerp()
	if chase_player:
		global_position = global_position.move_toward(player.global_position, _delta*rainy_movementspeed)
	if falling:
		velocity_y += gravity*_delta
		global_position.y -= velocity_y*_delta
		bridge_mesh.global_position.y -= velocity_y*_delta

func _ready() -> void:
	match(Status.current_day_string):
		"day1": day_1()
		"day2": day_2()
		"day3": day_3()
		"night1": disable()
		"night2": disable()
		"night3": disable()

func disable() -> void:
	hide()
	global_position = Vector3(0,0,0)

func day_1() -> void:
	follow_player = true

func day_2() -> void:
	print("day 2 executed")
	follow_player = true
	follow_static_position = true
	if static_positions.size() > 0:
		global_position = static_positions[0].global_position

func day_3() -> void:
	follow_player = true
	stalk_player = true


func _on_brawny_brawny_murdered() -> void:
	if Status.current_day_string != "day3":
		return
	chase_player = true
	stalk_player = false
	Audio.play("whatdidyoudo", audio_player)
	Audio.play("chase_trigger", null, true, 80)
	Audio.stop("being_followed")


func _on_chase_detector_body_entered(_body: Node3D) -> void:
	if not chase_player:
		return
	print("Caught you!")
	Status.restart_day()


func _on_raincoat_catcher_body_entered(_body: Node3D) -> void:
	#print(body.name)
	if not chase_player:
		return
	print("I've been caught!")
	chase_player = false
	falling = true
	broken_bridge.show()
	bridge_blocker.process_mode = Node.PROCESS_MODE_INHERIT
	Audio.stop("chase_trigger", true, 7)
	Audio.stop("chase_loop", true, 7)
	Audio.play("bridge_collapse", bridge_audio)


#func _on_bridge_collapse_timeout() -> void:
	#bridge_mesh.show()
