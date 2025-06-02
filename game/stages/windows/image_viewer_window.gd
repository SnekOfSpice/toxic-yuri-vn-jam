extends CustomWindow
class_name ImageViewerWindow

var image_id:String

func  _ready() -> void:
	super()

func serialize():
	pass

func deserialize(data:Dictionary):
	pass


func show_image(image:String):
	image_id = image
	var tex : TextureRect = find_child("TextureRect")
	tex.texture = load("res://game/images/%s.png" % image)
	find_child("FileNameLabel").text = image
	move_to_top()
