extends Control
class_name StageRoot

var stage := ""
var screen := ""

@export_group("Screen Fade", "screen_fade_")
@export_exp_easing("positive_only") var screen_fade_in := 1.0
@export_exp_easing("positive_only") var screen_fade_out := 0.5

var screenshot_to_save:Image

func _ready():
	change_stage(CONST.STAGE_GAME)
	set_screen("")
	GameWorld.stage_root = self

func set_screen(screen_path:String, payload := {}):
	if is_instance_valid(Parser.line_reader):
		if Parser.line_reader.is_executing:
			return
	
	if stage == CONST.STAGE_GAME:
		screenshot_to_save = get_viewport().get_texture().get_image()
		var s = Options.get_save_thumbnail_size()
		screenshot_to_save.resize(s.x, s.y)
	
	var screen_container:Control
	if (null if not is_instance_valid(GameWorld.camera) else GameWorld.camera) is GameCamera:
		screen_container = GameWorld.camera.get_screen_container()
	else:
		screen_container = find_child("ScreenContainer")
	
	if screen_path.is_empty():
		if screen_fade_out == 0 or screen_container.get_child_count() == 0:
			for c in screen_container.get_children():
				c.queue_free()
			screen_container.visible = false
		else:
			var tween
			for c in screen_container.get_children():
				var t = create_tween()
				t.tween_property(c, "modulate:a", 0, screen_fade_out)
				t.set_ease(Tween.EASE_OUT_IN)
				t.finished.connect(c.queue_free)
				tween = t
			tween.finished.connect(screen_container.set_visible.bind(false))
		screen = screen_path
		return
	var new_screen = load(str(CONST.SCREEN_ROOT, screen_path)).instantiate()
	
	match screen_path:
		CONST.SCREEN_NOTICE:
			new_screen.handle_payload(payload)
	
	if screen_fade_in > 0:
		new_screen.modulate.a = 0
	screen_container.add_child(new_screen)
	if screen_fade_in > 0:
		var t = create_tween()
		t.tween_property(new_screen, "modulate:a", 1, screen_fade_in)
		t.set_ease(Tween.EASE_OUT_IN)
	screen_container.visible = true
	screen = screen_path


func new_gamestate():
	game_start_callable = Parser.reset_and_start
	change_stage(CONST.STAGE_GAME)


func load_gamestate():
	game_start_callable = Options.load_gamestate
	change_stage(CONST.STAGE_GAME)

func start_epilogue():
	game_start_callable = Parser.read_page_by_key.bind("epilogue")
	change_stage(CONST.STAGE_GAME)

var game_start_callable:Callable
func change_stage(stage_path:String):
	await get_tree().process_frame
	
	set_screen("")
	var new_stage = load(str(CONST.STAGE_ROOT, stage_path)).instantiate()
	
	if stage_path == CONST.STAGE_GAME:
		new_stage.callable_upon_blocker_clear = game_start_callable
	
	for child in $StageContainer.get_children():
		if new_stage != child:
			child.queue_free()
	
	
	match stage_path:
		CONST.STAGE_MAIN:
			new_stage.start_game.connect(new_gamestate)
			new_stage.load_game.connect(load_gamestate)
			new_stage.start_epilogue.connect(start_epilogue)
		#CONST.STAGE_GAME:
			#new_stage.blockers_cleared.connect(game_start_callable)
	
	$StageContainer.add_child(new_stage)
	
	stage = stage_path

func get_stage_node() -> Node:
	return $StageContainer.get_child(0)
	
