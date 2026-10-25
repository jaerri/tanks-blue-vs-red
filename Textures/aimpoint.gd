extends Sprite2D

@export var ACTUAL_SCALE: float = 1.0

func _ready() -> void:
	get_window().size_changed.connect(_fix_scale)
	_fix_scale()

# make texture pixels map 1:1 to screen pixels, like the cursor
func _fix_scale() -> void:
	var win := get_window()
	var base := Vector2(win.content_scale_size)  # base size from project settings
	var stretch := minf(win.size.x / base.x, win.size.y / base.y)
	scale = Vector2.ONE * ACTUAL_SCALE / stretch
