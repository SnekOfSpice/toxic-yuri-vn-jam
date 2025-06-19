extends Control

const CREDITS := {
	"LONER DOG: SNUFF PUPPY CARNAGE SOCIETY" : "A visual novel by:",
	"Snek Remilia Ketter" : "Programming, Writing, UI Design, Background Art",
	"Blood Machine" : "Character Art, CG Art, Character Design",
	"Jane Gorelove" : "Proofreading",
	"[musiceans]" : "OST contributions",
	}
	
const MESSAGES := [
	"POLITICS OF VISIBILITY WILL GET YOU KILLED",
	"RADICAL TRANS RIGHTS OR DEATH",
	"INJECT EXOGENOUS HORMONES",
	"DEATH TO FASCISM",
	"LOVE YOURSELF",
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
	visible = true
	Sound.fade_out_bgm(2)
	if GameWorld.game_stage:
		GameWorld.game_stage.hide_ui()
	await get_tree().create_timer(2.0).timeout
	$Logo.visible = true
	await get_tree().create_timer(4.0).timeout
	$Logo.visible = false
	$Black.modulate.a = 1.0
	Sound.play_bgm("credits")
	await get_tree().create_timer(2.0).timeout
	
	for message in MESSAGES:
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
		
		var fade = create_tween()
		fade.tween_property(%LabelContainer, "modulate:a", 1.0, 0.0)
		await fade.finished
		
		await get_tree().create_timer(4.0).timeout
		
		fade = create_tween()
		fade.tween_property(%LabelContainer, "modulate:a", 0.0, 0.0)
		await fade.finished
		
		await get_tree().create_timer(1.0).timeout
	
	var black_tween = create_tween()
	black_tween.tween_property(%TextContainer, "modulate:a", 0.0, 0.0)
	await black_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	
	
	
	await get_tree().create_timer(8.0).timeout
	%MessageContainer.visible = false
	await get_tree().create_timer(4.0).timeout
	
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
