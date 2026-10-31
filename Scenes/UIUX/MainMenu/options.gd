extends CanvasLayer

@export var volume_slider : Slider
@export var volume_display : Label
@export var sensitivity_display : Label
@export var sensitivity_slider : Slider


func _on_options_close_pressed() -> void:
	close()
	
	if get_parent().current_scene != "main_menu":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_sens_drag_ended(_value_changed: bool) -> void:
	pass


func _process(_delta: float) -> void:
	volume_display.text = "%0.1fdb" % volume_slider.value
	sensitivity_display.text = "%0.2f" % sensitivity_slider.value


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close()


func open() -> void:
	show()
	volume_slider.value = Settings.volume
	sensitivity_slider.value = Settings.mouse_sensitivity


func close() -> void:
	hide()
	Settings.volume = volume_slider.value
	Settings.mouse_sensitivity = sensitivity_slider.value
	Settings.save_settings()
