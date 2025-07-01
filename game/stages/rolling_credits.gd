extends Control

const CREDITORS := [
	"LONER_DOG://Snuff Puppy Carnage Society",
	"Snek Remilia Ketter",
	"Blood Machine",
	"[musicean 1]",
	"[musicean 2]",
	"Jane Gorelove",
	"The creative commons community",
	"LONER_DOG://Snuff Puppy Carnage Society",
]
const CREDIT_CONTENT := [
	"A visual novel by...",
	"Programming\t\t\t\tWriting\t\t\t\tUI Design\t\t\t\tBackground Art",
	"Character Art\t\t\t\tCG Art\t\t\t\tCharacter Design",
	"OST Contributions",
	 "OST Contributions",
	"Proofreading",
	"Various Stuff (Check main menu credits)",
	"Made for TOXIC YURI VN JAM",
	]
	
const MESSAGES := [
	"POLITICS OF VISIBILITY WILL GET YOU KILLED",
	"RADICAL TRANS RIGHTS OR DEATH",
	"INJECT EXOGENOUS HORMONES",
	"DEATH TO FASCISM",
	"LOVE YOURSELF",
	"BE QUEER",
	"<3"
]

@onready var start_position : Vector2 = %MessageContainer.position
var wiggle_timer := 0.0

func _ready() -> void:
	visible = false
	$Black.modulate.a = 0.0
	$Black.visible = true
	%Label.visible = true
	$Logo.visible = false
	%TextContainer.visible = false
	if get_parent() == get_tree().root:
		start()
	
	$GridContainer.visible = false

func start():
	Sound.fade_out_bgm(4)
	var credits : CanvasLayer = GameWorld.game_stage.find_child("CreditsLayer")
	credits.visible = true
	visible = true
	$GridContainer.visible = true
	var paws := []
	for i in 300:
		var tex = TextureRect.new()
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		tex.custom_minimum_size = Vector2(50, 50)
		tex.texture = load("res://game/visuals/opening_icon.png")
		tex.modulate.a = 0
		$GridContainer.add_child(tex)
		paws.append(i)
	paws.shuffle()
	var time_buffer := 2.065
	while not paws.is_empty():
		Sound.play_sfx("hover")
		var paw_index = paws.pop_back()
		$GridContainer.get_child(paw_index).modulate.a = 1
		await get_tree().create_timer(0.005 + time_buffer).timeout
		if time_buffer >= 0.065:
			time_buffer -= 0.4
		time_buffer = max(0, time_buffer - 0.001)
	await get_tree().create_timer(3).timeout
	$GridContainer.visible = false
	$Logo.visible = true
	var riser_player := Sound.play_sfx("riser", false)
	var riser_length := riser_player.stream.get_length()
	
	var i := 0
	
	var params := [
		{"contrast_mult" : 2,
		"brightness_add" : -0.118},
		{"value_mult" : 1.484},
		{"saturation_mult":1.237}
	]
	var step_length = riser_length / float(params.size())
	while i < params.size():
		var param_settings : Dictionary = params[i]
		for param in param_settings.keys():
			credits.get_child(0).get_material().set_shader_parameter(param, param_settings.get(param))
		await get_tree().create_timer(step_length).timeout
		i += 1
	#await get_tree().create_timer(riser_length).timeout
	
	Sound.fade_out_bgm(0)
	if GameWorld.game_stage:
		#GameWorld.game_stage.hide_ui()
		GameWorld.game_stage.find_child("ControlsContainer").visible = false
	#await get_tree().create_timer(2.0).timeout
	
	#await get_tree().create_timer(4.0).timeout
	$Logo.visible = false
	$Black.modulate.a = 1.0
	Sound.play_bgm("credits")
	await get_tree().create_timer(2.0).timeout
	
	for message in MESSAGES:
		var clicker := Sound.play_sfx("clicker")
		await get_tree().create_timer(clicker.stream.get_length() * 0.8).timeout
		var label := RichTextLabel.new()
		label.add_theme_font_override("normal_font", load("res://game/visuals/estrogen_font.tres"))
		label.add_theme_font_size_override("normal_font_size", 30)
		label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = message
		label.fit_content = true
		%MessageContainer.add_child(label)
		await get_tree().create_timer(3.0).timeout
	
	await get_tree().create_timer(4.0).timeout
	%TextContainer.visible = true
	
	var j := 0
	while j < CREDITORS.size():
		%NameLabel.text = CREDITORS[j]
		%Label.text = CREDIT_CONTENT[j]
		#%TextContainer.rotation_degrees = randf_range(-1.1, 2.3)
		
		var segments = %Label.text.split("\t\t\t\t", false)
		
		var segment_size : int = segments.size()
		if segment_size <= 1:
			segment_size = 0
		#var fade = create_tween()
		#fade.tween_property(%LabelContainer, "modulate:a", 1.0, 0.0)
		#await fade.finished
		Sound.play_sfx("shutter")
		await get_tree().create_timer(8.0 + segment_size).timeout
		
		#fade = create_tween()
		#fade.tween_property(%LabelContainer, "modulate:a", 0.0, 0.0)
		#await fade.finished
		
		#await get_tree().create_timer(1.0).timeout
		j += 1
	
	var black_tween = create_tween()
	black_tween.tween_property(%TextContainer, "modulate:a", 0.0, 0.0)
	Sound.play_sfx("shutter")
	await black_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	
	
	
	await get_tree().create_timer(8.0).timeout
	%MessageContainer.visible = false
	Sound.play_sfx("shutter")
	await get_tree().create_timer(4.0).timeout
	Sound.fade_out_bgm(4.5)
	await get_tree().create_timer(6.0).timeout
	
	Parser.function_acceded()

func _process(delta: float) -> void:
	if not %MessageContainer.visible:
		return
	wiggle_timer += delta
	if wiggle_timer >= 1.5:
		wiggle_timer = 0
		%MessageContainer.position = start_position + Vector2(
			randi_range(-1, 1),
			randi_range(-1, 1),
		)
