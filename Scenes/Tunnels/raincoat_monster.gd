extends CharacterBody3D

var player : Node3D :
	get:
		return Status.game_node.character

@export var audio_player : AudioPlayer3D
@export var audio_player_2 : AudioPlayer3D
@export var navigation_agent : NavigationAgent3D
## How fast (in m/s) Raincoat moves
@export var speed : float = 8.0
## How long Raincoat stands there before chasing the player
@export var piece_disable_time : float = 3.5
## The maximum distance raincoat can get before re-spawning near the player
@export var max_wander_distance : float = 30
## The furthest a wander point can be before it isn't considered for moving
@export var max_wander_target_distance : float = 15
## The spawn node must be within the must much distance to be in range for raincoat to spawn there.
@export var wander_spawn_distance : float = 15
## How long raincoat keeps chasing during the wander phase after losing sight
@export var max_chase_time : float = 5.0
## How far raincoat can see
@export var max_sight_distance : float = 10.0

var navigation_nodes : Array[Node3D] :
	get:
		if navigation_nodes.size() <= 0:
			navigation_nodes.assign(get_tree().get_nodes_in_group("NavPoint")) # Caching!
		return navigation_nodes

var wander_timer : float = 0.0

var movement_disabled : float = 0.0
var start_wander : float = 0.0
var chasing_player : bool = false
var chase_triggered : bool = true
var wander_mode : bool = false
var ignore_max_chase_time : bool = false

var player_last_seen : float = 0

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func set_collision_mode(mode:bool) -> void:
	if not mode:
		collision_mask = 0
	else:
		collision_mask = 1


func disable() -> void:
	Audio.stop("whatdidyoudo")
	Audio.stop("chase_trigger")
	Audio.stop("chase_loop")
	set_collision_mode(false)
	global_position = Vector3(0, -100, 0)
	chasing_player = false
	chase_triggered = false


func enable() -> void:
	set_collision_mode(true)
	velocity = Vector3.ZERO


func get_movement_target() -> Vector3:
	## Target Selection code
	if chasing_player:
		return player.global_position
	if wander_mode:
		var valid_points : Array[Node3D]
		for point in navigation_nodes:
			if point.global_position.distance_to(player.global_position) < max_wander_target_distance:
				valid_points.append(point)
		if valid_points.size() <= 0:
			return global_position
		return valid_points[randi_range(0,valid_points.size()-1)].global_position
	return global_position


func set_movement_target(target:Vector3) -> void:
	navigation_agent.set_target_position(target)
	return

func spawn_at_wander_point() -> void:
	#print_stack()
	var valid_points : Array[Node3D]
	for point in navigation_nodes:
		if point.global_position.distance_to(player.global_position) < wander_spawn_distance:
			valid_points.append(point)
	if valid_points.size() <= 0:
		return
	global_position = valid_points[randi_range(0,valid_points.size()-1)].global_position + Vector3(0, 9, 0)
	movement_disabled = piece_disable_time
	return

func item_collected(pos:Vector3) -> void:
	enable()
	global_position = pos + Vector3(0, 9, 0)
	movement_disabled = piece_disable_time
	chasing_player = true
	chase_triggered = false
	ignore_max_chase_time = true
	if Status.total_pieces >= 1:
		Audio.stop_themes(true, 30)
		#Audio.play("tunnels_of_dread", null, true, 16)


func generator_fixed() -> void:
	#Audio.stop_themes()
	#if Status.total_pieces > 0:
		#Audio.play("tunnels_of_dread", null, true, 8)
	#else:
		#Audio.play("tunneling_through", null, true, 8)
	ignore_max_chase_time = false
	if Status.collected_pieces.size() > 0:
		wander_mode = true
		movement_disabled = 10.0
		start_wander = 10.0
	disable()
	


func _ready() -> void:
	Status.generator_piece_collected.connect(generator_fixed)
	
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	if Status.collected_pieces.size() > 0:
		wander_mode = true
		start_wander = 25.0
	
	actor_setup.call_deferred()


func actor_setup():
	await get_tree().physics_frame
	set_movement_target(get_movement_target())


func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	rotation.x = 0
	rotation.z = 0
	
	movement_disabled -= _delta
	start_wander -= _delta
	wander_timer -= _delta
	#set_collision_mode(true)
	
	if not chasing_player and wander_mode and start_wander <= 0 and collision_mask == 0:
		enable()
		spawn_at_wander_point()
		wander_timer = randf_range(4.0, 6.0)
		chasing_player = false
	
	#if navigation_agent.is_navigation_finished():
		#set_movement_target(get_movement_target())
		#return
	
	if not movement_disabled > 0.0:
		if not chase_triggered and chasing_player:
			Audio.play("whatdidyoudo", audio_player_2)
			Audio.play("chase_trigger", audio_player)
			Audio.stop("wail")
			chase_triggered = true
		
		player_last_seen += _delta
		
		## Wander Mode:
		## Look for Player
		## Pick point to wander to (in range)
		## If out of max range, re-spawn
		if (wander_mode and not chasing_player):
			if global_position.distance_to(player.global_position) > max_wander_distance:
				Audio.play("wail", audio_player_2)
				spawn_at_wander_point()
		
		## RAY CASTING
		var space_state = get_world_3d().direct_space_state
		var source := Vector3(global_position.x, 1, global_position.z)
		var target := player.global_position + Vector3(0,1,0)
		var ray_distance : Vector3 = source.move_toward(target, max_sight_distance)
		var query = PhysicsRayQueryParameters3D.create(source, ray_distance, 1, [self.get_rid()])
		var result : Dictionary = space_state.intersect_ray(query)
		if result != {} and result["collider"] == player:
			chasing_player = true
			if not chase_triggered:
				chase_triggered = true
				Audio.play("whatdidyoudo", audio_player_2)
				Audio.stop("wail")
				Audio.play("chase_trigger", audio_player)
			player_last_seen = 0
		if chasing_player and  player_last_seen > max_chase_time and not ignore_max_chase_time:
			chasing_player = false
			chase_triggered = false
			Audio.stop("whatdidyoudo")
			Audio.stop("chase_trigger")
			Audio.stop("chase_loop")
			Audio.play("wail", audio_player_2)
			spawn_at_wander_point()
		
		if (wander_mode and wander_timer < 0.0) or chasing_player:
			set_movement_target(get_movement_target())
			wander_timer = randf_range(7, 16)
		
		
		
		if not navigation_agent.is_target_reached():
			var current_agent_position : Vector3 = global_position
			var next_path_position : Vector3 = navigation_agent.get_next_path_position()
			var dir : Vector3 = (current_agent_position.direction_to(next_path_position) * Vector3(1,0,1) ).normalized()
			velocity = dir * speed
	if not is_on_floor():
		#print("adding gravity")
		velocity.y -= gravity * _delta
	move_and_slide()


func _on_catcher_body_entered(body: Node3D) -> void:
	if not body == player:
		return
	Audio.stop_all()
	Status.game_node.switch_scene("tunnels")

## called by signal when the agent reaches its target
func _target_reached() -> void:
	return
	#wander_timer = randf_range(1, 5)
