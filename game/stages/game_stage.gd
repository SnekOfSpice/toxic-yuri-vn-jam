extends Stage
class_name GameStage

@onready var characters := {}

var background : String = ""

@export_group("Devmode", "devmode_")
@export var devmode_enabled := false
@export var devmode_start_page := 0
@export var devmode_start_line := 0
@export var stylebox_regular : StyleBox
@export var stylebox_cg : StyleBox

@onready var line_reader : LineReader = find_child("LineReader")

var dialog_box_tween : Tween
var dialog_box_offset := Vector2.ZERO
var actor_name := ""
var cg := ""
var cg_position := ""
var base_cg_offset : Vector2
var is_name_container_visible := false

@onready var cg_roots := [find_child("CGBottomContainer"), find_child("CGTopContainer")]

var callable_upon_blocker_clear:Callable
var meta_blocker := false
var screen_close_blocker := false
@onready var camera = %Camera2D
@onready var overlay_fade_out = find_child("FadeOut").get_node("ColorRect")
@onready var overlay_orgasm = find_child("Orgasm").get_node("ColorRect")


@onready var orgasm_mat = overlay_orgasm.get_material()
@onready var fade_mat = overlay_fade_out.get_material()

var target_lod := 0.0
var target_mix := 0.0

@onready var windows : Array = find_child("Windows").get_children()
var last_body_label_target := 0
var target_label_id_by_actor := {}

func get_default_targets() -> Dictionary:
	var result := {}
	for actor in line_reader.name_map.keys():
		result[actor] = 0
	return result

func _ready():
	if Parser.page_index == 0 and line_reader.line_index == 0:
		hide_ui()
	if devmode_enabled:
		Sound.play_bgm("argo_default")
	else:
		set_background("black")
	find_child("Portrait").visible = false
	find_child("CreditsLayer").visible = false
	find_child("BlackLayer").visible = true
	find_child("Suicide").visible = false
	find_child("PsychedelicsLayer").visible = false
	find_child("DevModeLabel").visible = devmode_enabled
	target_label_id_by_actor = get_default_targets()
	#GoBackHandler.store_into_subaddress(get_default_targets(), targets_by_subaddress, "0.0.0")
	find_child("StartCover").visible = true
	ParserEvents.actor_name_changed.connect(on_actor_name_changed)
	ParserEvents.actor_name_about_to_change.connect(on_actor_name_about_to_change)
	ParserEvents.page_terminated.connect(go_to_main_menu)
	ParserEvents.instruction_started.connect(on_instruction_started)
	#ParserEvents.instruction_completed.connect(on_instruction_completed)
	ParserEvents.read_new_line.connect(on_read_new_line)
	ParserEvents.dialog_line_args_passed.connect(on_dialog_line_args_passed)
	#ParserEvents.go_back_accepted.connect(on_go_back_accepted)
	#ParserEvents.start_new_dialine.connect(on_start_new_dialine)
	
	GameWorld.game_stage = self
	
	line_reader.auto_continue = Options.auto_continue
	line_reader.text_speed = Options.text_speed
	line_reader.auto_continue_delay = Options.auto_continue_delay
	
	for character in find_child("Characters").get_children():
		character.visible = false
	
	grab_focus()
	
	tree_exiting.connect(on_tree_exit)
	
	hide_cg()
	
	await get_tree().process_frame
	if callable_upon_blocker_clear:
		callable_upon_blocker_clear.call()
	else:
		if devmode_enabled:
			Parser.reset_and_start(devmode_start_page, devmode_start_line)
		else:
			Parser.reset_and_start()
	
	await get_tree().process_frame
	find_child("StartCover").visible = false
	set_enable_dither(Options.enable_dither)

func set_enable_dither(value:bool):
	
	find_child("DitherLayer").visible = value
	find_child("DitherLayer2").visible = value
	find_child("DitherColorCorrection").visible = value


