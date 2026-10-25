class_name Player
extends Commander

@onready var camera := $Camera2D
const cursor_texture := preload("res://Textures/cursor.svg")

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_texture.get_size()/2)

func _process(delta: float) -> void:
	# pass input to player controlled vehicle (tank here)
	tank_input = Input.get_vector("left", "right", "forward", "backward")
	commander_target = get_global_mouse_position()
	
	# update actual aimpoint
	$Aimpoint.position = turret_target

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		fire.emit()
