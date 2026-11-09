extends Node2D

# Small bursts mark projectile hits; larger bursts mark tank destruction.
var tank_explosion := false
var age := 0.0
var particles: Array[Dictionary] = []
var audio := AudioStreamPlayer2D.new()

func _ready() -> void:
	z_index = 50
	var count := 72 if tank_explosion else 18
	for i in range(count):
		var smoke := tank_explosion and i >= 42
		var lifetime := randf_range(0.9, 1.8) if smoke else randf_range(0.15, 0.65)
		particles.append({
			"position": Vector2.ZERO,
			"velocity": Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, 100.0 if smoke else (250.0 if tank_explosion else 130.0)),
			"age": 0.0, "life": lifetime, "smoke": smoke,
			"radius": randf_range(7.0, 14.0) if smoke else randf_range(1.5, 4.0)
		})
	add_child(audio)
	audio.stream = load("res://Sounds/tank_explosion.wav" if tank_explosion else "res://Sounds/projectile_impact.wav") as AudioStream
	audio.volume_db = -5.0 if tank_explosion else -12.0
	audio.max_distance = 2200.0
	audio.pitch_scale = randf_range(0.94, 1.06)
	audio.play()

func _process(delta: float) -> void:
	age += delta
	for i in range(particles.size() - 1, -1, -1):
		var part: Dictionary = particles[i]
		part["age"] += delta
		part["position"] += part["velocity"] * delta
		part["velocity"] *= exp(-delta * 3.0)
		if part["smoke"]:
			part["position"].y -= 24.0 * delta
		if part["age"] >= part["life"]:
			particles.remove_at(i)
	queue_redraw()
	if particles.is_empty() and not audio.playing and age > 0.7:
		queue_free()

func _draw() -> void:
	var duration := 0.5 if tank_explosion else 0.18
	var t := clampf(age / duration, 0.0, 1.0)
	if t < 1.0:
		var radius := lerpf(5.0, 100.0 if tank_explosion else 25.0, t)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 0.7, 0.2, 1 - t), 3.0)
		draw_circle(Vector2.ZERO, radius * 0.5, Color(1, 0.9 - t * 0.5, 0.15, 1 - t))
	for part in particles:
		var progress: float = part["age"] / part["life"]
		var color := Color(0.18, 0.19, 0.2, (1 - progress) * 0.7) if part["smoke"] else Color(1, 0.8 * (1 - progress), 0.1, 1 - progress)
		var radius: float = part["radius"] * (1 + progress * 2) if part["smoke"] else part["radius"] * (1 - progress)
		draw_circle(part["position"], radius, color)
