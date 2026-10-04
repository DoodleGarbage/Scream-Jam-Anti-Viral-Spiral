extends Node3D

@export var book_scene : PackedScene
var book_colors : Array[Material] = []
var book_titles : Array = []

func _load_books() -> int:
	rotation.y = randf_range(0, 2*PI) # randomize the table rotations to move the chairs
	var amnt_rand : int = randi_range(1, 9)
	var amnt : int = 0
	match(amnt_rand):
		1,2,3,4: amnt = 1
		5,6,7: amnt = 2
		8,9: amnt = 3
	for i in range(0, amnt):
		var pos = rand_point()
		var new_book : Node3D = book_scene.instantiate()
		add_child(new_book)
		new_book.rotation.y = randf_range(0, 2*PI)
		new_book.position = pos
		
		var index : int = randi_range(0, book_colors.size()-1)
		new_book.book_material = book_colors[index]
		new_book.book_title = get_title(index)
		new_book.book_index = index
	return amnt

func rand_point() -> Vector3:
	var rand_x : float = randf_range(-1.343*0.5, 1.343*0.5)
	var rand_z : float = randf_range(-1.363*0.5, 1.363*0.5)
	return Vector3(rand_x, 0.49, rand_z)


func get_title(idx:int) -> String:
	var index = randi_range(1+3*(Status.current_day),3+3*(Status.current_day))
	return book_titles[idx][index]
