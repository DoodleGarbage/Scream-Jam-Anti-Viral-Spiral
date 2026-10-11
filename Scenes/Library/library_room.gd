extends Node3D

var total_books : int = 0


@export var character : Node3D
@export var loading_point : Node3D

#@export var bookshelves : Array[Node3D] = []
var bookshelf_colors : Array[Material] = []
var bookshelf_titles : Array = []

func loaded(_last_scene:String) -> void:
	match(Status.current_day_string):
		"day1":
			Audio.play("first_day", null, true)
		"day2":
			Audio.play("second_day", null, true)
		_:
			Audio.play("library", null, true)
	Status.position_character(loading_point, character)
	var bookshelves = get_tree().get_nodes_in_group("bookshelves")
	for shelf in bookshelves.size():
		bookshelves[shelf].bookshelf_index = shelf
		bookshelves[shelf]._load_shelves()
		bookshelf_colors.append(bookshelves[shelf].book_color)
		bookshelf_titles.append(bookshelves[shelf].book_titles)
	var tables = get_tree().get_nodes_in_group("tables")
	for table in tables:
		table.book_colors = bookshelf_colors
		table.book_titles = bookshelf_titles
		total_books += table._load_books()
	Status.returned_books = 0
	Status.total_books = total_books
