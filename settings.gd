extends Node

var volume : float = -15.0
var mouse_sensitivity : float = 0.35


func _ready() -> void:
	if settings_exists():
		load_settings()


func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_db(0, Settings.volume)
	Status.game_node.character.mouse_sensitivity = mouse_sensitivity


func settings_exists() -> bool:
	if FileAccess.file_exists("user://settings.ini"):
		var dat = FileAccess.open("user://save.dat", FileAccess.READ)
		var json := JSON.new()
		var err := json.parse(dat.get_as_text())
		
		if err != Error.OK:
			return false
		
		dat = json.data
		
		if typeof(dat) != TYPE_ARRAY:
			return false
		
	else:
		return false
	
	return true


func save_settings() -> void:
	var file := FileAccess.open("user://settings.ini", FileAccess.WRITE)
	var save_dat := JSON.stringify([volume, mouse_sensitivity])
	file.store_string(save_dat)
	file.flush()
	return


func load_settings() -> void:
	var file := FileAccess.open("user://settings.ini", FileAccess.READ)
	var dat : String = file.get_as_text()
	var json := JSON.new()
	var err := json.parse(dat)
	
	if err == Error.OK:
		var data = json.data
		if typeof(data) != TYPE_ARRAY:
			push_error("Tried to load saved settings, but it wasn't in an array!")
			return
		
		var arr : Array = data as Array
		volume = arr[0]
		mouse_sensitivity = arr[1]
	return
