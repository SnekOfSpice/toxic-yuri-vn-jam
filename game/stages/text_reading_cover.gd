extends ColorRect


@onready var label : RichTextLabel = $RichTextLabel

func _ready() -> void:
	visible = false

func read(text:String,
	background:String=GameWorld.game_stage.background,
	bgm:=Sound.bgm_key,
	reset_windows:=true):
	if not GameWorld.game_stage.background in ["", "black"]:
		Sound.play_sfx("shutter")
	visible = true
	
	label.text = text
	label.visible_characters = 0
	await get_tree().create_timer(1).timeout
	if bgm != Sound.bgm_key:
		Sound.fade_out_bgm(0.5 * text.length() * 0.25)
	if reset_windows:
		GameWorld.hidden_ui_reset()
	GameWorld.game_stage.set_background(background)
	var started_playing_music := false
	for i in text.length() + 1:
		var wait_time = randf_range(0.2, 0.3)
		if label.get_parsed_text().substr(0, label.visible_characters-1).ends_with("\n"):
			wait_time += 0.5
		await get_tree().create_timer(wait_time).timeout
		label.visible_characters = i + 2
		if i < text.length():
			Sound.play_sfx("keyboard")
		var s = $RichTextLabel.get_theme_font_size("normal_font_size")
		var cursor := "[font_size=%s]▮[/font_size]" % str(s * 0.5)
		if i > 0 and i <= text.length() - 1:
			label.text = label.text.erase(i, cursor.length())
		if i < text.length() - 1:
			label.text = label.text.insert(i+1, cursor)
		
		if not started_playing_music and i >= text.length() * 0.75:
			Sound.play_bgm(bgm, 0.25 * text.length())
			started_playing_music = true
	
	await get_tree().create_timer(1.5).timeout
	label.visible_characters = 0
	Sound.play_sfx("keyboard")
	await get_tree().create_timer(1.5).timeout
	GameWorld.game_stage.conditional_hide()
	visible = false
	Sound.play_sfx("shutter")
	await get_tree().create_timer(2.5).timeout
	Parser.function_acceded()
