extends Node3D

@export var character : Node3D
@export var loading_point : Node3D

#@export var bookshelves : Array[Node3D] = []
var bookshelf_colors : Array[Material] = []

func loaded(_last_scene:String) -> void:
	character.global_position = loading_point.position
	var bookshelves = get_tree().get_nodes_in_group("bookshelves")
	for shelf in bookshelves.size():
		bookshelves[shelf].bookshelf_index = shelf
		bookshelves[shelf]._load_shelves()
		bookshelf_colors.append(bookshelves[shelf].book_color)
	var tables = get_tree().get_nodes_in_group("tables")
	for table in tables:
		table.book_colors = bookshelf_colors
		table._load_books()
	#load_bookshelves.emit()