#var targets_by_subaddress := {}
##var window_visibilities_by_subaddress := {}
#func on_go_back_accepted(page:int, line:int, dialine:int):
	#var targets = GoBackHandler.fetch_prev_from_subaddress(targets_by_subaddress, page, line, dialine)
	#for actor in targets.keys():
		#set_target_labels(actor, targets.get(actor), false)


func get_window_visibilities() -> Dictionary:
	var result := {}
	for window : CustomWindow in windows:
		result[window.uid] = window.visible
	return result

func on_read_new_line(line_index:int):
	pass

func on_tree_exit():
	GameWorld.game_stage = null

func on_instruction_started(
	instruction_text : String,
	_delay : float,
):
	find_child("StartCover").visible = false

func show_start_cover():
	find_child("StartCover").visible = true

func go_to_main_menu(_unused):
	GameWorld.stage_root.change_stage(CONST.STAGE_MAIN)


func _process(_delta: float) -> void:
	fade_mat.set_shader_parameter("lod", lerp(fade_mat.get_shader_parameter("lod"), target_lod, 0.02))
	fade_mat.set_shader_parameter("mix_percentage", lerp(fade_mat.get_shader_parameter("mix_percentage"), target_mix, 0.02))
	
	
	orgasm_mat.set_shader_parameter("lod", lerp(orgasm_mat.get_shader_parameter("lod"), 0.0, 0.000175))
	
	find_child("VFXLayer").position = -camera.offset * camera.zoom.x

func cum(_voice:String):
	orgasm_mat.set_shader_parameter("lod", 1.8)
	
	get_tree().create_timer(1.5).timeout.connect(orgasm_mat.set_shader_parameter.bind("lod", 1.4))

func _unhandled_input(event: InputEvent) -> void:
	if not GameWorld.stage_root.screen.is_empty():
		return
	if event is InputEventKey:
		if event.pressed:
			if InputMap.action_has_event("ui_cancel", event):
				GameWorld.stage_root.set_screen(CONST.SCREEN_OPTIONS)
			if InputMap.action_has_event("screenshot", event):
				var screenshot := get_viewport().get_texture().get_image()
				var path := str("user://screenshot_", ProjectSettings.get_setting("application/config/name").replace("://", " "), "_", Time.get_datetime_string_from_system().replace(":", "-"), ".png")
				screenshot.save_png(path)
				
				var notification_popup = preload("res://game/systems/notification.tscn").instantiate()
				var global_path := ProjectSettings.globalize_path(path)
				var global_dir := global_path.substr(0, global_path.rfind("/"))
				find_child("VNUIRoot").add_child(notification_popup)
				notification_popup.init(str("Saved to [url=", global_dir, "]", global_path, "[/url]"))
			if InputMap.action_has_event("toggle_auto_continue", event):
				line_reader.auto_continue = not line_reader.auto_continue
				Options.auto_continue = line_reader.auto_continue
				Options.save_prefs()
			if InputMap.action_has_event("toggle_ui", event):
				if find_child("VNUI").visible:
					hide_ui()
				else:
					show_ui()
			if InputMap.action_has_event("cheats", event) and OS.has_feature("editor"):
				find_child("Cheats").visible = not find_child("Cheats").visible
				
	if event is InputEventMouse:
		if event.is_pressed() and InputMap.action_has_event("ui_cancel", event):
			GameWorld.stage_root.set_screen(CONST.SCREEN_OPTIONS)

	if event.is_action_released("advance"):
		if screen_close_blocker:
			screen_close_blocker = false
			return
		if meta_blocker:
			return
		for root in cg_roots:
			if root.visible and emit_insutrction_complete_on_cg_hide:
				hide_cg()
				return
		if not find_child("VNUI").visible:
			return
		line_reader.request_advance()
	if event.is_action_pressed("history"):
		if GameWorld.stage_root.screen == CONST.SCREEN_HISTORY:
			GameWorld.stage_root.set_screen("")
		else:
			GameWorld.stage_root.set_screen(CONST.SCREEN_HISTORY)
		
	#elif event.is_action_pressed("go_back"):
		#line_reader.request_go_back()

