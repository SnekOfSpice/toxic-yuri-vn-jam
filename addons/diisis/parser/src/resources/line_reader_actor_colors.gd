extends Resource
class_name LineReaderActorColors


## whatever. doesnt do anything atm. come back when i feel more like it!

@export_group("Base")
## Use Color.TRANSPARENT to use the default theme color.
@export var color := Color.TRANSPARENT
@export var outline := Color.WHITE
@export var outline_size := 0
@export_group("Chatlog", "chatlog_")
@export var chatlog_color := Color.WHITE
@export var chatlog_outline := Color.WHITE
## If true, if no chatlog color or outline color is set, will attempt to use the base values before falling back to the LineReader base
@export var chatlog_default_to_base := false
