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
	visibilities_by_subaddress = {0:{0:{0:hide_on_ready}}}
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
	clamp_to_viewport()

var visibilities_by_subaddress := {}
func on_go_back_accepted(page:int, line:int, dialine:int):
	#windows can get hidden through and retargeted through functions, so there also needs to be a function that listens to any new line being read 
#and when going back, we need to compare to the first possible address
	var prev_page := page
	while prev_page > 0:
		if visibilities_by_subaddress.has(prev_page):
			break
		prev_page -= 1
	
	var prev_line := line
	while prev_line > 0:
		if visibilities_by_subaddress.get(prev_page).has(prev_line):
			break
		prev_line -= 1
	
	var prev_dialine := dialine
	while prev_dialine > 0:
		if visibilities_by_subaddress.get(prev_page).get(prev_line).get(prev_dialine):
			break
		prev_dialine -= 1
	
	visible = visibilities_by_subaddress[prev_page][prev_line][prev_dialine]

func on_visibility_changed():
	dragging = false
	var subaddress_arr := Parser.line_reader.get_subaddress_arr()
	var page : Dictionary
	var page_index : int = subaddress_arr[0]
	var line_index : int = subaddress_arr[1]
	var dialine_index : int = subaddress_arr[2]
	if visibilities_by_subaddress.has(page_index):
		page = visibilities_by_subaddress.get(page_index)
	else:
		page = {}
		visibilities_by_subaddress[page_index] = page
	var line : Dictionary
	if page.has(line_index):
		line = page.get(line_index)
	else:
		line = {}
		page[line_index] = line
	
	if not line.has(dialine_index):
		line[dialine_index] = visible
	
	visibilities_by_subaddress[page_index][line_index][dialine_index] = visible

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
	get_parent().move_child(self, get_parent().get_child_count() - 1)

func clamp_to_viewport():
	global_position.x = clamp(global_position.x,
		0,
		ProjectSettings.get_setting("display/window/size/viewport_width") - size.x)
	global_position.y = clamp(global_position.y,
		0,
		ProjectSettings.get_setting("display/window/size/viewport_height") - size.y)

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		clamp_to_viewport()
		

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