func show_ui():
	if is_instance_valid(find_child("VNUI")):
		find_child("VNUI").visible = true

func hide_ui():
	find_child("VNUI").visible = false

func set_cg(cg_name:String, fade_in_duration:float, cg_root:Control):
	#if stylebox_cg:
		#var ui1panel : PanelContainer = find_child("TextContainer1").find_child("Panel")
		#ui1panel.add_theme_stylebox_override("panel", stylebox_cg)
	
	cg_root.modulate.a = 0.0 if cg_root.get_child_count() == 0 else 1.0
	cg_root.visible = true
	
	var cg_path := CONST.fetch("CG", cg_name)
	var cg_node : Control
	
	if cg_path.is_empty():
		push_warning(str("Couldn't find CG \"", cg_name, "\"."))
		return
	if cg_path.ends_with(".tscn"):
		cg_node = load(cg_path).instantiate()
	else:
		#if cg_root
		#cg_node = ColorRect.new()
		#cg_node.set_anchors_preset(Control.PRESET_FULL_RECT)
		#cg_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#cg_node.color = Color.BLACK
		cg_node = TextureRect.new()
		#cg_node.add_child(tex)
		cg_node.position -=  Vector2(1000, 750) * 0.7 * 0.5
		cg_node.position.y += 54#  Vector2(1000, 750) * 0.7 * 0.5
		cg_node.set_anchors_preset(Control.PRESET_CENTER)
		cg_node.texture = load(cg_path)
		cg_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		cg_node.custom_minimum_size = Vector2(1000, 750) * 0.7
	
	cg_root.add_child(cg_node)
	
	var t = create_tween()
	
	if cg_root.modulate.a == 1.0:
		cg_node.modulate.a = 0.0
		t.tween_property(cg_node, "modulate:a", 1.0, fade_in_duration)
	else:
		t.tween_property(cg_root, "modulate:a", 1.0, fade_in_duration)
	
	
	var background_size : Vector2
	if cg_node is TextureRect:
		background_size = cg_node.texture.get_size()
	else:
		background_size = cg_node.size
	var overshoot = background_size - Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	var container = cg_node.get_parent() # might be top or bottom
	container.position = Vector2.ZERO
	if overshoot.x > 0:
		container.position.x = - overshoot.x * 0.5
	if overshoot.y > 0:
		container.position.y = - overshoot.y * 0.5
	base_cg_offset = container.position
	
	cg = cg_name

func set_cg_top(cg_name:String, fade_in_duration:float):
	cg_position = "top"
	set_cg(cg_name, fade_in_duration, find_child("CGTopContainer"))

func set_cg_bottom(cg_name:String, fade_in_duration:float):
	cg_position = "bottom"
	set_cg(cg_name, fade_in_duration, find_child("CGBottomContainer"))

func set_cg_offset(offset:Vector2):
	find_child("CGTopContainer").position = offset + base_cg_offset
	find_child("CGBottomContainer").position = offset + base_cg_offset


func hide_cg(fade_out := 0.0):
	cg = ""
	cg_position = ""
	if fade_out == 0.0:
		_clear_cg()
		return
	var t = create_tween()
	t.set_parallel()
	for cg_root : Control in cg_roots:
		t.tween_property(cg_root, "modulate:a", 0, fade_out)
	t.finished.connect(_clear_cg)
	
func _clear_cg():
	for cg_root : Control in cg_roots:
		cg_root.visible = false
		for c in cg_root.get_children():
			c.queue_free()
		#cg_root.modulate.a = 0.0
		if emit_insutrction_complete_on_cg_hide:
			Parser.function_acceded()
			emit_insutrction_complete_on_cg_hide = false
	
	#if stylebox_regular:
		#var ui1panel : PanelContainer = find_child("TextContainer1").find_child("Panel")
		#ui1panel.add_theme_stylebox_override("panel", stylebox_regular)
	

