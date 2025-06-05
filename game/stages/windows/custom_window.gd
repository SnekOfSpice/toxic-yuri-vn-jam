extends PanelContainer
class_name CustomWindow

## used for whatever, usually within the window group 8f image viewrs, text log, etc
@export var id := 0
## used for saving / loading
var uid := 0
@export var title : String
@export var allow_close := false
@export var include_title_bar := true
@export var header_vbox_parent : VBoxContainer
@export var hide_on_ready := true
@export var icon : Texture2D

func  _ready() -> void:
	uid = get_index()
	if hide_on_ready: hide()
	if include_title_bar:
		var title_bar = preload("res://game/stages/windows/custom_window_title_bar.tscn").instantiate()
		header_vbox_parent.add_child(title_bar)
		header_vbox_parent.move_child(title_bar, 0)
		title_bar.close_requested.connect(close)
		title_bar.set_close_button_visible(allow_close)
		if title:
			title_bar.set_title(title)
		if icon:
			title_bar.set_icon(icon)
	
	gui_input.connect(on_gui_input)
	ParserEvents.go_back_accepted.connect(on_go_back_accepted)
	visibility_changed.connect(on_visibility_changed)

var visibilities_by_subaddress := {}
func on_go_back_accepted(page:int, line:int, dialine:int):
	var subaddress := str(page, ".", line, ".", dialine)
	if subaddress in visibilities_by_subaddress:
		visible = visibilities_by_subaddress.get(subaddress)

func on_visibility_changed():
	visibilities_by_subaddress[Parser.line_reader.get_subaddress()] = not visible

var dragging := false
var drag_offset : Vector2

func on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.is_echo():
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
	data["position.x"] = position.x
	data["position.y"] = position.y
	data["visible"] = visible
	data["rotation_degrees"] = rotation_degrees
	data["uid"] = uid
	return data

func deserialize(data:Dictionary):
	z_index = data.get("z_index", z_index)
	position.x = data.get("position.x", position.x)
	position.y = data.get("position.y", position.y)
	visible = data.get("visible", visible)
	rotation_degrees = data.get("rotation_degrees", rotation_degrees)
	uid = data.get("uid", uid)

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
