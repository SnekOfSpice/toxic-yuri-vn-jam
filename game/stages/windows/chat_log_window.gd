extends CustomWindow
class_name ChatLogWindow

func  _ready() -> void:
	super()
	close()
	if not include_title_bar: # is for embodied voice
		find_child("PanelContainer").theme_type_variation = "EmbodiedText"
		%ScrollContainer.vertical_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_DISABLED
	else: # is digital comm
		%TextContent.theme_type_variation = "DigitalText"
		%ScrollContainer.vertical_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_RESERVE

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

func set_portrait(actor:String):
	if actor == "":
		%Portrait.visible = false
		%Portrait.texture = load("res://game/characters/portraits/none.png")
		return
	%Portrait.visible = true
	%Portrait.texture = load("res://game/characters/portraits/%s.png" % actor)
func serialize() -> Dictionary:
	var data := super.serialize()
	data["body_label_text"] = %BodyLabel.text
	data["name_label_text"] = %NameLabel.text
	return data

func deserialize(data:Dictionary):
	super.deserialize(data)
	%BodyLabel.text = data.get("body_label_text", "")
	%NameLabel.text = data.get("name_label_text", "")
