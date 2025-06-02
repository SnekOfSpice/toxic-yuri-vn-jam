extends Control
class_name CustomWindow

@export var id := 0
@export var title : String
@export var allow_close := false
@export var header_vbox_parent : VBoxContainer

func  _ready() -> void:
	hide()
	var title_bar = preload("res://game/stages/windows/custom_window_title_bar.tscn").instantiate()
	header_vbox_parent.add_child(title_bar)
	header_vbox_parent.move_child(title_bar, 0)
	title_bar.close_requested.connect(close)
	title_bar.set_close_button_visible(allow_close)
	if title:
		title_bar.set_title(title)
	
	gui_input.connect(on_gui_input)

var dragging := false
var drag_offset : Vector2

func on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_echo():
			if event.pressed:
				dragging = true
				move_to_top()
				drag_offset = get_local_mouse_position()
			else:
				dragging = false

func move_to_top():
	open_if_closed()
	for window :CustomWindow in get_parent().get_children():
		window.z_index = 0
	z_index = 1

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func serialize() -> Dictionary:
	# serialize the get_index() of these and then also use that during deserialization to preserve order
	var data := {}
	data["z_index"] = z_index
	data["position"] = position
	data["visible"] = visible
	data["rotation_degrees"] = rotation_degrees
	return data

func deserialize(data:Dictionary):
	z_index = data.get("z_index", z_index)
	position = data.get("position", position)
	visible = data.get("visible", visible)
	rotation_degrees = data.get("rotation_degrees", rotation_degrees)

func open():
	show()
	move_to_top()
	Sound.play_sfx("keyboard")
func open_if_closed():
	if visible:return
	open()

func close():
	if not allow_close:
		return
	hide()
	Sound.play_sfx("keyboard")
