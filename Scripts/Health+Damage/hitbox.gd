class_name Hitbox
extends Area2D

signal die
signal health_changed(old: float, new: float)

@export var MAX_HEALTH := 100.0
@export var health := 100.0

func change_damage(amount: float) -> void:
	var old = health
	health += amount
	health_changed.emit(old, health)
	if health <= 0.0:
		die.emit()

func _on_area_entered(area: Area2D) -> void:
	var damage = (area as Hurtbox).get_damage.call(self)
	print("hit " + str(damage))
	change_damage(-damage)
