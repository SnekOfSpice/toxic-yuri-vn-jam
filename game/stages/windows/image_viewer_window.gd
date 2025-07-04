extends CustomWindow
class_name ImageViewerWindow

var image_id:String


func  _ready() -> void:
	super()

func serialize() -> Dictionary:
	var data := super.serialize()
	data["image_id"] = image_id
	return data

func deserialize(data:Dictionary):
	show_image(data.get("image_id", ""))
	super.deserialize(data)


func show_image(image:String, x_min:=200, y_min:=200):
	image_id = image
	if image.is_empty():
		return
	size = Vector2.ONE
	var tex : TextureRect = find_child("TextureRect")
	tex.texture = load("res://game/images/%s.png" % image)
	tex.custom_minimum_size = Vector2(x_min, y_min)
	find_child("FileNameLabel").text = image
	move_to_top()
	clamp_to_viewport()


func _on_change_size_button_pressed() -> void:
	pass # Replace with function body.
