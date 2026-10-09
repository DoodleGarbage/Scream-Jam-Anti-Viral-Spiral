extends Node

## Enable this when testing scenes.
@export var disabled : bool = false

@export var start_scene : String = "follys_room"

var character # Prevents accessing a non-existant variable when global root switches this scene in
func loaded(_last_scene:String) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Audio.play("main_menu")
	return

func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_db(0, $CL/LS/Vol/Volume.value)
	$CL/LS/Vol/VolPerc.text = "%0.1fdb" % $CL/LS/Vol/Volume.value
	#Audio

signal switch_scene(scene:String)
func _on_start_pressed() -> void:
	var target_scene : String = start_scene
	if $CL/Debug/LineEdit.text != "":
		target_scene = $CL/Debug/LineEdit.text
	if $CL/Debug/SpinBox.value > -1:
		Status.current_day = $CL/Debug/SpinBox.value
	if target_scene == "follys_room":
		Status.woke_up = false
	switch_scene.emit(target_scene)
