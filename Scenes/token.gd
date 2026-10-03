extends Node2D

class_name Token

@onready var health_bar = $HealthBar








## Movement
@export var movement_speed : float = 4.5
var movement_target : Vector2 = Vector2(0,0)
## Movement (Combat)
var distance_traveled : float = 0
var max_distance : float = 1000

func _physics_process(_delta: float) -> void:
	var up_down = Input.get_axis("forward", "backward")
	var left_right = Input.get_axis("left", "right")
	position = position + Vector2(left_right, up_down).normalized() * movement_speed





## NPC
var is_npc : bool = false
#var dialogue : DialogueResource
#var shop : Shop
