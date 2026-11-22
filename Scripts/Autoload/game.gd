extends Node

var fullscreen: bool = false
var stretch: float

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
func _ready() -> void:
	get_window().size_changed.connect(_fix_scale)
	_fix_scale()

func _fix_scale() -> void:
	var win := get_window()
	var base := Vector2(win.content_scale_size)  # base size from project settings
	var ratio = Vector2(win.size) / base
	stretch = ratio[ratio.min_axis_index()] # get min
