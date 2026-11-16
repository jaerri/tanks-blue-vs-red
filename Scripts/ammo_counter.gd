class_name AmmoCounter
extends Node

signal ammo_change
@export var remaining: int

func change_ammo(count: int) -> bool:
	if remaining > 0:
		remaining += count
		ammo_change.emit()
		return true
	else:
		return false
