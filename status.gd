extends Node

var loading : bool = false

## increase to 'day2', 'day3', etc.
var current_day : int = 1
var current_day_string : String :
	get:
		if current_day > 3:
			return "hell"
		if work_complete:
			return "night" + str(current_day)
		return "day" + str(current_day)

var in_dialogue : bool = false

const ROUTINE_TASKS : Array[String] = ["food","washup","dress"]
var completed_tasks : int = -1

var game_node : Node

var holding_book : bool = false
var held_book_index : int = -1

var holding_rock : bool = false

var woke_up : bool = false
var waking_up : bool = false


var returned_books : int = -1
var total_books : int = 0
var work_complete : bool :
	get:
		return returned_books >= total_books






func pickup_book(index:int, material:Material, title:String="") -> bool:
	if holding_book:
		return false
	holding_book = true
	held_book_index = index
	game_node.player_character.BOOK.book_material = material
	game_node.player_character.BOOK.book_title = title
	game_node.player_character.BOOK.show()
	Audio.play("book_grabbed")
	return true

func collect_book(book_index:int) -> bool:
	if not (holding_book == true and held_book_index == book_index):
		return false
	holding_book = false
	held_book_index = -1
	game_node.player_character.BOOK.hide()
	returned_books += 1
	Audio.play("book_delivered")
	return true

func pickup_rock() -> void:
	holding_rock = true
	game_node.player_character.ROCK.show()

const rock_throw_force : float = 10.0
func throw_rock() -> void:
	clear_rock()
	var thrown_rock : RigidBody3D = preload("res://Scenes/rock_projectile.tscn").instantiate()
	game_node.add_child(thrown_rock)
	#thrown_rock.global_transform = game_node.player_character.HEAD.global_transform
	thrown_rock.global_position = game_node.player_character.global_position + game_node.player_character.HEAD.position
	#print("Firing in direction: ", game_node.player_character.HEAD.quaternion * Vector3(0,0,-1))
	var basis = -game_node.player_character.HEAD.global_transform.basis.z.normalized()
	print(basis)
	#var direction = basis * Vector3.FORWARD
	thrown_rock.apply_central_impulse(basis * rock_throw_force)

func clear_rock()-> void:
	holding_rock = false
	game_node.player_character.ROCK.hide()


func complete_routine(task:String, audio_player=null) -> bool:
	var task_num : int = int(task)
	if completed_tasks != task_num-1:
		return false
	completed_tasks += 1
	#completed_tasks.append(task)
	Audio.play(task.right(-1), audio_player)
	return true

func movement_allowed() -> bool:
	return not (not Status.woke_up or Status.in_dialogue)

func end_day() -> void:
	print("Ending day ", current_day)
	clear_rock()
	total_books = 0
	returned_books = -1
	completed_tasks = -1
	current_day += 1
	woke_up = false
	waking_up = false

func position_character(spawn_point:Node3D, character:CharacterBody3D) -> void:
	#print("Position character called to go to: ", spawn_point.global_position)
	character.velocity = Vector3(0,0,0)
	character.global_position = spawn_point.global_position
	character.HEAD.quaternion = spawn_point.quaternion

func restart_day() -> void:
	clear_rock()
	total_books = 0
	returned_books = -1
	completed_tasks = -1
	woke_up = false
	waking_up = false
	game_node.switch_scene("follys_room")
