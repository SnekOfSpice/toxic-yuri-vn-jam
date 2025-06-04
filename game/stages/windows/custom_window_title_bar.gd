extends HBoxContainer

signal close_requested()

func _on_close_button_pressed() -> void:
	emit_signal("close_requested")

func set_title(title:String):
	find_child("TitleLabel").text = title

func set_close_button_visible(v:bool):
	find_child("CloseButton").visible = v

func set_icon(texture:Texture2D):
	$TextureRect.texture = texture
