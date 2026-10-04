@tool
extends Node3D

var book_color : Material


var bookshelf_index : int = 0 :
	set(value):
		bookshelf_index = value
		$Interactable3D.book_index = value

#@export var book_color : Color = Color("red")

@export var shelf_width : float = 10.0
@export var book_width : float = 0.08

@export var book_chance : float = 0.9
@export var min_book_scale : float = 0.25

@export var shelves : Array[Node3D] = []
@export var book_model : PackedScene

@export var book_genre : String = "" :
	set(value):
		book_genre = value
		var node = get_node_or_null("Label3D")
		if node == null:
			return
		node.text = value
@export var book_titles : Array[String] = [""]

func _load_shelves() -> void:
	var rand_color : Color = Color(randf(), randf(), randf())
	var book_material : Material = StandardMaterial3D.new()
	book_material.albedo_color = rand_color
	book_color = book_material
	
	for shelf in shelves:
		var width : float = 0.0
		while width < shelf_width - book_width:
			var skip := randf()
			if skip > book_chance:
				width += book_width
				continue
			var new_book = book_model.instantiate()
			add_child(new_book)
			var rand_size : float = randf_range(min_book_scale, 1.0)
			new_book.scale = Vector3(rand_size, rand_size, rand_size)
			var pos := shelf.position - Vector3(0,0,width + 0.5*(book_width*rand_size))
			new_book.position = pos
			new_book.book_material = book_material
			width += book_width * rand_size
	
