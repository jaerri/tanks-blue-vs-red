class_name Level1
extends Level

# Level 1 (Defense): Victory = destroy all enemy tanks.
# Lose = player tank destroyed.

func _physics_process(_delta: float) -> void:
	if remaining <= 0:
		win()
