extends Node

const STAGE_ROOT := "res://game/stages/"
const STAGE_MAIN := "main_menu_stage.tscn"
const STAGE_GAME := "game_stage.tscn"

const SCREEN_ROOT := "res://game/screens/"
const SCREEN_CONTENT_WARNING := "cw.tscn"
const SCREEN_CREDITS := "credits.tscn"
const SCREEN_HISTORY := "history.tscn"
const SCREEN_NOTICE := "notice.tscn"
const SCREEN_OPTIONS := "options_screen.tscn"
const SCREEN_SAVE := "save_screen.tscn"

const CG_ROOT := "res://game/cg/"

const BACKGROUND_ROOT := "res://game/backgrounds/"
const BACKGROUND_ARGO_APARTMENT := "void.png"
const BACKGROUND_RECOVERY_CENTER := "void.png"

const MUSIC_ROOT := "res://game/sounds/music/"
const MUSIC_ARGO_DEFAULT := "2025-06-09-tyj_the quite part out loud.mp3"
const MUSIC_CONSENSUAL_HATE_FUCK := "Paradise_Found.mp3"
const MUSIC_DICKS := "Paradise_Found.mp3"
const MUSIC_DOLLHOUSE := "Paradise_Found.mp3"
const MUSIC_DRUNK_DRIVING := "Paradise_Found.mp3"
const MUSIC_GAS_STATION := "Paradise_Found.mp3"
const MUSIC_HANGOVER := "Paradise_Found.mp3"
const MUSIC_HAYA_FALLOUT := "CØL - Crossbones - 03 It Repeats Over and Over.ogg"
const MUSIC_HOLE := "Paradise_Found.mp3"
const MUSIC_INTRO := "Paradise_Found.mp3"
const MUSIC_RECOVERY := "Paradise_Found.mp3"
const MUSIC_MAIN_MENU := "Paradise_Found.mp3"
const MUSIC_MEETING_AGAIN := "Paradise_Found.mp3"
const MUSIC_NIGHTCORE := "Paradise_Found.mp3"
const MUSIC_SHELTER := "Paradise_Found.mp3"
const MUSIC_VEIN_ACID := "Paradise_Found.mp3"

const SFX_ROOT := "res://game/sounds/sfx/"
const SFX_CLICK := "637345__kyles__camera-toy-single-shot-nice-stereo.ogg"
const SFX_SHUTTER := "579882__yfjesse__polaroid-one-step-camera-shutter.ogg"

func fetch(type:String, key:String) -> String:
	type = type.to_upper()
	var root = get(str(type, "_ROOT"))
	var property := str(type, "_", key.to_upper())
	if get(property):
		return str(root, get(property))
	var extensions : Array
	if type == "MUSIC" or type == "SFX":
		extensions = ["mp3", "wav", "ogg"]
	elif type == "BACKGROUND" or type == "CG":
		extensions = ["tscn", "png", "jpg"]
	elif type == "SCREEN" or type == "STAGE":
		extensions = ["tscn"]
	for extension in extensions:
		var path := str(root, key, ".", extension)
		if ResourceLoader.exists(path):
			return path
	push_error(str("Couldn't fetch ", key, " in ", type))
	return ""
