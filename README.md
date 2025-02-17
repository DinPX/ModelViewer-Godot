# Model Viewer
View your obj models on the fly!  
Features drag-and-drop (OBJ), rotation, zooming and loading models.

![app detailed and simple preview](/model_viewer_preview.png)

**Note:** The drag-and-drop function was only tested on files that share the same parent folder, e.g.  
`./Skibidi/amogus.obj`, `./Skibidi/amogus.mtl` and `./Skibidi/Texture/sussy_tex.png`.  
Other directory structures would most likely result to error.

# Controls
- Drag and drop an OBJ file into the window to load it
- Left mouse button - swipe to rotate the models
- Scroll wheel / middle mouse button - scroll to zoom in and out the models
- Previous and next buttons ![previous button sprite](/Assets/Images/prev_btn.png) ![next button sprite](/Assets/Images/next_btn.png) - navigate and load models
- Background toggle button ![toggle background button sprite](/Assets/Images/turn_off_btn.png) - toggles between simple and blooming background
- Help button ![help toggle button sprite](/Assets/Images/help_btn.png) - shows / hides help screen
- Credits button ![credits toggle button sprite](/Assets/Images/credits_btn.png) - shows / hides credits screen

# Documentation
## FileLoader.gd
This script handles the creation of directories and copying of necessary files.  

- `export_path` - path where the drag-and-dropped file and others will be copied to.
```gdscript
# Equivalent to '~/Documents/ModelViewer/Models/OBJ' in Linux
var export_path := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/ModelViewer/Models/OBJ"
```  

- `create_new_model()` - creates a directory and copies each `obj`, `mtl`, and texture file.
```gdscript
...

if _create_directory(dir, export_path) == true:
    # Copy OBJ model
    dir.copy(file_path, export_path+"/"+file_path.get_file())

    # Copy MTL file
    dir.copy(get_mtl_path(), 
    export_path+"/"+get_mtl_path().get_file())

    # Copy PNG texture
    var copy_path : String = get_tex_path(export_path+"/"+get_mtl_path().get_file())[0]
    var rel_path : String = get_tex_path(export_path+"/"+get_mtl_path().get_file())[1]

    ...
```  

- `add_model(mesh_path: String, file_path: String, material_path: String)` - adds model to the array of models. It uses the arguments to load needed files and make a loadable resource from them.
    - `mesh_path` - this argument refers to the path of the `obj` file
    - `file_path` - this argument refers to the path of the `tscn` file
```gdscript
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
```

# Changes

<details open>
<summary>added <b>gd-obj</b> <code>3.x</code> by <a href="https://github.com/Ezcha" target="_blank">Ezcha</a> and co. [Feb. 17, 2025]</summary>

- It is now possible to parse `obj` to mesh thanks to their amazing work.
- Now loads `obj`, `mtl`, and texture on export build

</details>

<details>
<summary>fixed texture pixel issues [Dec. 30, 2024]</summary>
<h3>UI</h3>

- Uses `GPU Pixel Snap` to show pixels properly
    - Enabled `rendering/2d/snapping/use_gpu_pixel_snap`

</details>

<details>
<summary>added drag-and-drop [Dec. 28, 2024]</summary>
<h3>Feature</h3>

- Added drag-and-drop functionality
- Loads a single dropped file
- Generates a new MeshInstance and adds it to the `models`
- Loads OBJ's MTL and TEX on load

</details>

<details>
<summary>added credits, UI scaling, etc. [Dec. 20, 2024]</summary>
<h3>UI</h3>

- Fixed UI scaling to be responsive to window's size
- Changed UI's default scale to 2x
    - In order to be clear on smaller window sizes
- Added credits screen of the authors and assets
- Changed the toggle background button's sprites
    - In order to take less space visually

</details>

<details>
<summary>added buttons, bloom background, help screen, etc. [Dec. 19, 2024]</summary>
<h3>UI</h3>

- Fixed buttons' positions when scaling the window
- Added more buttons (e.g. background and help toggle)
- Added sprites for buttons
- Added text to show model's filename
- Added a detailed background with bloom to test models with lightings
- Used Bit3 font for texts

<h3>Models</h3>

- Removed models from initial fork due to the rights

<h3>Code</h3>

- Added/cleaned some lines of code

</details>

# To-do
- [x] Make UI's scale responsive to window's scale
- [x] Drag n' drop OBJs and load them as scenes
- [ ] Controls for adjusting the detailed background
- [x] Credits screen
- [x] Fix pixel tearing of textures (e.g. buttons)
- [x] Make drag-and-drop work on export

# Credits
## Source
**Ivolutio [(@Ivolutio)](https://github.com/Ivolutio)** - loading models, controls  
**Dylan [(@Ezcha)](https://github.com/Ezcha)**, **Jeff Brooks [(@jeffgamedev)](https://github.com/jeffgamedev)**, **Deakcor [(@deakcor)](https://github.com/deakcor)**, and **Karl [(@kb173)](https://github.com/kb173)** - `obj` parser  
**Din [(@DinPX)](https://github.com/DinPX)** - drag-and-drop to load model, and some UI sprites

## Models
**Kenney [(www.kenney.nl)](https://www.kenney.nl)** - cars, barrel, crate, tree  
License: Creative Commons Zero, CC0 [(https://creativecommons.org/publicdomain/zero/1.0/)](https://creativecommons.org/publicdomain/zero/1.0/)
- **Car Kit:** <https://www.kenney.nl/assets/car-kit>
- **Platformer Kit:** <https://www.kenney.nl/assets/platformer-kit>

## Fonts
**Bit3 Font** by **[CamShaft](https://www.fontsc.com/font/designer/camshaft)**  
License: Freeware (Personal & Commercial Use)  
<https://fontzone.net/font-details/bit3>

## License
This project uses **gd-obj** `3.x` by **[(@Ezcha)](https://github.com/Ezcha)** and co. which is under their own MIT license: [https://github.com/Ezcha/gd-obj/blob/3.x/LICENSE](https://github.com/Ezcha/gd-obj/blob/3.x/LICENSE).