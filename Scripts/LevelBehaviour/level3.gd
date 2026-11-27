class_name Level3
extends Level

# Level 3 (Last Stand):
# Victory = all enemies defeated (coordinated enemy AI not yet implemented).
# Lose = player tank destroyed.

func _physics_process(_delta: float) -> void:
	if remaining <= 0:
		win()
