extends CanvasLayer

@export var volume_slider : Slider
@export var volume_display : Label
@export var sensitivity_display : Label
@export var sensitivity_slider : Slider

func _on_options_close_pressed() -> void:
	hide()
	if get_parent().current_scene != "main_menu":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_sens_drag_ended(_value_changed: bool) -> void:
	pass


#func _on_volume_drag_ended(value_changed: bool) -> void:
	#pass # Replace with function body.

func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_db(0, volume_slider.value)
	get_parent().character.mouse_sensitivity = sensitivity_slider.value
	volume_display.text = "%0.1fdb" % volume_slider.value
	sensitivity_display.text = "%0.2f" % sensitivity_slider.value
	#Audio

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hide()
