class_name EnemyTankCommander
extends Commander

@export var DEBUG: bool = false
@export var STEER_HARDNESS: float = 1.5
@export var SPOTTING_RANGE: float = 256.0
@export var TURN_SPEED_CURVE: Curve # x (degrees) -> y (recommended speed)

static func aggressive_drive(tank: Tank, current: float, target: float, distance: float) -> float:
	var best_distance_to_target := (
		# integrate to see how much space we have left
		# use the brake as much as we can
		(tank.SPEED_CURVE_DX(current) - tank.SPEED_CURVE_DX(target)) * tank.ENGINE_POWER
	)
	#print("distance: ", distance)
	#print("braking distance: ", best_distance_to_target)
	#print("target speed: ", target)
	# brake if close, full speed if not
	if distance > best_distance_to_target:
		return -1
	else:
		print("braking")
		return 1

var steer := 0.0
var speed := 0.0
var next := Vector2()
var after_next := Vector2()
func drive(delta: float) -> Vector2:
	if %NavigationAgent2D.is_navigation_finished():
		return Vector2.ZERO
	var tank := vehicle as Tank
	# find next turn angle
	next = %NavigationAgent2D.get_next_path_position()
	var current_idx: int = %NavigationAgent2D.get_current_navigation_path_index() 
	var path: PackedVector2Array = %NavigationAgent2D.get_current_navigation_path()	
	if !path.is_empty() and current_idx < path.size()-1:
		after_next = path[current_idx+1]
	var final := current_idx >= path.size()-1
	#print("current idx: ", current_idx)
	#print("path size: ", path.size())
	
	# heading vectors
	var current_heading := next - global_position
	var next_path := after_next - next
	
	# the angles
	var next_angle_diff := current_heading.angle_to(next_path)
	var current_angle_diff := global_transform.y.angle_to(current_heading)
	
	# movement 
	#print("next angle diff: ", rad_to_deg(next_angle_diff))
	var next_speed_limit := TURN_SPEED_CURVE.sample(rad_to_deg(abs(next_angle_diff)))
	if final:
		#print("final!")
		next_speed_limit = 0.0
	var current_speed_limit := TURN_SPEED_CURVE.sample(rad_to_deg(abs(current_angle_diff)))
	var distance := global_position.distance_to(next)
	speed = clampf(
		aggressive_drive(tank, tank.speed, next_speed_limit, distance), 
		-current_speed_limit, 1.0
	)
	# steering
	steer = clampf(
		current_angle_diff * STEER_HARDNESS / tank.STEER_POWER,
		-1, 1
	)
	#print("speed: ", speed, "; steer: ", steer)	
	#print("angle: ", current_angle_diff)
	#print(%NavigationAgent2D.get_current_navigation_path())
		
	return Vector2(steer, speed)

var player: Tank = get_tree().get_first_node_in_group("player")
func _spotting_update() -> void:
	var tank := vehicle as Tank
	# do raycast
	%SpottingRaycast.target_position = to_local(player.global_position)
	var spotted: bool = (!%SpottingRaycast.is_colliding() and 
		player.tank_state != player.STATE.DESTROYED and
		global_position.distance_to(player.global_position) <= SPOTTING_RANGE)
	
	# send property to statechart
	%StateChart.set_expression_property("is_player_spotted", spotted)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and DEBUG: 
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			%NavigationAgent2D.target_position = get_global_mouse_position()

func _draw() -> void:
	if DEBUG:
		draw_line(Vector2(), Vector2(speed, -steer).rotated(rotation - PI/2) * 50, Color.YELLOW, 1.0)
		draw_line(to_local(next), to_local(after_next), Color.BLUE, 2.0)

func _physics_process(delta: float) -> void:
	if not vehicle:
		return
	tank_input = drive(delta)
	if DEBUG:
		queue_redraw()

func _on_engaging_state_entered() -> void:
	%NavigationAgent2D.target_position = global_position

func _on_engaging_state_physics_processing(delta: float) -> void:
	commander_target = player.global_position
	if turret_target.is_equal_approx(player.global_position):
		fire.emit()

func _on_seek_state_physics_processing(delta: float) -> void:
	if %StateChart.get_expression_property("is_player_spotted"):
		%NavigationAgent2D.target_position = player.global_position		

func _on_patrol_state_physics_processing(delta: float) -> void:
	pass
