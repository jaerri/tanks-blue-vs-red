@tool
extends Node2D

@export_enum("Health", "Ammo") var supply_type: int = 0:
	set(value):
		supply_type = value
		queue_redraw()
@export var respawn_seconds := 30.0
var cooldown_left := 0.0

func _ready() -> void:
	add_to_group("supply_spots")
	z_index = 2
	var unshaded := CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = unshaded

func consume() -> void:
	cooldown_left = respawn_seconds
	queue_redraw()

func _process(delta: float) -> void:
	if cooldown_left > 0.0:
		cooldown_left = maxf(0.0, cooldown_left - delta)
		queue_redraw()

func _draw() -> void:
	var color := Color.LIME_GREEN if supply_type == 0 else Color.GOLD
	if cooldown_left > 0.0: color = Color.DIM_GRAY
	draw_circle(Vector2.ZERO, 42, Color(color, 0.13))
	draw_arc(Vector2.ZERO, 42, 0, TAU, 48, color, 2)
	draw_rect(Rect2(-16, -16, 32, 32), color.darkened(0.5))
	if supply_type == 0:
		draw_line(Vector2(-10, 0), Vector2(10, 0), color, 6)
		draw_line(Vector2(0, -10), Vector2(0, 10), color, 6)
	else:
		for x in [-8, 0, 8]:
			draw_line(Vector2(x, 9), Vector2(x, -8), color, 4)
	var text := "HEALTH" if supply_type == 0 else "AMMO"
	if cooldown_left > 0.0: text = "%ds" % ceili(cooldown_left)
	draw_string(ThemeDB.fallback_font, Vector2(-24, 58), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
