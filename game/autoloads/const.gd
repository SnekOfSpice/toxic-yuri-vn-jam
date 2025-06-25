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

const MUSIC_ROOT := "res://game/sounds/music/"
const MUSIC_ARGO_DEFAULT := "2025-06-09-tyj_the quite part out loud.mp3"
const MUSIC_AMBIENT_DRONE := "Paradise_Found.mp3"
const MUSIC_BODY_DISCOVERY := "Paradise_Found.mp3"
const MUSIC_CONSENSUAL_HATE_FUCK := "mobygratis head sound inst 82 bpm.mp3"
const MUSIC_CREDITS := "661009__seth_makes_sounds__e-minor-120bpm-dark-edm-song.ogg"
const MUSIC_DEATH_INDUSTRIAL := "Paradise_Found.mp3"
const MUSIC_DEATH_PHILOSOPHY := "Paradise_Found.mp3"
const MUSIC_DICKS := "mobygratis idiots inst mix ab oz.mp3"
const MUSIC_DOLLHOUSE := "Paradise_Found.mp3"
const MUSIC_DRUNK_DRIVING := "Koi-discovery - Shoot-Gun.mp3"
const MUSIC_ENDING := "Demoiselle Döner - Décapitation de l'Hydre Alpha - 09 YM I Y.ogg"
const MUSIC_FUNERAL := "2025-06-24-abschied.mp3"
const MUSIC_GAS_STATION := "Paradise_Found.mp3"
const MUSIC_GLOOM := "CØL - What Makes Me Feel Alive - 01 Gloom.ogg"
const MUSIC_HANGOVER := "mobygratis isolate prior approx 89.mp3"
const MUSIC_HAYA_FALLOUT := "CØL - Crossbones - 03 It Repeats Over and Over.ogg"
const MUSIC_HAYA_TENSION := "Paradise_Found.mp3"
const MUSIC_HOLE := "Paradise_Found.mp3"
const MUSIC_INTRO := "Princess Commodore 64 - XOXO - 02 XOXO.ogg"
const MUSIC_ONE_STEP_TO_SUICIDE := "Paradise_Found.mp3"
const MUSIC_PANIC := "Lonesummer - Satisfaction Feels Like a Tomb - 07 9-25.ogg"
const MUSIC_PUPPY_RESCUE := "Various Artists - CULT TAPE 002 - SELECTED AMBIENT WORKS - 03 Leprosy - ANESTHESIA.ogg"
const MUSIC_RECOVERY := "mobygratis in west inst mix ab oz.mp3"
const MUSIC_MAIN_MENU := "Princess Commodore 64 - XOXO - 06 Flowers From The Midnight Garden.ogg"
const MUSIC_MEETING_AGAIN := "545882__spurioustransients__electric-mandocello-drone-in-gm.ogg"
const MUSIC_NECRO := "Paradise_Found.mp3"
const MUSIC_NIGHTCORE := "Paradise_Found.mp3"
const MUSIC_SHELTER := "Princess Commodore 64 - XOXO - 02 XOXO.ogg"
const MUSIC_SUICIDE_TENSIOM := "Paradise_Found.mp3"
const MUSIC_TATTOO := "Paradise_Found.mp3"
const MUSIC_XELIA := "433801__oymaldonado__guitar-melody.ogg" #https://freesound.org/people/oymaldonado/sounds/433801/ attr
const MUSIC_VARGO_LOVE := "Paradise_Found.mp3"
const MUSIC_VEIN_ACID := "Various Artists - CULT TAPE 002 - SELECTED AMBIENT WORKS - 06 Lorenzi - Elphael.ogg"

const SFX_ROOT := "res://game/sounds/sfx/"
const SFX_CLICK := "637345__kyles__camera-toy-single-shot-nice-stereo.ogg"
const SFX_SHUTTER := "579882__yfjesse__polaroid-one-step-camera-shutter.ogg"
const SFX_HOVER := "720828__riley_garinger__metlfric-circular-saw-blade-scrape-on-concrete_01_single-fast_rg_2023_ntg4-2.ogg" # attr
const SFX_CLICKER := "clicker.ogg"
const SFX_RISER := "376574__original_sound__riser-quick-1-longer.ogg" # https://freesound.org/people/original_sound/sounds/376574/ attr

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
