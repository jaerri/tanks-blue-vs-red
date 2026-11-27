extends Control

@export var max_ammo: int = 10

var current_ammo: int = 10

@onready var ammo_label: Label = $AmmoLabel


func _ready() -> void:
	current_ammo = max_ammo
	update_ammo_display()


func update_ammo_display() -> void:
	ammo_label.text = "AMMO: %d / %d" % [current_ammo, max_ammo]


func use_ammo() -> void:
	if current_ammo > 0:
		current_ammo -= 1
		update_ammo_display()


func reload_ammo() -> void:
	current_ammo = max_ammo
	update_ammo_display()
	
