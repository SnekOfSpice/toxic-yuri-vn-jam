extends Node


var states_by_page := {}

func _ready() -> void:
	ParserEvents.go_back_accepted.connect(on_go_back_accepted)
	ParserEvents.read_new_line.connect(on_read_new_line)

func on_read_new_line(line:int):
	line -= 1
	# save the state
	var state := {}
	
	var characters := {}
	for character : Character in get_tree().get_nodes_in_group("character"):
		characters[character.character_name] = character.serialize()
	#state["characters"] = characters
	state["background"] = GameWorld.background
	state["bgm"] = Sound.bgm_key
	if is_instance_valid(GameWorld.game_stage):
		state["game_stage"] = GameWorld.game_stage.serialize()
	
	if states_by_page.has(Parser.page_index):
		states_by_page[Parser.page_index][line] = state
	else:
		states_by_page[Parser.page_index] = {line : state}

func on_go_back_accepted(page:int, line:int, _a):
	if not states_by_page.has(page):
		return
	if not states_by_page[page].has(line):
		return
	
	# handle payload
	var state : Dictionary = states_by_page[page][line]
	#var characters : Dictionary = state.get("characters", {})
	#for character : Character in get_tree().get_nodes_in_group("character"):
		#character.deserialize(characters.get(character.character_name, {}))
	
	
	if is_instance_valid(GameWorld.game_stage):
		GameWorld.game_stage.deserialize(state.get("game_stage", {}))

	Sound.play_bgm(state.get("bgm", Sound.bgm_key))

func serialize() -> Dictionary:
	return {"states_by_page" : states_by_page}

func deserialize(data: Dictionary):
	states_by_page = data.get("states_by_page", {})


## default is at 0.0.0
func store_into_subaddress(value, default, storage:Dictionary, page_index:int, line_index:int, dialine_index:int) -> void:
	var page : Dictionary
	if storage.has(page_index):
		page = storage.get(page_index)
	else:
		page = {}
		storage[page_index] = page
	var line : Dictionary
	if page.has(line_index):
		line = page.get(line_index)
	else:
		line = {}
		page[line_index] = line
	
	var value_to_save
	if page_index == 0 and line_index == 0 and dialine_index == 0:
		value_to_save = default
	else:
		value_to_save = value
	
	if not line.has(dialine_index):
		line[dialine_index] = value_to_save
	
	storage[page_index][line_index][dialine_index] = value_to_save

func fetch_from_subaddress(storage:Dictionary, page:int, line:int, dialine:int) -> Variant:
	var prev_page := page
	var prev_line := line
	var prev_dialine := dialine
	
	while prev_page > 0:
		if storage.has(prev_page):
			break
		prev_page -= 1
	
	while prev_line > 0:
		if storage.get(prev_page).has(prev_line):
			break
		prev_line -= 1
	
	while prev_dialine > 0:
		if storage.get(prev_page).get(prev_line).has(prev_dialine):
			break
		prev_dialine -= 1
	

	if not storage.has(prev_page):
		var page_keys = storage.keys()
		page_keys.sort()
		var key_index := 0
		while page_keys[key_index] < prev_page:
			key_index += 1
		prev_page = page_keys[key_index]
		
	if not storage.get(prev_page).has(prev_line):
		var line_keys = storage.get(prev_page).keys()
		line_keys.sort()
		var key_index := 0
		while line_keys[key_index] < prev_line:
			key_index += 1
		prev_line = line_keys[key_index]
	
	if not storage.get(prev_page).get(prev_line).has(prev_dialine):
		var dialine_keys = storage.get(prev_page).get(prev_line).keys()
		dialine_keys.sort()
		var key_index := 0
		while dialine_keys[key_index] < prev_dialine:
			key_index += 1
		prev_dialine = dialine_keys[key_index]
		
	
	return storage[prev_page][prev_line][prev_dialine]
