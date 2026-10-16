extends Scene

@export var spawn_point : Node3D
@export var post_crash_point : Node3D
@export var car : Node3D
@export var car_2 : Node3D
@export var car_crash : Node3D
@export var tunnel_door : Node3D
@export var chase_monster : Node3D
@export var chase_path : Path3D
@export var blackout : ColorRect
@export var car_horn_audio_player : AudioPlayer3D
@export var car_crash_audio_player : AudioPlayer3D
@export var car_speed : float = 60
## When to trigger the horn (in seconds), based on the car speed and distance from player
@export var horn_time : float = 4.5
## Same as horn time
@export var crash_time : float = 1.8
#@export var crash
## How long the blackout screen stays solid before fading
@export var minimum_blackout : float = 2.0
## How much the blackout fades away each second - remember: 1.0 = full opacity, 0.0 = clear
@export var blackout_fade_rate : float = 0.2
## How much % of the fog density is increased each second after the fog is triggered
@export var fog_appear_rate : float = 0.4
## The base chase speed in m/s of the chase monster
@export var chase_speed : float = 8.0


var car_active : bool = true
var horn_triggered : bool = false
var crash_triggered : bool = false
var crash_finished : bool = false
var blackout_timer : float = 0.0
var fog_active : bool = false
var in_chase_mode : bool = false

var chase_progress : float = 0.0


func loaded(_last_scene:String) -> void:
	character.in_air_momentum = true
	$WorldEnvironment.environment.fog_enabled = false
	Status.position_character(spawn_point, character)


func _on_player_fall() -> void:
	print("player has fallen")
	character.base_speed = Status.character_base_speed * 0.25
	character.sprint_speed = Status.character_sprint_speed * 0.25
	character.jumping_enabled = false
	#car_active = true

func _process(_delta: float) -> void:
	if in_chase_mode:
		$Eyes.global_position = character.global_position
		chase_monster.look_at(character.global_position)
		if fog_active:
			chase_progress += chase_speed * _delta
			chase_monster.global_position = chase_path.curve.sample_baked(chase_progress)
		else:
			chase_monster.global_position = chase_monster.global_position.move_toward(character.global_position, chase_speed * _delta)
		
		
		
		
		
	#if fog_active and $WorldEnvironment.environment.fog_density < 1.0:
		#$WorldEnvironment.environment.fog_density += fog_appear_rate * _delta
	if crash_finished:
		blackout_timer += _delta
		if not blackout_timer > minimum_blackout:
			return
		character.base_speed = Status.character_base_speed
		character.sprint_speed = Status.character_sprint_speed
		blackout.color.a -= blackout_fade_rate * _delta
		if blackout.color.a <= 0.05:
			Status.woke_up = true
			blackout.hide()
			crash_triggered = false
	if car_active:
		if not horn_triggered and (car.global_position.distance_to(car_2.global_position) / (car_speed*2)) <= horn_time:
			horn_triggered = true
			Audio.play("car_horn", car_horn_audio_player)
		if not crash_triggered and (car.global_position.distance_to(car_2.global_position) / (car_speed*2)) <= crash_time:
			crash_triggered = true
			Audio.stop("car_horn", true, 1.0)
			Audio.play("car_crash", car_crash_audio_player)
			await get_tree().create_timer(0.8).timeout
			print("Crash triggered set to false	`")
			crash_finished = true
			car_active = false
			car.hide()
			car_2.hide()
			Status.woke_up = false
			blackout.show()
			car_crash.process_mode = Node.PROCESS_MODE_INHERIT
			car_crash.show()
			character.in_air_momentum = false
			character.jumping_enabled = true
			Status.position_character(post_crash_point, character)
		car.position.z -= car_speed * _delta
		car_2.position.z += car_speed * _delta


#func _on_ground_detector_body_entered() -> void:
	#car_active = true
	#total_dist = car.global_position.distance_to(character.global_position)


func _on_fog_trigger_body_entered(body: Node3D) -> void:
	if not body == character:
		return
	$Eyes.show()
	fog_active = true
	#$WorldEnvironment.environment.fog_enabled = true
	#$WorldEnvironment.environment.fog_density = 0.0
	$Sun.hide()

func _on_chase_triggered() -> void:
	await Dialogue.dialogue_finished
	print("Activating chase_mode")
	Audio.play("chase_loop", null, true, 10)
	chase_monster.show()
	in_chase_mode = true
	tunnel_door.hide()
	tunnel_door.process_mode = Node.PROCESS_MODE_DISABLED


func _on_catcher_body_entered(body: Node3D) -> void:
	if not in_chase_mode or body != character:
		return
	print("Caught you!")
	Status.restart_day("car_scene")
	Status.woke_up = true
