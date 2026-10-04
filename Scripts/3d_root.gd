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

signal scene_switch(scene:String)
func trigger_scene_switch(scene:String) -> void:
	scene_switch.emit(scene)