func on_actor_name_changed(
	actor: String,
	name_container_visible: bool
	):
		actor_name = actor
		is_name_container_visible = name_container_visible
		if actor_name.is_empty():
			actor_name = "narrator"
		var target_id : int = target_label_id_by_actor.get(actor, 0)
		if target_id == 6:
			find_child("Portrait").visible = false
			return
		if actor_name in Parser.line_reader.blank_names:
			if target_id == 0:
				find_child("Portrait").visible = false
				find_child("Portrait").texture = load("res://game/characters/portraits/none.png")
			else:
				get_chatlog_window(target_id).set_portrait("")
		else:
			if target_id == 0:
				find_child("Portrait").visible = true
				find_child("Portrait").texture = load("res://game/characters/portraits/%s.png" % actor_name)
			else:
				get_chatlog_window(target_id).set_portrait(actor_name)

func on_actor_name_about_to_change(actor:String):
	if block_about_new_actor_handling:
		block_about_new_actor_handling = false
		return
	set_target_labels(actor, target_label_id_by_actor.get(actor, 0))



func set_callable_upon_blocker_clear(callable:Callable):
	callable_upon_blocker_clear = callable

func serialize() -> Dictionary:
	var result := {}
	
	var character_data := {}
	for character : Character in find_child("Characters").get_children():
		character_data[character.character_name] = character.serialize()
	
	result["character_data"] = character_data
	result["cg"] = cg
	result["cg_position"] = cg_position
	result["base_cg_offset"] = base_cg_offset
	result["background"] = background
	result["objects"] = %Objects.serialize()
	
	result["start_cover_visible"] = find_child("StartCover").visible
	result["fade_out_lod"] = overlay_fade_out.get_material().get_shader_parameter("lod")
	result["fade_out_mix_percentage"] = overlay_fade_out.get_material().get_shader_parameter("mix_percentage")
	
	result["camera"] = %Camera2D.serialize()
	result["target_label_id_by_actor"] = target_label_id_by_actor
	result["last_body_label_target"] = last_body_label_target
	result["psychedelics"] = line_reader.psychedelics_enabled
	result["portrait_visible"] = find_child("Portrait").visible
	
	#result["window_visibilities_by_subaddress"] = window_visibilities_by_subaddress
	#result["target_label_history_by_subaddress"] = target_label_history_by_subaddress
	result["are_words_being_spoken"] = are_words_being_spoken
	
	var window_data_by_uid := {}
	for window : CustomWindow in windows:
		var data := window.serialize()
		window_data_by_uid[int(data.get("uid"))] = data
	result["windows"] = window_data_by_uid
	result["text_content_default"] = serialize_text_content(%DefaultTextContainer)
	result["text_content_full"] = serialize_text_content(%FullCoverText)
	
	return result

func serialize_text_content(root:Control) -> Dictionary:
	var result := {}
	result["root_visible"] = root.visible
	result["rotation_degrees"] = root.rotation_degrees
	result["body_text"] = root.find_child("BodyLabel").text
	result["visible_characters"] = root.find_child("BodyLabel").visible_characters
	return result
func deserialize_text_content(root:Control, data:Dictionary) -> void:
	root.visible = data.get("root_visible", false)
	root.rotation_degrees = data.get("rotation_degrees", 0)
	root.find_child("BodyLabel").text = data.get("body_text", "")
	root.find_child("BodyLabel").visible_characters = data.get("visible_characters", -1)

