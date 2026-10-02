extends Node2D

## Inheritence, next heir has genetics from previous character
## Inherit an heirloom from your previous adventurer, and continue onward
## Some Rogue Lineage roblox game typa stuff
## Maybe get bloodlines with s and special powers/bonuses involved
## And no gating stuff behind Robux

class_name Token

## Initialization

## Overrides the team inherited from the Source Character profile.
@export var team_override : int = -1
## Holds all the stats, data, and other bits to initialize a token.

@onready var health_bar = $HealthBar








## Movement
const movement_speed : float = 4.5
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
