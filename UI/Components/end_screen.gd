extends Control

@export var result: String = "VICTORY"
@onready var next_level_button: Button = %NextLevelButton
@onready var result_label := $ResultLabel
var last_level: PackedScene
var next_level: PackedScene

func _ready() -> void:
	result_label.text = result
	if next_level && result == "VICTORY":
		next_level_button.visible = true

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_packed(last_level)
	
func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_packed(next_level)