func deserialize(data:Dictionary):
	var character_data : Dictionary = data.get("character_data", {})
	for character : Character in find_child("Characters").get_children():
		character.deserialize(character_data.get(character.character_name, {}))
	
	%Objects.deserialize(data.get("objects", {}))
	%Camera2D.deserialize(data.get("camera", {}))
	
	var cg_name : String = data.get("cg", "")
	if cg_name.is_empty():
		hide_cg()
	else:
		if data.get("cg_position", "") == "top":
			set_cg_top(cg_name, 0.0)
		elif data.get("cg_position", "") == "bottom":
			set_cg_bottom(cg_name, 0.0)
		else:
			push_warning("cg_position isn't top or bottom")
			hide_cg()
	
	find_child("StartCover").visible = data.get("start_cover_visible", false)
	
	target_lod = data.get("fade_out_lod", 0.0)
	target_mix = data.get("fade_out_mix_percentage", 0.0)
	overlay_fade_out.get_material().set_shader_parameter("lod", target_lod)
	overlay_fade_out.get_material().set_shader_parameter("mix_percentage", target_mix)
	
	
	base_cg_offset = GameWorld.str_to_vec2(data.get("base_cg_offset", Vector2.ZERO))
	target_label_id_by_actor = data.get("target_label_id_by_actor", {})
	for actor in target_label_id_by_actor.keys():
		set_target_labels(actor, target_label_id_by_actor.get(actor), false)
	
	#window_visibilities_by_subaddress = data.get("window_visibilities_by_subaddress", {})
	#targets_by_subaddress = data.get("targets_by_subaddress", get_ready_targets_by_subaddress())
	are_words_being_spoken = data.get("are_words_being_spoken", are_words_being_spoken)
	
	set_background(data.get("background"))
	find_child("PsychedelicsLayer").visible = data.get("psychedelics", false)
	
	# windows
	var window_data : Dictionary = data.get("windows", {})
	var windows_by_index := {}
	for window : CustomWindow in windows:
		var local_window_data : Dictionary = window_data.get(str(window.uid), {})
		window.deserialize(local_window_data)
		windows_by_index[local_window_data.get("index", windows_by_index.size())] = window
	%LineReader.body_label = get_body_label(data.get("last_body_label_target", 0))
	
	var sorted_indices := windows_by_index.keys().duplicate()
	sorted_indices.sort()
	for index in sorted_indices:
		windows_by_index.get(index).move_to_top(false)
	find_child("Portrait").visible = data.get("portrait_visible", false)
	
	deserialize_text_content(%DefaultTextContainer, data.get("text_content_default", {}))
	deserialize_text_content(%FullCoverText, data.get("text_content_full", {}))
	show_ui()

var emit_insutrction_complete_on_cg_hide :bool

func get_character(character_name:String) -> Character:
	for child : Character in %Characters.get_children():
		if child.character_name == character_name:
			return child
	return null

func _on_history_button_pressed() -> void:
	GameWorld.stage_root.set_screen(CONST.SCREEN_HISTORY)

func show_letter():
	hide_ui()
	var letter = preload("res://game/objects/letter.tscn").instantiate()
	add_child(letter)
	letter.position = Vector2(258, 8)

func _on_handler_start_show_cg(cg_name: String, fade_in: float, on_top: bool) -> void:
	if on_top:
		emit_insutrction_complete_on_cg_hide = true
		set_cg_top(cg_name, fade_in)
	else:
		#var t = get_tree().create_timer(fade_in)
		#t.timeout.connect(Parser.function_acceded)
		set_cg_bottom(cg_name, fade_in)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_menu_button_pressed() -> void:
	GameWorld.stage_root.set_screen(CONST.SCREEN_OPTIONS)

func _on_chapter_cover_chapter_intro_finished() -> void:
	Parser.function_acceded()
	find_child("ChapterCover").visible = false



func set_fade_out(lod:float, mix:float):
	target_lod = lod
	target_mix = mix

func get_chatlog_window(id:int) -> ChatLogWindow:
	var vnui : Control = find_child("VNUI")
	var window : ChatLogWindow = vnui.find_child("ChatLogWindow%s"%id)
	return window

func get_body_label(target_id:int):
	if target_id == 0:
		return%DefaultTextContainer.find_child("BodyLabel")
	else:
		return get_chatlog_window(target_id).get_body_label()

func hide_default_text_container():
	%DefaultTextContainer.visible = false
