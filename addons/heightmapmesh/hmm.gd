@tool
extends EditorPlugin

var dock
func _enter_tree() -> void:
	dock = preload("res://addons/heightmapmesh/hmm_control.tscn").instantiate()
	var heightmap_picker = EditorResourcePicker.new()
	heightmap_picker.base_type = "Image"
	dock.add_child(heightmap_picker)
	dock.move_child(heightmap_picker, 1)
	dock.height_src = heightmap_picker
	dock.pressed.connect(trigger_process)
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()

func trigger_process(height_map:Image, mesh_size:int, resource_name:String) -> void:
	if height_map == null or resource_name == "":
		print("Select a heightmap or name the resource first!")
		return
	var new_mesh := generate_mesh(mesh_size, height_map)
	print("Done! Saving mesh...")
	new_mesh.resource_name = resource_name
	var err = ResourceSaver.save(new_mesh, "res://" + resource_name + ".tres")
	if err != 0:
		push_error("Error saving mesh; Error Code: ", err)
		return
	get_editor_interface().get_resource_filesystem().scan()
	print("Mesh saved! Enjoy!")
	return

func generate_mesh(mesh_size:int, height_map:Image) -> ArrayMesh:
	var rect = height_map.get_used_rect()
	var division : int = floor(rect.size.x / mesh_size)
	var vertices : PackedVector3Array = []
	
	#vertices.push_back(Vector3(0,1,0))
	for y in range(0,mesh_size-1):
		for x in range(0,mesh_size-1):
			vertices.push_back(Vector3(x, height_map.get_pixel(x, y+1).r, y+1))
			vertices.push_back(Vector3(x+1, height_map.get_pixel(x+1, y).r, y))
		vertices.push_back(Vector3(mesh_size-1, height_map.get_pixel(mesh_size-1, y+1).r, y+1))
		vertices.push_back(Vector3(mesh_size-1, height_map.get_pixel(mesh_size-1, y+1).r, y+1))
		#vertices.push_back(Vector3(mesh_size-1, 1, y+1))
		#vertices.push_back(Vector3(mesh_size-1,1,y+2))
	
	#for x in range(0, mesh_size):
	#	for y in range(0, mesh_size):
	#		#var pix := height_map.get_pixel(x*division, y*division)
	#		#var point := Vector3(x, pix.r, y)
	#		var point := Vector3(x, 1, y)
	#		vertices.push_back(point)
	
	var new_mesh := ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	#var m = MeshInstance3D.new()
	#m.mesh = new_mesh
	return new_mesh
