extends CustomWindow

func  _ready() -> void:
	super()
	close()

func get_body_label() -> RichTextLabel:
	return %BodyLabel
func get_name_label() -> Label:
	return %NameLabel
func get_text_container() -> Control:
	return %TextContent
func get_name_container() -> Control:
	return %NameLabel

func serialize() -> Dictionary:
	var data := super.serialize()
	data["body_label_text"] = %BodyLabel.text
	data["name_label_text"] = %NameLabel.text
	return data

func deserialize(data:Dictionary):
	super.deserialize(data)
	%BodyLabel.text = data.get("body_label_text", "")
	%NameLabel.text = data.get("name_label_text", "")
