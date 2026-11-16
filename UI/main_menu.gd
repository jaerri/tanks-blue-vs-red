extends Control

@export var level: PackedScene
@export var instructions_menu: PackedScene

func _ready():
	$PlayButton.pressed.connect(_on_play_pressed)
	$InstructionsButton.pressed.connect(_on_instructions_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Entering level!")
	get_tree().change_scene_to_packed(level)

func _on_instructions_pressed():
	get_tree().change_scene_to_packed(instructions_menu)

func _on_quit_pressed():
	get_tree().quit()
