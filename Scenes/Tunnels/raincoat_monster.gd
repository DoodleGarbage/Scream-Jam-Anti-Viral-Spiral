extends CharacterBody3D

var player : Node3D :
	get:
		return Status.game_node.character

@export var audio_player : AudioPlayer3D
@export var navigation_agent : NavigationAgent3D
## How fast (in m/s) Raincoat moves
@export var speed : float = 8.0
## How long Raincoat stands there before chasing the player
@export var piece_disable_time : float = 3.5

var movement_disabled : float = 0.0
var chasing_player : bool = false
var chase_triggered : bool = true

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func set_collision_mode(mode:bool) -> void:
	if not mode:
		collision_mask = 0
	else:
		collision_mask = 1


func disable() -> void:
	set_collision_mode(false)
	global_position = Vector3(0, -100, 0)

func enable() -> void:
	set_collision_mode(true)
	velocity = Vector3.ZERO


func get_movement_target() -> Vector3:
	## Target Selection code
	if chasing_player:
		return player.global_position
	return global_position


func set_movement_target(target:Vector3) -> void:
	navigation_agent.set_target_position(target)
	return

func item_collected(pos:Vector3) -> void:
	enable()
	global_position = pos + Vector3(0, 9, 0)
	movement_disabled = piece_disable_time
	chasing_player = true
	chase_triggered = false
	if Status.total_pieces == 1:
		Audio.stop_themes(true, 30)
		#Audio.play("tunnels_of_dread", null, true, 16)


func generator_fixed() -> void:
	#Audio.stop_themes()
	#if Status.total_pieces > 0:
		#Audio.play("tunnels_of_dread", null, true, 8)
	#else:
		#Audio.play("tunneling_through", null, true, 8)
	disable()


func _ready() -> void:
	Status.generator_piece_collected.connect(generator_fixed)
	
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	actor_setup.call_deferred()


func actor_setup():
	await get_tree().physics_frame
	set_movement_target(get_movement_target())


func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	rotation.x = 0
	rotation.z = 0
	
	movement_disabled -= _delta
	#set_collision_mode(true)
	
	if navigation_agent.is_navigation_finished():
		set_movement_target(get_movement_target())
		return
	
	if not movement_disabled > 0.0:
		if not chase_triggered:
			Audio.play("chase_trigger", audio_player)
			chase_triggered = true
		set_movement_target(get_movement_target())
		
		var current_agent_position : Vector3 = global_position
		var next_path_position : Vector3 = navigation_agent.get_next_path_position()
		var dir : Vector3 = (current_agent_position.direction_to(next_path_position) * Vector3(1,0,1) ).normalized()
		velocity = dir * speed
	if not is_on_floor():
		#print("adding gravity")
		velocity.y -= gravity * _delta
	move_and_slide()
