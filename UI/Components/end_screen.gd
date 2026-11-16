extends Control

@export var main_menu: PackedScene
@export var last_level: PackedScene

func _on_main_menu_pressed():
	get_tree().change_scene_to_packed(main_menu)

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_packed(last_level)
	
