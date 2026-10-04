extends Node2D

@export var player : Node2D

#func _ready() -> void:
#	disable_scene()

func activate_scene() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	player.set_physics_process(true)

#func disable_scene() -> void:
	#hide()
	#process_mode = Node.PROCESS_MODE_DISABLED
	#player.set_physics_process(false)