var are_words_being_spoken := true
func set_target_labels(actor:String, target_id:int, force_show:=true, as_voice_message:=false):
	#print("as voice ", as_voice_message)
	#GoBackHandler.store_into_subaddress(target_label_id_by_actor.duplicate(),
		#targets_by_subaddress, Parser.line_reader.get_subaddress())
	target_label_id_by_actor[actor] = target_id
	var is_texting := target_id in [3,5,7,8,9]
	var is_digital := target_id in [3,4,5,7,8,9]
	are_words_being_spoken = not is_texting
	if target_id == 6:
		hide_all_windows(false)
		%DefaultTextContainer.visible = false
		%FullCoverText.visible = true
	else:
		%FullCoverText.visible = false
		
	%LineReader.body_label_tint_lines = false
	if target_id == 0:
		%DefaultTextContainer.visible = true
		%LineReader.custom_text_speed_override = -1
		%LineReader.text_container = %DefaultTextContainer
		%LineReader.set_body_label(%DefaultTextContainer.find_child("BodyLabel"), false)
		var name_label = %DefaultTextContainer.find_child("NameLabel")
		var name_container = %DefaultTextContainer.find_child("NameContainer")
		%LineReader.set_name_controls(name_label, name_container)
		%LineReader.custom_text_speed_override = -1
		%LineReader.body_label_prefix = ""
		%LineReader.body_label_suffix = ""
		%LineReader.keep_past_lines = false
	elif target_id == 6:
		%LineReader.text_container = %FullCoverText
		%LineReader.custom_text_speed_override = -1
		%LineReader.set_body_label(%FullCoverText.find_child("BodyLabel"), false)
		var name_label = %FullCoverText.find_child("NameLabel")
		var name_container = %FullCoverText.find_child("NameLabel")
		%LineReader.set_name_controls(name_label, name_container)
		%LineReader.custom_text_speed_override = -1
		%LineReader.body_label_prefix = ""
		%LineReader.body_label_suffix = ""
		%LineReader.keep_past_lines = false
	else:
		var vnui : Control = find_child("VNUI")
		#if last_body_label_target in [3,4,5]:
			#var ui_fix_window : ChatLogWindow = vnui.find_child("ChatLogWindow%s"%last_body_label_target)
			#ui_fix_window.get_text_container().visible = true
		var window : ChatLogWindow = vnui.find_child("ChatLogWindow%s"%target_id)
		%LineReader.set_body_label(window.get_body_label(), false)
		%LineReader.set_name_controls(window.get_name_label(), window.get_name_container())
		%LineReader.text_container = window.get_text_container()
		if is_texting:
			%LineReader.custom_text_speed_override = 201
			%LineReader.body_label_prefix = "[code]"
			%LineReader.body_label_suffix = "[/code]"
			if last_body_label_target != target_id and not window.visible:
				window.clear_past_container()
			%LineReader.enable_keep_past_lines(
				window.get_past_container()
			)
			if as_voice_message:
				%LineReader.custom_text_speed_override = -1
				#window.get_body_label().text = str("[color=#%s]" , window.get_body_label().text, "[/color]") % %LineReader._get_actor_color(actor_name).to_html()
				%LineReader.body_label_tint_lines = true
				await get_tree().process_frame
				window.build_waveform()
				
				 # builds from its current text and displays it
			else:
				window.hide_waveform()
		else:
			%LineReader.custom_text_speed_override = -1
			%LineReader.body_label_prefix = ""
			%LineReader.body_label_suffix = ""
			%LineReader.keep_past_lines = false
		if force_show:
			window.move_to_top()
			window.open_if_closed()

	last_body_label_target = target_id

var block_about_new_actor_handling := false
func on_dialog_line_args_passed(
	actor: String,
	dialog_line_args: Dictionary):
		block_about_new_actor_handling = true
		set_target_labels(actor, int(dialog_line_args.get("target", target_label_id_by_actor.get(actor))), true, dialog_line_args.has("is_voice"))

func hide_all_windows(reset_to_default:=true):
	for window : CustomWindow in windows:
		if window is WaveFormWindow:
			continue
		window.hide()
	if reset_to_default:
		set_all_target_labels(0, false)

func set_all_target_labels(target_id:int, force_show := true):
	for actor in target_label_id_by_actor.keys():
		set_target_labels(actor, target_id, force_show)

