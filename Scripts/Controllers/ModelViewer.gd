extends Spatial

onready var models := [ 
	preload("res://Models/Taxi.tscn"), 
	preload("res://Models/Race.tscn"),
	preload("res://Models/TractorPolice.tscn"),
	preload("res://Models/Barrel.tscn"),
	preload("res://Models/Tree.tscn"),
	preload("res://Models/Crate.tscn"),
]
onready var model_name := get_parent().get_node("UI/Name")
var model_index := 0
var current_model = null


func _ready() -> void:
	_setModel(model_index)
	pass


func nextModel() -> void:
	if model_index >= models.size()-1:
		model_index = 0
	else:
		model_index += 1
	_setModel(model_index)
	pass


func prevModel() -> void:
	if model_index <= 0:
		model_index = models.size()-1
	else:
		model_index -= 1
	_setModel(model_index)
	pass


func _setModel(index: int) -> void:
	var model = models[index].instance()
	if current_model != null:
		current_model.queue_free()
	add_child(model)
	current_model = model
	model_name.text = current_model.mesh.resource_path.get_file()
	pass


func add_model(mesh_path: String, file_path: String, material_path: String) -> void:
	var model = MeshInstance.new()
	var mesh = ObjParse.load_obj(mesh_path, material_path)

	# Make a new image and set it as a texture
	var image = Image.new()
	# This is the relative path of texture but I don't want to make another variable so here it is...
	image.load(material_path.rstrip(material_path.get_file())+ObjParse.get_mtl_tex_paths(material_path)[0])

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Check for multiple surfaces and set their own materials
	for i in mesh.get_surface_count():
		mesh.surface_get_material(i).albedo_texture = texture

	model.mesh = mesh

	model.rotation_degrees.y = 45
	model.scale = Vector3(4, 4, 4)
	model.translation.y = -1

	var scene = PackedScene.new()
	var result = scene.pack(model)

	if result == OK:
		var error = ResourceSaver.save(file_path, scene)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")

	models.push_back(scene)
	model_index = models.size() - 1
	_setModel(model_index)
