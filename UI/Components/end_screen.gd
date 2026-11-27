extends Control

@export var last_level: PackedScene
@export var result: String = "VICTORY"

@onready var result_label := $ResultLabel

func _ready() -> void:
	result_label.text = result

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_packed(last_level)
	
