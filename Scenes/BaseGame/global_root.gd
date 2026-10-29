extends Node


@export var current_scene : String = ""
@export var character : Node
@export var active_scene : Node
@export var dialogue_display : CanvasLayer
@export var loading_screen : CanvasLayer


func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Status.game_node = self
	for node in get_tree().get_nodes_in_group("Interactables"):
		if node.switch_scenes:
			node.switch_scene.connect(switch_scene)
	if active_scene is Scene:
		active_scene.character = character
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
	var scene_folder : String = ""
	match(scene):
		"follys_room": scene_folder = "FollysRoom/"
		"library", "library_room": scene_folder = "Library/"
		"3d_game", "town": scene_folder = "Town/"
		"tunnels": scene_folder = "Tunnels/"
		"hermits_house": scene_folder = "HermitsHouse/"
		"childhood_home": scene_folder = "ChildhoodHome/"
		"car_scene": scene_folder = "CarScene/"
		"dorm": scene_folder = "Dorm/"
	var exists = ResourceLoader.exists("res://Scenes/" + scene_folder + scene + ".tscn")
	if not exists:
		push_error("Tried to load non-existent scene: ", scene)
		return
	Status.clear_rock()
	dialogue_display.end_dialogue(true)
	#print("Character position before everything: ", character.position)
	Status.loading = true
	active_scene.queue_free()
	currently_loading_scene = "res://Scenes/" + scene_folder + scene + ".tscn"
	ResourceLoader.load_threaded_request(currently_loading_scene, "", true)
	next_scene_name = scene
	loading_screen.show()
	active_scene.hide()
	Audio.stop_themes()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _execute_scene_switch(loaded_scene:Node) -> void:
	#print("Character position post scene load: ", character.position)\
	Audio.stop_all()
	active_scene = loaded_scene
	
	character.base_speed = Status.character_base_speed
	character.sprint_speed = Status.character_sprint_speed
	
	if loaded_scene is Scene:
		loaded_scene.character = character
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
	character.hide_generator_pieces()
	Status.held_pieces = []
	character.velocity = Vector3(0,0,0)
	Status.save_game()

#func re_enable_character() -> void:
	#character.process_mode = Node.PROCESS_MODE_INHERIT
	#character.set_physics_process(true)
