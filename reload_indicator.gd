extends Control

@onready var reload_bar = $ReloadBar
@onready var reload_label = $ReloadLabel

func _ready():
	update_reload(0)

func update_reload(progress: float):
	reload_bar.value = clamp(progress, 0.0, 100.0)

	if reload_bar.value >= 100:
		reload_label.text = "READY TO FIRE!"
	else:
		reload_label.text = "RELOADING..."
