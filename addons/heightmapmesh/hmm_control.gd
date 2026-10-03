@tool
extends VBoxContainer


var height_src : EditorResourcePicker
var height_map :
	set(value):
		if value is EditorResourcePicker:
			height_src = value
	get:
		if height_src != null:
			return height_src.get_edited_resource()
		return null

signal pressed(_heightmap:Image, _meshsize:int, _outputname:String)

func clicked() -> void:
	var sz : int = int(get_node("Mesh").text)
	pressed.emit(height_map, sz, $LineEdit.text)
