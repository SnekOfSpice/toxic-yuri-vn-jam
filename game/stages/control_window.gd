extends VBoxContainer

@export var visible_only_on_focus := false

@onready var content_container : Control = find_child("ContentContainer")

func add_content(content:Control):
	for child in content_container.get_children():
		child.queue_free()
	content_container.add_child(content)

func hide_custom():
	# TODO
	hide()

func _on_focus_exited() -> void:
	if visible_only_on_focus:
		hide_custom()
