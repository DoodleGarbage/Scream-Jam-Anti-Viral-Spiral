extends Node3D

@export var loading_point : Node3D
var character : Node3D

func _ready() -> void:
	pass

func loaded() -> void:
	character.global_position = loading_point.global_position
