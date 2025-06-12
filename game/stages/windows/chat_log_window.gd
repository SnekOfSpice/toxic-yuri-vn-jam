extends CustomWindow
class_name ChatLogWindow

var start_size:Vector2
var actor : String
func _ready() -> void:
	super()
	close()
	if not include_title_bar: # is for embodied voice
		find_child("PanelContainer").theme_type_variation = "EmbodiedText"
		%ScrollContainer.vertical_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_DISABLED
	else: # is digital comm
		%TextContent.theme_type_variation = "DigitalText"
		%ScrollContainer.vertical_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_RESERVE
		flatten_stylebox(get_body_label())
	start_size = size

func on_visibility_changed():
	super.on_visibility_changed()
	if not visible:
		clear_past_container()
		get_body_label().text = ""
	if visible:
		get_text_container().visible = true

func get_body_label() -> RichTextLabel:
	return %BodyLabel
func get_name_label() -> Label:
	return %NameLabel
func get_text_container() -> Control:
	return %TextContent
func get_name_container() -> Control:
	return %NameLabel
func get_past_container() -> VBoxContainer:
	return %PastContainer
func clear_past_container():
	for child in %PastContainer.get_children():
		child.queue_free()

func set_portrait(actor_name:String):
	actor = actor_name
	if actor_name == "":
		%Portrait.visible = false
		%Portrait.texture = load("res://game/characters/portraits/none.png")
		await get_tree().process_frame
		clamp_to_viewport()
		return
	%Portrait.visible = true
	%Portrait.texture = load("res://game/characters/portraits/%s.png" % actor_name)
	await get_tree().process_frame
	clamp_to_viewport()

func serialize() -> Dictionary:
	var data := super.serialize()
	data["body_label_text"] = %BodyLabel.text
	data["name_label_text"] = %NameLabel.text
	var past_lines := []
	for line in %PastContainer.get_children():
		past_lines.append(line.text)
	data["past_lines"] = past_lines
	data["actor"] = actor
	return data

func deserialize(data:Dictionary):
	super.deserialize(data)
	%BodyLabel.text = data.get("body_label_text", "")
	%NameLabel.text = data.get("name_label_text", "")
	
	for line in data.get("past_lines", []):
		var past_line = RichTextLabel.new()
		past_line.custom_minimum_size.x = %BodyLabel.custom_minimum_size.x
		past_line.fit_content = true
		past_line.bbcode_enabled = true
		past_line.mouse_filter = Control.MOUSE_FILTER_PASS
		past_line.text = line
		%PastContainer.add_child(past_line)
	set_portrait(data.get("actor", ""))

@warning_ignore("native_method_override")
func hide():
	super.hide()
	clear_past_container()

func flatten_stylebox(on_label:RichTextLabel):
	var stylebox : StyleBox = on_label.get_theme_stylebox("normal")
	var lmargin = stylebox.get_margin(SIDE_LEFT)
	var rmargin = stylebox.get_margin(SIDE_RIGHT)
	var box = StyleBoxEmpty.new()
	box.content_margin_left = lmargin
	box.content_margin_right = rmargin
	on_label.add_theme_stylebox_override("normal", box)

func _on_past_container_child_entered_tree(node: Node) -> void:
	if node in %PastContainer.get_children():
		if node is RichTextLabel:
			flatten_stylebox(node)


func _on_body_label_item_rect_changed() -> void:
	size = Vector2(start_size.x, 1)
	clamp_to_viewport()
