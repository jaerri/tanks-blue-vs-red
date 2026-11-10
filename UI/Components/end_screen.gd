extends Control


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/alpha_level.tscn")
