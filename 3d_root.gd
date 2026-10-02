extends Node3D

@export var character : Node3D

func activate_scene() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT
	character.CANVAS.show()
	character.CAMERA.process_mode = Node.PROCESS_MODE_INHERIT

func disable_scene() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	process_mode = Node.PROCESS_MODE_DISABLED
	character.CANVAS.hide()
	character.CAMERA.process_mode = Node.PROCESS_MODE_DISABLED
