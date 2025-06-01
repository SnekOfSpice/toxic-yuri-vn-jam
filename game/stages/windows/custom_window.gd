extends Control
class_name CustomWindow


@export var title : String
@export var allow_close := false

func  _ready() -> void:
	if title:
		find_child("TitleLabel").text = title
	find_child("CloseButton").visible = allow_close

func serialize():
	pass

func deserialize(data:Dictionary):
	pass

func open():
	show()
	Sound.play_sfx("keyboard")

func close():
	if not allow_close:
		return
	hide()
	Sound.play_sfx("keyboard")
