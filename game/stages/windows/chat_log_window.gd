extends CustomWindow
class_name ChatLogWindow

func  _ready() -> void:
	super()
	close()
	if not include_title_bar: # is for embodied voice
		find_child("PanelContainer").theme_type_variation = "EmbodiedText"
	else: # is digital comm
		%TextContent.theme_type_variation = "DigitalText"

func get_body_label() -> RichTextLabel:
	return %BodyLabel
func get_name_label() -> Label:
	return %NameLabel
func get_text_container() -> Control:
	return %TextContent
func get_name_container() -> Control:
	return %NameLabel

func set_portrait(actor:String):
	if actor == "":
		%Portrait.texture = load("res://game/characters/portraits/none.png")
		return
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