func set_background(new_bg_key:String, fade_time:=0.0):
	if new_bg_key == "none" or new_bg_key == "null" or new_bg_key.is_empty():
		new_bg_key = GameWorld.background
	var path = CONST.fetch("BACKGROUND", new_bg_key)
	if not path:
		push_warning(str("COULDN'T FIND BACKGROUND ", new_bg_key, "!"))
		return
	var new_background:Node2D
	var old_backgrounds:=%Background.get_children()
	if path.ends_with(".png") or path.ends_with(".jpg") or path.ends_with(".jpeg"):
		new_background = Sprite2D.new()
		new_background.texture = load(path)
		
		new_background.centered = false
	
	elif path.ends_with(".tscn"):
		new_background = load(path).instantiate()
	else:
		push_error(str("Background ", new_bg_key, " does not end in .png, .jpg, .jpeg or .tscn."))
		return
	
	%Background.add_child(new_background)
	%Background.move_child(new_background, 0)
	
	var background_size := Vector2.ZERO
	if new_background is Sprite2D:
		background_size = new_background.texture.get_size()
	elif new_background.has_method("get_size"):
		background_size = new_background.get_size()
	
	var overshoot = background_size - Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	if overshoot.x > 0:
		new_background.position.x = - overshoot.x * 0.5
	if overshoot.y > 0:
		new_background.position.y = - overshoot.y * 0.5
	
	
	for old_node : Node in old_backgrounds:
		var fade_tween := get_tree().create_tween()
		fade_tween.tween_property(old_node, "modulate:a", 0.0, fade_time)
		fade_tween.finished.connect(old_node.queue_free)
	
	GameWorld.background = new_bg_key
	
	#if is_instance_valid(GameWorld.game_stage):
		#GameWorld.game_stage.get_node("Objects").hide_all()
		
func hide_window(id:int):
	for window : CustomWindow in windows:
		if window.id == id:
			window.hide()
			return
		
func move_window(id:int, x:int, y:int):
	for window : CustomWindow in windows:
		if window.id == id:
			window.position = Vector2(x, y)
			window.clamp_to_viewport()
			return


func clear_text_bodies():
	%DefaultTextContainer.find_child("BodyLabel").text = ""
	%FullCoverText.find_child("BodyLabel").text = ""
	for window : CustomWindow in windows:
		if window is ChatLogWindow:
			window.get_body_label().text = ""


var control_tween
func _on_line_reader_start_accepting_advance() -> void:
	if control_tween:
		control_tween.kill()
	var controls : Control = find_child("ControlsContainer")
	control_tween = create_tween()
	control_tween.tween_property(controls, "modulate:a", 1, 1)
	
	Options.save_gamestate()


func _on_line_reader_stop_accepting_advance() -> void:
	if control_tween:
		control_tween.kill()
	var controls : Control = find_child("ControlsContainer")
	control_tween = create_tween()
	control_tween.tween_property(controls, "modulate:a", 0, 1)


func is_window_overlapping(window_to_check:CustomWindow):
	var rect_a = Rect2(window_to_check.position, window_to_check.size)
	for window : CustomWindow in windows:
		if not window.visible:
			continue
		if window == window_to_check:
			continue
		var rect_b = Rect2(window.position, window.size)
		var rect_a_x1 = rect_a.position.x
		var rect_a_x2 = rect_a.position.x + rect_a.size.x
		var rect_b_x1 = rect_b.position.x
		var rect_b_x2 = rect_b.position.x + rect_b.size.x
		var rect_a_y1 = rect_a.position.y
		var rect_a_y2 = rect_a.position.y + rect_a.size.y
		var rect_b_y1 = rect_b.position.y
		var rect_b_y2 = rect_b.position.y + rect_b.size.y
		
		if not (rect_a_x1 > rect_b_x2 or rect_a_x2 < rect_b_x1 or rect_a_y1 > rect_b_y2 or rect_a_y2 < rect_b_y1):
			return true
	return false

func get_screen_container() -> Control:
	return find_child("ScreenContainer")
