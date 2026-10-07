extends Node


@export var current_scene : String = ""
@export var player_character : Node
@export var active_scene : Node
@export var dialogue_display : CanvasLayer
@export var loading_screen : CanvasLayer


func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Status.game_node = self
	for node in get_tree().get_nodes_in_group("Interactables"):
		if node.switch_scenes:
			node.switch_scene.connect(switch_scene)
	active_scene.character = player_character
	active_scene.loaded("")

var next_scene : PackedScene
var currently_loading_scene : String = ""
var next_scene_name : String = ""

func _process(_delta: float) -> void:
	var arr : Array = []
	var status : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(currently_loading_scene, arr)
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED or status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
		return
	#print("Loading status: ", status, " ", arr[0])
	if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		return
	var packed_scene = ResourceLoader.load_threaded_get(currently_loading_scene)
	_execute_scene_switch(packed_scene.instantiate())

func switch_scene(scene:String) -> void:
	print("recieved scene: ", scene)
	var exists = ResourceLoader.exists("res://Scenes/" + scene + ".tscn")
	if not exists:
		push_error("Tried to load non-existent scene: ", scene)
		return
	Status.clear_rock()
	dialogue_display.end_dialogue()
	#print("Character position before everything: ", player_character.position)
	Status.loading = true
	active_scene.queue_free()
	currently_loading_scene = "res://Scenes/" + scene + ".tscn"
	ResourceLoader.load_threaded_request(currently_loading_scene, "", true)
	next_scene_name = scene
	loading_screen.show()
	active_scene.hide()
	Audio.stop_themes()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _execute_scene_switch(loaded_scene:Node) -> void:
	#print("Character position post scene load: ", player_character.position)
	active_scene = loaded_scene
	loaded_scene.character = player_character
	loaded_scene.ready.connect(loaded_scene.loaded.bind(current_scene))
	#loaded_scene.ready.connect(re_enable_character)
	add_child(loaded_scene)
	#loaded_scene.loaded(current_scene)
	for node in get_tree().get_nodes_in_group("Interactables"):
		node.switch_scene.connect(switch_scene)
	#await get_tree().create_timer(0.1).timeout
	loading_screen.hide()
	current_scene = next_scene_name
	next_scene_name = ""
	next_scene = null
	Status.loading = false
	#print("Character position on final load: ", player_character.position)
	await get_tree().create_timer(1.0).timeout
	#print("Character position 1.0 seconds later: ", player_character.position)

#func re_enable_character() -> void:
	#player_character.process_mode = Node.PROCESS_MODE_INHERIT
	#player_character.set_physics_process(true)
