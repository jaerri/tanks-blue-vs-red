extends Control

func _ready():
	$PlayButton.pressed.connect(_on_play_pressed)
	$InstructionsButton.pressed.connect(_on_instructions_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Entering alpha level!")
	get_tree().change_scene_to_file("res://Levels/alpha_level.tscn")
	

func _on_instructions_pressed():
	get_tree().change_scene_to_file("res://UI/Components/instructions_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
