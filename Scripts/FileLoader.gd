extends Control

const DIR_ERR = 'ERROR: Failed to create directory "%s". Error code %s.'

# Equivalent to '~/Documents/ModelViewer/Models/OBJ' in Linux
var export_path := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/ModelViewer/Models/OBJ"

var file_path := ""
var loaded_file := File.new()

onready var viewer := $"%ModelViewer"


func _ready() -> void:
	get_tree().connect("files_dropped", self, "get_files_path")


func get_files_path(files: PoolStringArray, _screen: int) -> void:
	file_path = files[0]
	if not file_path.empty():
		create_new_model()


func create_new_model() -> void:
	# Create directory first if it doesn't exist yet
	var dir := Directory.new()
	
	if _create_directory(dir, export_path) == true:
		# Copy OBJ model
		dir.copy(file_path, export_path+"/"+file_path.get_file())

		# Copy MTL file
		dir.copy(get_mtl_path(), 
		export_path+"/"+get_mtl_path().get_file())

		# Copy PNG texture
		var copy_path : String = get_tex_path(export_path+"/"+get_mtl_path().get_file())[0]
		var rel_path : String = get_tex_path(export_path+"/"+get_mtl_path().get_file())[1]

		# Check if MTL file exist, if yes, get the texture
		if dir.file_exists(export_path+"/"+get_mtl_path().get_file()):
			# Check if directory exists first before copying file
			if dir.dir_exists(export_path+"/"+rel_path) == true:
				dir.copy(copy_path, export_path+"/"+rel_path)
			else:
				dir.make_dir(export_path+"/"+rel_path.get_base_dir())
				dir.copy(copy_path, export_path+"/"+rel_path)

		# After copying the needed OBJ, MTL, and texture files, add a new model which will use them (via paths below)
		viewer.add_model(
			export_path+"/"+file_path.get_file(),
			export_path+"/"+file_path.get_file().replacen(".obj", ".tscn"),
			export_path+"/"+get_mtl_path().get_file())


func get_mtl_path() -> String:
	var mtl_path := ""
	var file := File.new()

	# Open OBJ, get its text, then find MTL's path
	file.open(file_path, File.READ)
	var obj_contents := file.get_as_text()

	# Find mtllib and .mtl, then get their length
	var mtl_path_start := obj_contents.findn("mtllib ")+7
	var mtl_path_end := obj_contents.findn(".mtl", 0)+4

	# Remove all string from left starting at mtllib string's length
	mtl_path = obj_contents.trim_prefix(obj_contents.left(mtl_path_start))

	# Remove all string from right starting at .mtl string's length
	mtl_path = mtl_path.trim_suffix(obj_contents.right(mtl_path_end))

	file.close()

	# Check if file path is valid and relative to the OBJ's path
	if mtl_path.is_rel_path() == true:
		mtl_path = mtl_path.insert(0, file_path.get_base_dir()+"/")

	return mtl_path


func get_tex_path(mtl_path: String) -> Array:
	var tex_path := ""
	var paths := ["", ""]
	var file := File.new()

	# Open MTL, get its text, then find PNG's path
	file.open(mtl_path, File.READ)
	var mtl_contents := file.get_as_text()

	# Find map_kd and .mtl, then get their length
	var tex_path_start := mtl_contents.findn("map_kd ")+7
	var tex_path_end := mtl_contents.findn(".png", 0)+4

	# Remove all string from left starting at mtllib string's length
	tex_path = mtl_contents.trim_prefix(mtl_contents.left(tex_path_start))

	# Remove all string from right starting at .mtl string's length
	tex_path = tex_path.trim_suffix(mtl_contents.right(tex_path_end))

	# Relative path of file being copied
	paths[1] = tex_path

	file.close()

	# Get absolute path of texture
	var file_origin := file_path.get_basename()
	var file_name := file_path.get_file()

	file_name = file_name.trim_suffix("."+file_name.get_extension())
	file_origin = file_origin.trim_suffix(file_name)

	tex_path = tex_path.insert(0, file_origin)

	# 'Copy to' path
	paths[0] = tex_path

	return paths


func _create_directory(directory, path) -> bool:
	var exists := false
	if not directory.dir_exists(path):
		var error_code = directory.make_dir_recursive(path)
		exists = true
		if error_code != OK:
			printerr(DIR_ERR % [path, error_code])
			exists = false
	else:
		exists = true
	return exists
