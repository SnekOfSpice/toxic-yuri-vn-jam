extends CustomWindow

var band := 7

func _ready() -> void:
	super()
	ParserEvents.word_read.connect(on_word_read)
	
	for segment in get_segments():
		segment.scale.y = 0
	
func get_segments() -> Array:
	return %Segments.get_children() as Array

func on_word_read(word:String):
	var i := 0.0
	var segment_count := get_segments().size()
	for segment : ColorRect in get_segments():
		var amp:float
		if i <= band:
			amp = i / float(band)
		elif i >= segment_count - band:
			amp = (segment_count - i) / float(segment_count - band)
		else:
			amp = 1
		amp *= randf_range(0.96, 1.03)
		var duration := 0.05 + word.length() * 0.005
		duration *= randf_range(0.96, 1.03)
		segment.scale.y = amp
		var t = create_tween()
		t.tween_property(segment, "scale:y", 0, duration)
		i += 1
