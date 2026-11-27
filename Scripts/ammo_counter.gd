class_name AmmoCounter
extends Node

signal ammo_change
@export var capacity: int = 20
@export var remaining: int

func change_ammo(count: int) -> bool:
	if count < 0 and remaining + count < 0:
		return false
	var next := clampi(remaining + count, 0, capacity)
	if next == remaining:
		return false
	remaining = next
	ammo_change.emit()
	return true
