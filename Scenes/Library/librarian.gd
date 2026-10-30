extends CharacterBody3D

@export var dialogue_source : DialogueResource

@export var lib_exit : Node3D
@export var navigation_agent : NavigationAgent3D
@export var speed : float = 4.0

const gravity = 1.805

var movement_disabled : bool = false
var wander_timer : float = 1.0
var dialogue_timer : float = 9.0

func _ready() -> void:
	if Status.current_day_string == "hell":
		queue_free()

func get_movement_target() -> Vector3:
	return Vector3(randf_range(-10,10), 0, randf_range(-10,10))


func set_movement_target(target:Vector3) -> void:
	navigation_agent.set_target_position(target)
	return

var last_dialogue : bool = false

func _physics_process(_delta: float) -> void:
	
	if Status.in_dialogue: ## Pause when in dialogue
		look_at(get_parent().character.global_position)
		rotation.x = 0
		rotation.z = 0
		velocity = Vector3(0,0,0)
		return
	
	if Status.work_complete:
		if not last_dialogue:
			Dialogue.trigger_event("", dialogue_source, Status.current_day_string)
			global_position = lib_exit.global_position
			get_parent().character.HEAD.look_at(global_position + Vector3(0,1.5,0))
			if Status.current_day_string == "night3":
				collision_layer = 0
				collision_mask = 0
			last_dialogue = true
		look_at(get_parent().character.global_position)
		rotation.x = 0
		rotation.z = 0
		if Status.current_day_string != "night3":
			velocity = Vector3(0,0,0)
		else:
			velocity.y -= gravity * _delta
			move_and_slide()
		return
	
	dialogue_timer -= _delta
	wander_timer -= _delta
	
	if dialogue_timer < 0.0:
		var rand_cue = "a" + str(randi_range(1,9)) # <- this magic number is from the dialogue resource, it picks from to a1-a9 to say
		if Status.in_recovery:
			rand_cue = "b" + str(randi_range(1,4))
		Dialogue.trigger_event("", dialogue_source, rand_cue)
		get_parent().character.HEAD.look_at(global_position + Vector3(0,1.5,0))
		dialogue_timer = randf_range(10, 16) if not Status.in_recovery else randf_range(16, 24)
	
	if not movement_disabled:
		if wander_timer < 0.0:
			set_movement_target(get_movement_target())
			wander_timer = randf_range(4, 8)
		
		if not navigation_agent.is_target_reached() and not navigation_agent.get_final_position().distance_to(global_position) < 0.5:
			var current_agent_position : Vector3 = global_position
			var next_path_position : Vector3 = navigation_agent.get_next_path_position()
			var dir : Vector3 = (current_agent_position.direction_to(next_path_position) * Vector3(1,0,1) ).normalized()
			if dir != Vector3.ZERO:
				look_at(position+dir)
				rotation.x = 0
				rotation.z = 0
			velocity = dir * speed
		else:
			look_at(get_parent().character.global_position)
			rotation.x = 0
			rotation.z = 0
			velocity = Vector3(0,0,0)
	if not is_on_floor():
		#print("adding gravity")
		velocity.y -= gravity * _delta
	move_and_slide()
