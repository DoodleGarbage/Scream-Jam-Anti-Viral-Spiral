extends Node


@export var current_scene : String = ""
@export var player_character : Node
@export var active_scene : Node
@export var dialogue_display : CanvasLayer


func _ready() -> void:
	Status.game_node = self
	for node in get_tree().get_nodes_in_group("Interactables"):
		if node.switch_scenes:
			node.switch_scene.connect(switch_scene)
	active_scene.character = player_character
	active_scene.loaded("")

func switch_scene(scene:String) -> void:
	print("recieved scene: ", scene)
	var load_scene = load("res://Scenes/" + scene + ".tscn")
	if load_scene == null:
		push_error("Tried to load non-existent scene: ", scene)
		return
	active_scene.queue_free()
	var new_scene = load_scene.instantiate()
	active_scene = new_scene
	new_scene.character = player_character
	player_character.velocity = Vector3(0,0,0)
	#player_character.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(new_scene)
	for node in get_tree().get_nodes_in_group("Interactables"):
		node.switch_scene.connect(switch_scene)
	#player_character.process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(0.1).timeout
	active_scene.loaded(current_scene)
	current_scene = scene
