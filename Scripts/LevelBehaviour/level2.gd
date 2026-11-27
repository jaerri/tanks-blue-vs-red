class_name Level2
extends Level

# Level 2 (Counterattack):
# Victory = player remains in the zone for zone_hold_time AND all enemies destroyed.
# Lose = player tank destroyed or time runs out.

@export var zone_hold_time: float = 5.0
@export var zone: Area2D
@export var zone_color: Color

var zone_timer := 0.0
var zone_occupied := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	zone.body_entered.connect(_on_zone_body_entered)
	zone.body_exited.connect(_on_zone_body_exited)

func _on_zone_body_entered(body: Node2D) -> void:
	if body == player:
		zone_occupied = true

func _on_zone_body_exited(body: Node2D) -> void:
	if body == player:
		zone_occupied = false
		zone_timer = 0.0

func _physics_process(delta: float) -> void:
	if _game_ended:
		return
	if remaining <= 0 and zone_occupied:
		zone_timer += delta
		print("holding zone %fs left" % (zone_hold_time - zone_timer))
		if zone_timer >= zone_hold_time:
			win()
	else:
		zone_timer = 0.0
		
func _process(_d: float) -> void:
	queue_redraw()

func _draw() -> void:
	var r: float = zone.get_child(0).shape.radius
	var p := clampf(zone_timer / zone_hold_time, 0.0, 1.0)

	draw_circle(zone.position, r, Color(zone_color, 0.12))               # zone background
	if p > 0.0:
		draw_circle(zone.position, r * p, Color(zone_color, 0.45))       # growing fill
	draw_circle(zone.position, r, Color(zone_color, 0.9), false, 3.0)    # outline on top	
