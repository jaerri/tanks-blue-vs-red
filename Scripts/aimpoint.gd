extends Sprite2D

@export var ACTUAL_SCALE: float = 1.0

func _ready() -> void:
	get_window().size_changed.connect(_fix_scale)
	_fix_scale()

# make texture pixels map 1:1 to screen pixels, like the cursor
func _fix_scale() -> void:
	scale = Vector2.ONE * ACTUAL_SCALE / Game.stretch
