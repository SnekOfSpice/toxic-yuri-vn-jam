extends ColorRect


@onready var label : RichTextLabel = $RichTextLabel

func _ready() -> void:
	visible = false

func read(text:String, hide_all_windows:=true):
	Sound.play_sfx("shutter")
	visible = true
	label.text = text
	label.visible_characters = 0
	await get_tree().create_timer(1).timeout
	if hide_all_windows:
		GameWorld.game_stage.hide_all_windows()
	for i in text.length() + 1:
		await get_tree().create_timer(randf_range(0.2, 0.3)).timeout
		label.visible_characters = i + 2
		Sound.play_sfx("keyboard")
		var s = $RichTextLabel.get_theme_font_size("normal_font_size")
		var cursor := "[font_size=%s]▮[/font_size]" % str(s * 0.5)
		if i > 0 and i <= text.length() - 1:
			label.text = label.text.erase(i, cursor.length())
		if i < text.length() - 1:
			
			label.text = label.text.insert(i+1, cursor)
	
	await get_tree().create_timer(1.5).timeout
	label.visible_characters = 0
	Sound.play_sfx("keyboard")
	await get_tree().create_timer(1.5).timeout
	visible = false
	Sound.play_sfx("shutter")
	await get_tree().create_timer(2.5).timeout
	Parser.function_acceded()
