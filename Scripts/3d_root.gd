extends Node3D


@export var library_exit : Node3D
@export var folly_exit : Node3D

@export var character : Node3D
@export var SkyCycle : Node3D

func activate_scene() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT
	character.CANVAS.show()
	character.CAMERA.process_mode = Node.PROCESS_MODE_INHERIT

#func disable_scene() -> void:
	#hide()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#process_mode = Node.PROCESS_MODE_DISABLED
	#character.CANVAS.hide()
	#character.CAMERA.process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	if SkyCycle != null:
		SkyCycle.get_node("AnimationPlayer").advance(550)

func loaded(last_scene:String) -> void:
	var spawn_pos : Vector3
	#print("matching scene: ", last_scene)
	match(last_scene):
		"follys_room": spawn_pos = folly_exit.global_position
		"library_room": spawn_pos = library_exit.global_position
		_: spawn_pos = folly_exit.global_position
	character.global_position = spawn_pos
	$NPCs/Raincoat.player = character
	if Status.work_complete:
		load_environment("night" + str(Status.current_day+1))
	else:
		load_environment(Status.current_day_string)

func load_environment(enviro:String) -> void:
	var new_enviro : Node3D
	match(enviro):
		"day3":
			$FogPools.show()
			new_enviro = preload("res://Scenes/3DSky/day3.tscn").instantiate()
		"day2":
			$FogPools.show()
			new_enviro = preload("res://Scenes/3DSky/day2.tscn").instantiate()
		"night3":
			$FogPools.show()
			new_enviro = preload("res://Scenes/3DSky/night3.tscn").instantiate()
		"night2":
			$FogPools.show()
			new_enviro = preload("res://Scenes/3DSky/night2.tscn").instantiate()
		"night1":
			new_enviro = preload("res://Scenes/3DSky/night.tscn").instantiate()
		_:
			new_enviro = preload("res://Scenes/3DSky/day.tscn").instantiate()
	add_child(new_enviro)


signal scene_switch(scene:String)
func trigger_scene_switch(scene:String) -> void:
	scene_switch.emit(scene)
