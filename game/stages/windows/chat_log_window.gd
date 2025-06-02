extends CustomWindow

func  _ready() -> void:
	super()

func get_body_label() -> RichTextLabel:
	return %BodyLabel
func get_name_label() -> Label:
	return %NameLabel
func get_text_container() -> Control:
	return %TextContent
func get_name_container() -> Control:
	return %NameLabel

func serialize():
	pass

func deserialize(data:Dictionary):
	pass
