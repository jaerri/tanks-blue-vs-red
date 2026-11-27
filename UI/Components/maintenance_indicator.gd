extends Control

@export var maintenance_duration: float = 5.0

var time_remaining: float = 0.0
var is_maintenance_active: bool = false

@onready var timer_label: Label = $TimerLabel
@onready var maintenance_label: Label = $MaintenanceLabel


func _ready() -> void:
	start_maintenance()


func _process(delta: float) -> void:
	if is_maintenance_active:
		time_remaining -= delta

		if time_remaining <= 0.0:
			time_remaining = 0.0
			complete_maintenance()

		update_timer_display()


func start_maintenance() -> void:
	time_remaining = maintenance_duration
	is_maintenance_active = true
	maintenance_label.text = "MAINTENANCE MODE"
	update_timer_display()


func update_timer_display() -> void:
	timer_label.text = "00:%02d" % ceili(time_remaining)


func complete_maintenance() -> void:
	is_maintenance_active = false
	maintenance_label.text = "MAINTENANCE COMPLETE!"
	timer_label.text = "00:00"
	
	
