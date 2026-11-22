class_name Player
extends Commander

@onready var camera := $Camera
@onready var win := get_window()
const cursor_texture := preload("res://Textures/cursor.svg")
@export var CAMERA_OFFSET_CURVE: Curve
@export var CAMERA_ZOOM_CURVE: Curve
## Counts from the edge of the camera
@export var CAMERA_OFFSET_MAX: float = 512.0

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_texture.get_size()/2)

func _process(delta: float) -> void:
	# pass input to player controlled vehicle (tank here)
	tank_input = Input.get_vector("left", "right", "forward", "backward")
	commander_target = get_global_mouse_position()
	
	# update actual aimpoint
	$Aimpoint.position = turret_target
	
	# update aim offset
	aiming_offset_camera(delta)
	
func aiming_offset_camera(delta: float) -> void:
	# get_mouse_position always use window (not virtual) pixels
	var dir = win.get_mouse_position() * Game.stretch / Vector2(win.size) \
		- Vector2(0.5, 0.5) 
	dir *= 2 # 0.5 to 1
	dir /= max(1.0, dir.length()) # clamp to unit circle
	var l = dir.length()
	
	# adjust max offset depending on window size
	# camera offset use virtual pixels
	# so we convert window pixels to virtual using stretch
	var virtual_winsize: Vector2 = Vector2(win.size) / camera.zoom / Game.stretch
	# divide by 2 because we only need half the screen on one side
	# don't go below 0 pls
	var offset_max = (Vector2.ONE * CAMERA_OFFSET_MAX - virtual_winsize / 2).maxf(0.0)
	#print("stretch: ", Game.stretch)
	#print("win: ", Vector2(win.size) / camera.zoom)
	#print("virt win: ", virtual_winsize)
	#print("win content scale: ", win.content_scale_size)
	#print("mouse: ", win.get_mouse_position())
	#print("dir: ", dir, " ", l)
	#print("curve: ", CAMERA_OFFSET_CURVE.sample(l))
	#print("offset: ", offset_max)
	
	#var target_offset = _clamp_ellipse(
		#dir.sign() * Vector2(
			#CAMERA_OFFSET_CURVE.sample(abs(dir.x)),
			#CAMERA_OFFSET_CURVE.sample(abs(dir.y))
		#) * offset_max,
		#offset_max
	#)
	var target_offset = dir * offset_max * CAMERA_OFFSET_CURVE.sample(l)
	var target_zoom := Vector2.ONE * CAMERA_ZOOM_CURVE.sample(l) 
	
	camera.offset = camera.offset.lerp(target_offset, 1.0 - exp(-4.0 * delta))
	camera.zoom = camera.zoom.lerp(target_zoom, 1.0 - exp(-4.0 * delta))
	#print("target_offset: ", target_offset)
	#print("---")
	
func _draw() -> void:	
	pass
	#draw_circle(Vector2(), CAMERA_OFFSET_MAX, Color.DARK_BLUE, false)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		fire.emit()

func _on_tank_destroy(_tank: Tank) -> void:
	await get_tree().create_timer(1).timeout # wait 1 sec
	get_tree().change_scene_to_file("res://UI/Components/end_screen.tscn")
