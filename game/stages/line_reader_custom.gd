@tool
extends LineReader

signal start_black_fade(
	fade_in:float,
	hold_time:float,
	fade_out:float,
	hide_characters:bool,
	new_background:String,
	new_bgm:String)

signal start_show_cg(
	cg_name:String,
	fade_in:float,
	on_top:bool)

signal start_hide_cg(fade_out:float)
signal start_chapter_cover(pov_name:String, bottom_text, new_background, zoom, bgm)
signal request_object_visible(object_name:String, visibility:bool)



var camera : Camera2D

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	camera = %Camera2D
	
	#if not body_label:
		#await  get_tree().process_frame
		#set_body_label(GameWorld.game_stage.get_body_label(0))

func play_sfx(_name:String):
	Sound.play_sfx(_name)
	return false

func set_bgm(_name:String, fade_in:float):
	Sound.play_bgm(_name, fade_in)
	return false


func black_fade(fade_in:float, hold_time:float, fade_out:float, hide_characters:bool, new_background:String, new_bgm:String):
	var bg = new_background
	if new_background == "none":
		bg = GameWorld.background
	
	var bgm = new_bgm
	if not bg:
		push_warning(str("COULDN'T FIND MUSIC ", new_bgm, "!"))
		bgm = "main_menu"
	if new_bgm == "none" or new_bgm == "null":
		bgm = Sound.bgm_key
	
	emit_signal("start_black_fade",
	fade_in,
	hold_time,
	fade_out,
	hide_characters,
	bg,
	bgm,
	)
	return true


func hide_all_characters() -> bool:
	for character: Character in get_tree().get_nodes_in_group("character"):
		character.visible = false
	return false


func show_cg(_name:String, fade_in_time:float, continue_dialog_through_cg:bool):
	emit_signal("start_show_cg",
	_name,
	fade_in_time,
	not continue_dialog_through_cg
	)
	return not continue_dialog_through_cg

func hide_cg(fade_out:=2.0):
	emit_signal("start_hide_cg", fade_out)
	return false

func set_background(_name:String, fade_time:=0.0):
	GameWorld.game_stage.set_background(
				_name,
				fade_time
			)
	return false


func play_chapter_intro(pov_name: String, bottom_text: String, new_background: String, zoom: float, bgm: = "One <3") -> bool:
	if bgm == "null":
		bgm = Sound.bgm_key
	emit_signal("start_chapter_cover", pov_name, bottom_text, new_background, zoom, bgm)
	return true


func zoom_to(value : float, duration : float) -> bool:
	camera.zoom_to(value, duration)
	return false

func splatter_blood(amount) -> bool:
	for i in int(amount):
		var sprite := preload("res://game/visuals/vfx/splatter/blood_splatter.tscn").instantiate()
		find_child("VFXLayer").add_child(sprite)
	return false

func set_emotion(actor_name: String, emotion_name: String) -> bool:
	for character : Character in get_tree().get_nodes_in_group("character"):
		if character.character_name == actor_name:
			character.set_emotion(emotion_name)
	return false

func show_character(character_name: String, clear_others: bool) -> bool:
	for character : Character in get_tree().get_nodes_in_group("character"):
		if character.character_name == character_name:
			character.visible = true
		elif clear_others:
			character.visible = false
	return false


func shake_camera(strength:float) -> bool:
	camera.apply_shake(strength)
	return false


func set_x_position(character_name: String, index:int, time:float, wait_for_reposition:bool) -> bool:
	if GameWorld.game_stage:
		var character : Character = GameWorld.game_stage.get_character(character_name)
		@warning_ignore("narrowing_conversion")
		character.set_x_position(int(index), time, wait_for_reposition)
	return wait_for_reposition


func sway_camera(intensity : float) -> bool:
	camera.set_sway_intensity(intensity)
	return false

func move_camera_to(x: float, y: float, duration: float) -> bool:
	camera.move_to(x, y, duration)
	return false

func set_eye_progress(value: float) -> bool:
	if GameWorld.game_stage:
		var one = GameWorld.game_stage.get_character("one")
		one.set_eye_progress(int(value))
	return false

