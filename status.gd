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
