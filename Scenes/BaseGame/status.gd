extends Node

const character_base_speed : float = 3.0
const character_sprint_speed : float = 8.0

signal generator_piece_collected()


var loading : bool = false

## increase to 'day2', 'day3', etc.
var current_day : int = 1
var current_day_string : String :
	get:
		if in_recovery:
			if work_complete:
				return "recoverynight"
			return "recovery"
		if game_node.current_scene == "car_scene":
			return "crash"
		if game_node.current_scene == "tunnels":
			return "tunnels"
		if game_node.current_scene == "childhood_home" or game_node.current_scene == "follys_room" and completed_childhood:
			return "childhood"
		if current_day > 3 or completed_childhood:
			if work_complete:
				return "hellnight"
			return "hell"
		if work_complete:
			return "night" + str(current_day)
		return "day" + str(current_day)

var in_dialogue : bool = false
var allow_dialogue : bool = true

const ROUTINE_TASKS : Array[String] = ["food","washup","dress"]
var completed_tasks_names : Array[String] = []
var completed_tasks : int = -1

var game_node : Node

var holding_book : bool = false
var held_book_index : int = -1
var generated_books : Array[String] = []


var holding_rock : bool = false

var woke_up : bool = true
var waking_up : bool = false


var returned_books : int = -1
var total_books : int = 0
var work_complete : bool :
	get:
		return returned_books >= total_books

var collected_pieces : Array[int] = []
var held_pieces : Array[int] = []
var total_pieces : int :
	get:
		return collected_pieces.size() + held_pieces.size()

## The amount that the light flickering is increased in the Tunnels after collecting a part.
var flicker_chance_increase : float = 0.1
var base_flicker_chance : float = 0.2

var completed_childhood : bool = false

var in_recovery : bool = false

func pickup_book(index:int, material:Material, title:String="") -> bool:
	if holding_book:
		return false
	holding_book = true
	held_book_index = index
	game_node.character.BOOK.book_material = material
	game_node.character.BOOK.book_title = title
	game_node.character.BOOK.show()
	Audio.play("book_grabbed")
	return true

func collect_book(book_index:int) -> bool:
	if holding_book == false or held_book_index != book_index:
		return false
	holding_book = false
	held_book_index = -1
	game_node.character.BOOK.hide()
	returned_books += 1
	Audio.play("book_delivered")
	return true


func pickup_generator_piece(gen_piece:int) -> bool:
	if collected_pieces.has(gen_piece) or held_pieces.has(gen_piece):
		return false
	print("executing")
	game_node.character.GEN_PIECES[gen_piece-1].show()
	held_pieces.append(gen_piece)
	return true


func collect_generator_piece() -> void:
	for piece in held_pieces:
		game_node.character.GEN_PIECES[piece-1].hide()
	collected_pieces.append_array(held_pieces)
	held_pieces = []
	generator_piece_collected.emit()
	return


func pickup_rock() -> void:
	holding_rock = true
	game_node.character.ROCK.show()

const rock_throw_force : float = 10.0
func throw_rock() -> void:
	if not holding_rock or in_dialogue:
		return
	clear_rock()
	var thrown_rock : RigidBody3D = preload("res://Scenes/Town/rock_projectile.tscn").instantiate()
	game_node.add_child(thrown_rock)
	#thrown_rock.global_transform = game_node.character.HEAD.global_transform
	thrown_rock.global_position = game_node.character.global_position + game_node.character.HEAD.position
	#print("Firing in direction: ", game_node.character.HEAD.quaternion * Vector3(0,0,-1))
	var basis = -game_node.character.HEAD.global_transform.basis.z.normalized()
	print(basis)
	#var direction = basis * Vector3.FORWARD
	thrown_rock.apply_central_impulse(basis * rock_throw_force)

func clear_rock()-> void:
	holding_rock = false
	game_node.character.ROCK.hide()


func complete_routine(task:String, audio_player=null) -> bool:
	if completed_tasks_names.has(task):
		return false
	#var task_num : int = int(task)
	#if completed_tasks != task_num-1:
		#return false
	completed_tasks += 1
	completed_tasks_names.append(task)
	Audio.play(task, audio_player)
	return true

func movement_allowed() -> bool:
	return Status.woke_up and not Status.in_dialogue

func end_day() -> void:
	print("Ending day ", current_day)
	clear_rock()
	total_books = 0
	returned_books = -1
	generated_books = []
	completed_tasks = -1
	current_day += 1
	woke_up = false
	waking_up = false
	completed_tasks_names = []

func position_character(spawn_point:Node3D, character:CharacterBody3D) -> void:
	#print("Position character called to go to: ", spawn_point.global_position)
	character.velocity = Vector3(0,0,0)
	character.global_position = spawn_point.global_position
	character.HEAD.quaternion = spawn_point.quaternion

func restart_day(scene:String="follys_room") -> void:
	Audio.stop_all()
	clear_rock()
	total_books = 0
	returned_books = -1
	completed_tasks = -1
	completed_tasks_names = []
	woke_up = false
	waking_up = false
	game_node.switch_scene(scene)


func save_exists() -> bool:
	if FileAccess.file_exists("user://save.dat"):
		var dat = FileAccess.open("user://save.dat", FileAccess.READ)
		var json := JSON.new()
		var err := json.parse(dat.get_as_text())
		if err != Error.OK:
			#print("failed here3")
			return false
		dat = json.data
		if typeof(dat) != TYPE_ARRAY:
			#print("failed here2")
			return false
		var arr : Array = json.data as Array
		if typeof(arr[1]) != TYPE_STRING or arr[1] == "":
			#print("failed here")
			return false 
	else:
		return false
	return true

func save_game() -> void:
	var file := FileAccess.open("user://save.dat", FileAccess.WRITE)
	#var json := JSON.new()
	
	print("we saved and overwrote")
	
	if game_node.current_scene == "main_menu":
		return
	
	
	var save_dat := JSON.stringify([current_day, game_node.current_scene, in_recovery, work_complete, collected_pieces, completed_childhood])
	print(file.store_string(save_dat))
	file.flush()
	return

func load_game() -> void:
	var file := FileAccess.open("user://save.dat", FileAccess.READ)
	var dat : String = file.get_as_text()
	var json := JSON.new()
	var err := json.parse(dat)
	if err == Error.OK:
		var data = json.data
		if typeof(data) != TYPE_ARRAY:
			push_error("Tried to load save data, but it wasn't in an array!")
			return
		var arr : Array = data as Array
		current_day = arr[0]
		in_recovery = arr[2]
		if arr[3]:
			returned_books = 1
		collected_pieces.assign(arr[4])
		completed_childhood = arr[5]
		
		game_node.switch_scene(arr[1])
	return

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