func set_static(level : float) -> bool:
	if GameWorld.game_stage:
		GameWorld.game_stage.set_static(level)
	return false

func set_fade_out(lod : float, mix : float) -> bool:
	if GameWorld.game_stage:
		GameWorld.game_stage.set_fade_out(lod, mix)
	return false


func wound_fx(shake_intensity: float, splatter_count: float) -> bool:
	shake_camera(shake_intensity)
	splatter_blood(splatter_count)
	play_sfx("squelch")
	return false

func control_camera(zoom : float, x : float, y : float, duration : float) -> bool:
	zoom_to(zoom, duration)
	move_camera_to(x, y, duration)
	return false

func roll_credits() -> bool:
	find_child("RollingCredits").start()
	return true

func set_character_name(character: String, new_name: String) -> bool:
	if Parser.line_reader:
		Parser.line_reader.set_actor_name(character, new_name)
	return false


func set_object_visible(object_name: String, visibility: bool) -> bool:
	emit_signal("request_object_visible", object_name, visibility)
	return false

func use_ui(id: float) -> bool:
	GameWorld.game_stage.use_ui(int(id))
	return false

func cum(voice: String) -> bool:
	GameWorld.game_stage.cum(voice)
	return false

func set_all_target_labels(target_id:int, force_show := true):
	GameWorld.game_stage.set_all_target_labels(target_id, force_show)

func reset_window_rotations(time:float):
	for window : CustomWindow in find_child("Windows").get_children():
		var window_tween = create_tween()
		window_tween.tween_property(window, "rotation_degrees", 0, randf_range(0.9  * time, time * 1.08))
	var container_tween = create_tween()
	container_tween.tween_property(%DefaultTextContainer, "rotation_degrees", 0, randf_range(0.9  * time, time * 1.08))

func shake_windows(strength:float):
	shake_camera(strength)
	for window : CustomWindow in find_child("Windows").get_children():
		window.rotation_degrees = randf_range(-0.5 * strength, 0.5 * strength)
	%DefaultTextContainer.rotation_degrees = randf_range(-0.5 * strength, 0.5 * strength)
	
func show_image(image:String, viewer:=0, x_min_size := 200, y_min_size := 200, ):
	for child in find_child("Windows").get_children():
		if child is ImageViewerWindow:
			if child.id == 100 + viewer:
				child.show_image(image, x_min_size, y_min_size)

func hide_windows(window_type:String):
	var windows = find_child("Windows").get_children()
	for window : CustomWindow in windows:
		if window is ChatLogWindow and window_type == "text":
			window.hide()
		elif window is ImageViewerWindow and window_type == "image":
			window.hide()
		if window is WaveFormWindow and window_type == "audio":
			window.hide()


