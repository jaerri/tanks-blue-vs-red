extends Control


func _ready() -> void:
	$BackButton.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	print("Returning to Main Menu from Credits")
