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

@onready var top_index : int = get_parent().get_child_count() - 1

func  _ready() -> void:
	#GoBackHandler.store_into_subaddress(false, visibilities_by_subaddress, "0.0.0")
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
	#ParserEvents.go_back_accepted.connect(on_go_back_accepted)
	#ParserEvents.read_new_line.connect(on_read_new_line)
	visibility_changed.connect(on_visibility_changed)
	clamp_to_viewport()

#func on_read_new_line(line_index:int):
	#GoBackHandler.store_into_subaddress(visible, false, visibilities_by_subaddress, Parser.page_index, line_index, 0)

#
#var visibilities_by_subaddress := {}
#func on_go_back_accepted(page:int, line:int, dialine:int):
	##windows can get hidden through and retargeted through functions, so there also needs to be a function that listens to any new line being read 
##and when going back, we need to compare to the first possible address
	#
	#visible = GoBackHandler.fetch_prev_from_subaddress(visibilities_by_subaddress, page, line, dialine)

func on_visibility_changed():
	dragging = false
		
	#GoBackHandler.store_into_subaddress(visible, visibilities_by_subaddress, Parser.line_reader.get_subaddress())

var dragging := false
var drag_offset : Vector2
var was_lmb_down := false
func on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				# god fucking spaghetti
				if (position == drag_start_position and (drag_start_index == get_index() or not GameWorld.game_stage.is_window_overlapping(self))):
					Parser.line_reader.request_advance()
				if dragging:
					get_viewport().set_input_as_handled()
					dragging = false
			if event.pressed and not event.is_echo():
				start_dragging()
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.is_echo():
			if event.pressed:
				start_dragging()
			else:
				dragging = false

var drag_start_position : Vector2
var drag_start_index : int
func start_dragging():
	drag_start_position = position
	drag_start_index = get_index()
	dragging = true
	drag_offset = get_local_mouse_position().rotated(rotation)

func move_to_top(force_open:=true):
	if force_open:
		open_if_closed()
	get_parent().move_child(self, top_index)

func clamp_to_viewport():
	await  get_tree().process_frame
	global_position.x = clamp(global_position.x,
		0,
		ProjectSettings.get_setting("display/window/size/viewport_width") - size.x)
	global_position.y = clamp(global_position.y,
		0,
		ProjectSettings.get_setting("display/window/size/viewport_height") - size.y)

var last_pos:Vector2
func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
		clamp_to_viewport()
		if global_position != last_pos and get_index() != top_index:
			move_to_top()
		last_pos = global_position
		

func serialize() -> Dictionary:
	# serialize the get_index() of these and then also use that during deserialization to preserve order
	var data := {}
	data["z_index"] = z_index
	data["index"] = get_index()
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
	play_open_sfx()


func open_if_closed():
	if visible:return
	open()

func close():
	if not allow_close:
		return
	hide()
	play_close_sfx()

func play_open_sfx():
	Sound.play_sfx("keyboard")

func play_close_sfx():
	Sound.play_sfx("keyboard")
