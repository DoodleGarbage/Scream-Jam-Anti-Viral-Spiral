@tool
extends Node3D

var book_title : String :
	set(value):
		book_title = value
		var node = get_node_or_null("book_title")
		if node == null:
			return
		node.text = value
		var int3 = get_node_or_null("Interactable3D")
		if int3 == null:
			return
		int3.book_title = value
		int3.desc = "Pick up \"" + book_title + "\""

var book_index : int :
	set(value):
		var node = get_node_or_null("Interactable3D")
		if node == null:
			return
		node.book_index = value

@export var book_material : Material :
	set(value):
		var interact = get_node_or_null("Interactable3D")
		if interact != null:
			interact.book_material = value
		var node = get_node_or_null("book_cover")
		if node == null:
			return null
		node.set_surface_override_material(0, value)
	get:
		var node = get_node_or_null("book_cover")
		if node == null:
			return null
		return node.get_surface_override_material(0)
