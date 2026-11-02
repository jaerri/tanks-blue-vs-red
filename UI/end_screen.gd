
extends Control

func _ready():
	$MainMenuButton.pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
