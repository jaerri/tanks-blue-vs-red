extends Control

@export var level1: PackedScene
@export var level2: PackedScene
@export var level3: PackedScene

func _ready() -> void:
	$Level1Button.pressed.connect(_on_level_1_pressed)
	$Level2Button.pressed.connect(_on_level_2_pressed)
	$Level3Button.pressed.connect(_on_level_3_pressed)
	$BackButton.pressed.connect(_on_back_pressed)

func _on_level_1_pressed() -> void:
	print("Level 1 selected")

func _on_level_2_pressed() -> void:
	print("Level 2 selected")

func _on_level_3_pressed() -> void:
	print("Level 3 selected")

func _on_back_pressed() -> void:
	print("Returning to Main Menu")
