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
	super.deserialize(data)
	show_image(data.get("image_id", ""))


func show_image(image:String):
	image_id = image
	if image.is_empty():
		return
	var tex : TextureRect = find_child("TextureRect")
	tex.texture = load("res://game/images/%s.png" % image)
	find_child("FileNameLabel").text = image
	move_to_top()


func _on_change_size_button_pressed() -> void:
	pass # Replace with function body.
