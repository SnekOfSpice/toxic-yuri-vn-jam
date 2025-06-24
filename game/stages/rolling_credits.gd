extends Control

const CREDITS := {
	"LONER_DOG://Snuff Puppy Carnage Society" : "A visual novel by...",
	"Snek Remilia Ketter" : "Programming\t\t\t\tWriting\t\t\t\tUI Design\t\t\t\tBackground Art",
	"Blood Machine" : "Character Art\t\t\t\tCG Art\t\t\t\tCharacter Design",
	"Jane Gorelove" : "Proofreading",
	"[musiceans]" : "OST Contributions",
	"The creative commons community" : "Various Stuff (Check main menu credits)"
	}
	
const MESSAGES := [
	"POLITICS OF VISIBILITY WILL GET YOU KILLED",
	"RADICAL TRANS RIGHTS OR DEATH",
	"INJECT EXOGENOUS HORMONES",
	"EVERY FASCIST MUST DIE",
	"LOVE YOURSELF",
	"BE QUEER",
	"BE GAY",
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

func start():
	await get_tree().create_timer(0.75).timeout
	var riser_player := Sound.play_sfx("riser", false)
	var riser_length := riser_player.stream.get_length()
	
	var i := 0
	var credits : CanvasLayer = GameWorld.game_stage.find_child("CreditsLayer")
	credits.visible = true
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
	visible = true
	Sound.fade_out_bgm(0)
	if GameWorld.game_stage:
		#GameWorld.game_stage.hide_ui()
		GameWorld.game_stage.find_child("ControlsContainer").visible = false
	#await get_tree().create_timer(2.0).timeout
	$Logo.visible = true
	await get_tree().create_timer(4.0).timeout
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
	
	for creditor : String in CREDITS.keys():
		
		%NameLabel.text = creditor
		%Label.text = CREDITS.get(creditor)
		#%TextContainer.rotation_degrees = randf_range(-1.1, 2.3)
		
		var segments = %Label.text.split("\t\t\t\t", false)
		print(segments)
		#var fade = create_tween()
		#fade.tween_property(%LabelContainer, "modulate:a", 1.0, 0.0)
		#await fade.finished
		Sound.play_sfx("shutter")
		await get_tree().create_timer(8.0 + segments.size()).timeout
		
		#fade = create_tween()
		#fade.tween_property(%LabelContainer, "modulate:a", 0.0, 0.0)
		#await fade.finished
		
		#await get_tree().create_timer(1.0).timeout
	
	var black_tween = create_tween()
	black_tween.tween_property(%TextContainer, "modulate:a", 0.0, 0.0)
	await black_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	
	
	
	await get_tree().create_timer(8.0).timeout
	%MessageContainer.visible = false
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