const SPLASH_STRINGS := {
	"opening" : "You don't deserve what I'm about to do to you.",
	"yea_right" : "Yeah.\nRight.",
	"killer_hangover" : "Killer hangover.",
	"filthy" : "Filthy.",
	"audrey_lives" : "Audrey lives.",
	"ending" : "An elegy until it's an anthem.",
	"noni_rescue" : "Trauma dump.",
	"pale" : "Pale as a corpse grey morning sky.",
	"vibrant" : "Vibrant as bruises.",
	"one_of_us" : "When you're one of us, making it out of your 20s will be your first and greatest life achievement.",
	"rape_intro" : "[ph]Sometimes, existence hurts.",
	"the_hole" : "The hole.",
	"not_gentle" : "The world is not a gentle place.",
	"bottom_surgery" : "Bottom surgery.",
	"cosmic_sorority" : "Emerging from the waves, a cosmic sorority.",
	"fuck" : "Fuck.",
	"life" : "We're all thieves.",
	"carnage" : "In carnage you will bloom.",
	"quandary_of_thought" : "A quandary of thought.",
	"wakey" : "Wakey wakey.",
	"art" : "The body is a canvas.",
	"keep_the_body" : "Nothing more than a body.",
	"maya_huddles" : "Swallowed by grief.",
	"scars" : "A living being is just a collection of scars.",
	"celestial_bodies" : "Like twin stars.",
	"devour_me" : "Devour me.",
	"eventually" : "Eventually, this will all come crashing down.",
	"funeral" : "Exiled from light.",
}
func splash_text(key:String,
	fade_in := 0.0,
	background:=GameWorld.game_stage.background,
	bgm:=Sound.bgm_key,
	reset_windows := true):
	var black_cover:Control
	#if key == "one_of_us":
		
	if fade_in > 0:
		black_cover = ColorRect.new()
		black_cover.color = Color.BLACK
		black_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
		black_cover.modulate.a = 0
		find_child("VNUI").add_child(black_cover)
		var tween = create_tween()
		tween.tween_property(black_cover, "modulate:a", 1, fade_in)
		tween.finished.connect(splash_text.bind(key, 0, background, bgm, reset_windows))
		tween.finished.connect(black_cover.call_deferred.bind("queue_free"))
		return true
	#if GameWorld.game_stage.devmode_enabled:
		#if reset_windows:
			#hide_all_windows()
			#set_all_target_labels(0)
		#set_background(background, 0)
		#print(SPLASH_STRINGS.get(key))
		#return false
	var cover = preload("res://game/stages/text_reading_cover.tscn").instantiate()
	find_child("VNUICanvasLayer").add_child(cover)
	cover.read(SPLASH_STRINGS.get(key), background, bgm, reset_windows)
	
	GameWorld.game_stage.show_ui()
	
	return true

func set_target_labels(actor:String, target_id:int, force_show:=true):
	GameWorld.game_stage.set_target_labels(actor, target_id, force_show)



func hide_all_windows(reset_to_default:=true):
	GameWorld.game_stage.hide_all_windows(reset_to_default)
func hide_window(id:int):
	GameWorld.game_stage.hide_window(id)
func move_window(id:int, x:int, y:int):
	GameWorld.game_stage.move_window(id, x, y)


func set_up_blank(display_name:String):
	set_actor_name("blank", display_name)

func start_opening_splash():
	%OpeningSplash.start()
	return true

@onready var psychedelics_rect : ColorRect = find_child("PsychedelicsLayer").get_child(0)
var psychedelics_enabled := false
func set_psychedelics(value:bool):
	psychedelics_enabled = value
	var layer : CanvasLayer = find_child("PsychedelicsLayer")
	var color_rect : ColorRect = layer.get_child(0)
	if value:
		layer.visible = value
		color_rect.color.a = 0
		var t = create_tween()
		t.tween_property(color_rect, "color:a", 1, 20)
	else:
		var t = create_tween()
		t.tween_property(color_rect, "color:a", 0, 8)
		t.finished.connect(layer.set.bind("visible", false))

func hide_default_text_container():
	GameWorld.game_stage.hide_default_text_container()


func suicide_visual():
	var layer : CanvasLayer = find_child("Suicide")
	layer.visible = true
	var floaty : ColorRect = layer.find_child("Floaty")
	floaty.color.a = 0
	hide_all_windows(false)
	GameWorld.game_stage.hide_ui()
	var t = create_tween()
	t.tween_property(floaty, "color:a", 1, 10).set_ease(Tween.EASE_OUT_IN)
	t.tween_property(floaty, "color:a", 0, 5).set_delay(5)
	t.finished.connect(layer.set.bind("visible", false))
	t.finished.connect(Parser.function_acceded)
	t.finished.connect(GameWorld.game_stage.show_start_cover)
	
	var p : AudioStreamPlayer = Sound.play_sfx("ocean")
	p.finished.connect(Sound.play_sfx.bind("ocean2"))
	
	return true

func set_up_ending_window_positions():
	move_window(1, 436, 587)
	move_window(2,  31,  84)

func set_up_meltdown_window_positions():
	# magic numbers based on visual
	move_window(8,  44, 169)
	move_window(3, 405, 248)
	move_window(9,  62, 313)
	move_window(5,   2, 564)
	move_window(7, 536, 179)
	
