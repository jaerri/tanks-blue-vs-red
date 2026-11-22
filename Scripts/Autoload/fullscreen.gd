extends Node

var fullscreen: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
