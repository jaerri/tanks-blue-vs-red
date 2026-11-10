class_name AmmoCounter
extends Node

var remaining: int

func add_ammo(count: int) -> void:
	if count > 0:
		remaining += count

func use_ammo() -> bool:
	if remaining > 0:
		remaining -= 1
		return true
	else:
		return false
