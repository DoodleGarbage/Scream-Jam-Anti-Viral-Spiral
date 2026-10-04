extends Node

var in_dialogue : bool = false

const ROUTINE_TASKS : Array[String] = ["food","washup","dress"]
var completed_tasks : Array[String] = []

var game_node : Node

var holding_book : bool = false
var held_book_index : int = -1

var woke_up : bool = false
var waking_up : bool = false

func pickup_book(index:int, material:Material) -> bool:
	if holding_book:
		return false
	holding_book = true
	held_book_index = index
	game_node.player_character.BOOK.book_material = material
	game_node.player_character.BOOK.show()
	Audio.play("book_grabbed")
	return true

func collect_book(book_index:int) -> bool:
	if not (holding_book == true and held_book_index == book_index):
		return false
	holding_book = false
	held_book_index = -1
	game_node.player_character.BOOK.hide()
	Audio.play("book_delivered")
	return true

func complete_routine(task:String, audio_player=null) -> bool:
	if not ROUTINE_TASKS.has(task) or completed_tasks.has(task):
		return false
	completed_tasks.append(task)
	Audio.play(task, audio_player)
	if task == "washup":
		Dialogue.trigger_event("washup")
	return true

func movement_allowed() -> bool:
	return not (not Status.woke_up or Status.in_dialogue)
