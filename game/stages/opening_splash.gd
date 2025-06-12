extends ColorRect


func _ready() -> void:
	visible = false

func start():
	visible = true
	%Content.visible = false
	var start_position = %Content.position
	await get_tree().create_timer(2.5).timeout
	%Content.visible = true
	Sound.play_sfx("shutter")
	var i := 0
	while i < 6:
		await get_tree().create_timer(1.5).timeout
		%Content.position = start_position + Vector2(
			randi_range(-1, 1),
			randi_range(-1, 1),
		)
		i += 1
	
	await get_tree().create_timer(2.5).timeout
	%Content.visible = false
	Sound.play_sfx("shutter")
	await get_tree().create_timer(4).timeout
	Parser.function_acceded()
	queue_free()
	
