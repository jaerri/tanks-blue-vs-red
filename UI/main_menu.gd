extends Control

func _ready():
	$PlayButton.pressed.connect(_on_play_pressed)
	$InstructionsButton.pressed.connect(_on_instructions_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("PLAY button clicked!")

func _on_instructions_pressed():
	get_tree().change_scene_to_file("res://instructions_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
