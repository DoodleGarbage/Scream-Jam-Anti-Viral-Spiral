extends Node

var active_scene : String = "3D"

@export var root3D : Node3D
@export var root2D : Node2D

func switch_scene(scene:String) -> void:
	match(active_scene):
		"3D":
			root3D.disable_scene()
			root3D.process_mode = Node.PROCESS_MODE_DISABLED
			#root3D.disable_gameplay()
		"2D":
			root2D.disable_scene()
			root2D.process_mode = Node.PROCESS_MODE_DISABLED
			#root2D.disable_gameplay()
	match(scene):
		"3D":
			root3D.activate_scene()
			root3D.process_mode = Node.PROCESS_MODE_INHERIT
		"2D":
			root2D.activate_scene()
			root2D.process_mode = Node.PROCESS_MODE_INHERIT
