extends CustomWindow
class_name WaveFormWindow

var band := 7

func _ready() -> void:
	super()
	ParserEvents.word_read.connect(on_word_read)
	
	for segment in get_segments():
		segment.scale.y = 0
	
func get_segments() -> Array:
	return %Segments.get_children() as Array

func on_word_read(word:String):
	if Parser.line_reader.current_raw_name in Parser.line_reader.blank_names:
		return
	var i := 0.0
	var segment_count := get_segments().size()
	var used_band = band + randi_range(-2, 2)
	if randf() <= 0.4:
		used_band = band
	for segment : ColorRect in get_segments():
		var amp:float
		if i <= used_band:
			amp = i / float(used_band)
		elif i >= segment_count - used_band:
			amp = (segment_count - i) / float(segment_count - used_band)
		else:
			amp = 1
		amp *= randf_range(0.76, 1.23)
		var duration := 0.05 + word.length() * 0.0075
		duration *= randf_range(0.9, 1.13)
		segment.scale.y = amp
		var t = create_tween()
		t.tween_property(segment, "scale:y", 0, duration)
		i += 1
