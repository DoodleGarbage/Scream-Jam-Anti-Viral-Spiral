extends Node3D

## The increase added to the total flicker chance when a part is collected
#@export var flicker_increase : float = 0.1 - this is in Status.flicker_chance_increase
@export var audio_player : AudioPlayer3D
@export var room_light : OmniLight3D

signal item_collected(pos:Vector3)

func part_collected() -> void:
	Audio.stop("tunneling_through")
	Audio.play("power_down")#, audio_player)
	#Audio.play("tunnels_of_dread", null, true, 8)
	item_collected.emit(global_position)
	room_light.flicker_disabled = true
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.visible = false
		light.flicker_chance = 0.95
	print("we are awaiting")
	get_tree().create_timer(2.0).timeout.connect(_timer_finished)
	hide()
	return

func _timer_finished() -> void:
	print("what da heck")
	room_light.visible = true
	room_light.flicker_disabled = false
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.flicker_chance = Status.base_flicker_chance + Status.flicker_chance_increase*(Status.collected_pieces.size()+Status.held_pieces.size())
	queue_free()
