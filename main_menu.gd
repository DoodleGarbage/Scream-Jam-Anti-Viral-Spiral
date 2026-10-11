extends Node

## The scene that is loaded when you select 'new game'
@export var start_scene : String = "follys_room"

## Nodes
@export_group("Node References")
## Sets the volume. Slider should be set with a min value of -72, max value of 6.0, step of 0.1, and allow greater & lesser
@export var volume_slider : Slider
## The label that displays the current volume setting.
@export var volume_display : Label
## Reference to the button that loads the save
@export var continue_button : Control
## Reference to the button that loads the credits room.
@export var credits_button : Control
@export_subgroup("Debug Nodes")
## Reference to the line edit that holds the user-entered text to load a different scene.
@export var debug_scene : LineEdit

var character # Prevents accessing a non-existant variable when global root switches this scene in - is not used by this node.

func _ready() -> void:
	## TODO: Implement saving and logging progress
	credits_button.hide()
	continue_button.hide()

func loaded(_last_scene:String) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Audio.play("main_menu")
	return

func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_db(0, volume_slider.value)
	volume_display.text = "%0.1fdb" % volume_slider.value
	#Audio

signal switch_scene(scene:String)
func _on_start_pressed() -> void:
	var target_scene : String = start_scene
	if debug_scene.text != "":
		target_scene = debug_scene.text
	if debug_scene.value > -1:
		Status.current_day = debug_scene.value
	if target_scene == "follys_room":
		Status.woke_up = false
	switch_scene.emit(target_scene)
