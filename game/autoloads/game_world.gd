extends Node


var stage_root: StageRoot
var game_stage: GameStage

var camera : GameCamera

var background := ""

var skip := false
var just_started := true

var hidden_ui_reset_target_override := -1

# function called by splash text and black fade etc. clean up the ui back to its default state
func hidden_ui_reset():
	if not game_stage:
		return
	game_stage.set_fade_out(0, 0)
	game_stage.hide_cg()
	game_stage.clear_text_bodies()
	game_stage.hide_all_windows()
	if hidden_ui_reset_target_override != -1:
		game_stage.set_all_target_labels(hidden_ui_reset_target_override, false)
		game_stage.set_target_labels("narrator", hidden_ui_reset_target_override, false)
		hidden_ui_reset_target_override = -1
	game_stage.hide_default_text_container()
	GameWorld.camera.zoom_to(1, 0)
	Parser.line_reader.shake_windows(0)

func str_to_vec2(s) -> Vector2:
	if s is Vector2:
		return s
	if not s is String:
		return Vector2.ZERO
	s = s.replace("(", "")
	s = s.replace(")", "")
	
	var segments = s.split(",")
	
	return Vector2(float(segments[0]), float(segments[1]))

func serialize():
	var result := {}
	result["background"] = background
	result["game_stage"] = game_stage.serialize()
	return result

func deserialize(data:Dictionary):
	if game_stage:
		game_stage.set_background(data.get("background", ""))
		game_stage.deserialize(data.get("game_stage", {}))
	else:
		print("game stage not set for gameworld deserialization")

func hide_all_characters():
	for character : Character in get_tree().get_nodes_in_group("character"):
		character.set_invisible()

func set_enable_dither(value:bool):
	stage_root.get_stage_node().set_enable_dither(value)
