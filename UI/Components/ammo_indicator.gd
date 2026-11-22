extends Control

@onready var reload_bar := %ReloadBar
@onready var reload_label := %ReloadLabel
@onready var ammo_label: Label = %AmmoLabel
@export var ammo_counter: AmmoCounter
@export var reload_timer: Timer

func _ready() -> void:
	# make sure they're there
	assert(reload_timer)
	assert(ammo_counter)
	ammo_counter.ammo_change.connect(_on_ammo_change)
	_on_ammo_change()
	
func _process(_delta: float) -> void:
	var progress := reload_timer.time_left / reload_timer.wait_time
	if ammo_counter.remaining <= 0:
		reload_bar.value = 1.0
		reload_label.text = "OUT OF AMMO!"
	else:
		update_reload(progress)

func _on_ammo_change() -> void:
	ammo_label.text = "(%d)" % ammo_counter.remaining
	
## progress runs from 0 to 1
func update_reload(progress: float):
	reload_bar.value = lerpf(0.0, 100.0, progress)

	if reload_bar.value <= 0.0:
		reload_label.text = "READY TO FIRE!"
	else:
		reload_label.text = "RELOADING..."
