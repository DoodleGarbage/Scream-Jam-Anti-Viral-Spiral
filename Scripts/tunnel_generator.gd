extends Node3D

@export var audio_player : AudioPlayer3D
## The number of generator pieces that need to be collected
@export var needed_pieces : int = 2

func _ready() -> void:
	Audio.play("broken_generator", audio_player)


func _on_generator_interact_triggered() -> void:
	if not $GeneratorInteract.collects_generator_pieces:
		return
	Audio.play("gear_clunk", audio_player)
	Audio.stop("broken_generator")
	Audio.stop("tunneling_through", true, 15.0)
	if Status.collected_pieces.size() >= needed_pieces:
		$GeneratorInteract.collects_generator_pieces = false
		$GeneratorInteract.desc = "It's running."
		await get_tree().create_timer(1.5).timeout
		Audio.play("power_on", audio_player)
		Audio.play("tunneling_through", null, true, 2.0)
		return
	
	Audio.play("power_down")
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.visible = false
		light.flicker_chance = 0.75
	
	$GeneratorInteract.desc = "It's missing " + str(needed_pieces-Status.collected_pieces.size()) + " parts."
	
	await get_tree().create_timer(1.5).timeout
	Audio.play("broken_generator", audio_player)
	Audio.play("tunneling_through", null, true, 6.0)
	
	## This stacks with the above timer
	await get_tree().create_timer(3.0).timeout
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.flicker_chance = 0.3


func part_collected() -> void:
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.visible = false
		light.flicker_chance = 0.80
	await get_tree().create_timer(1.5).timeout
	for light in get_tree().get_nodes_in_group("TunnelLight"):
		light.flicker_chance = 0.3
	return
