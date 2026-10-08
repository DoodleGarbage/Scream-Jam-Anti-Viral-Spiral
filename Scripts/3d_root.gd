extends Node3D


@export var library_exit : Node3D
@export var folly_exit : Node3D
@export var hermit_exit : Node3D

@export var character : Node3D
@export var SkyCycle : Node3D

#func activate_scene() -> void:
	#show()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#process_mode = Node.PROCESS_MODE_INHERIT
	#character.CANVAS.show()
	#character.CAMERA.process_mode = Node.PROCESS_MODE_INHERIT

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
	print("Loading finishing")
	match(Status.current_day_string):
		"day3": 
			Audio.play("being_followed", null, true)
			$RockPile/GrabRock.desc = "Grab Rock"
			$RockPile/GrabRock.is_rock = true
		"hell","hellnight":
			Audio.play("hell", null, true)
			$RockPile/GrabRock.desc = "I really shouldn't."
			#$RockPile/GrabRock.is_rock = false
			$Houses/HermitHouse/hermit_house.hide()
			$Houses/HermitHouse/hermit_house_open.show()
		_:Audio.play("prudent_folly", null, true)
	var spawn_pos : Node3D
	#print("matching scene: ", last_scene)
	match(last_scene):
		"follys_room": spawn_pos = folly_exit
		"library_room": spawn_pos = library_exit
		"hermits_house": spawn_pos = hermit_exit
		_: spawn_pos = folly_exit
	$NPCs/Raincoat.player = character
	$NPCs/Brawny.player = character
	if $Houses/HermitHouse/EnterHermit.get_restrictions():
		print("killing hermit")
		$Houses/HermitHouse/EnterHermit.queue_free()
	load_environment(Status.current_day_string)
	Status.position_character(spawn_pos, character)

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
