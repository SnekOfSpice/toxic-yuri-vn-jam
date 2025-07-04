extends Button

var save_slot:int

func _ready() -> void:
	find_child("TextureRect").custom_minimum_size = Options.get_save_thumbnail_size()

func set_slot(slot:int):
	save_slot = slot
	var thumb_path : String = Options.get_save_thumbnail_path(save_slot)
	var image = Image.new()
	# ResourceLoader cannot load images at runtime, so we need to use Image.load()
	# That automatically throws an error on nonexistence tho so we just have to live with that
	var error := image.load(thumb_path)
	if error:
		find_child("TextureRect").texture = load("res://game/systems/save_system/no_data.png")
	else:
		find_child("TextureRect").texture = ImageTexture.create_from_image(image)
	
	find_child("Slot").text = str("Slot ", slot + 1)
	
	var data_path : String = Options.get_savedata_path(save_slot)
	if ResourceLoader.exists(data_path):
		var file = FileAccess.open(Options.get_save_time_path(slot), FileAccess.READ)
		var label = file.get_as_text()
		file.close()
		label = label.replace(" ", "\n")
		find_child("Data").text = label
	else:
		find_child("Data").text = "No Data"
	
	await get_tree().process_frame
	
	custom_minimum_size = $Container.size


func _on_mouse_entered() -> void:
	$Container.add_theme_constant_override("margin_top", 6)
	$Container.add_theme_constant_override("margin_bottom", 2)


func _on_mouse_exited() -> void:
	$Container.add_theme_constant_override("margin_top", 4)
	$Container.add_theme_constant_override("margin_bottom", 4)
