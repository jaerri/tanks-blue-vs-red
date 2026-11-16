extends Control

func _ready():
	$BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
