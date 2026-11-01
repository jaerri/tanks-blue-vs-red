class_name Tank
extends RigidBody2D

enum STATE { RUNNING, MAINTENANCE, DESTROYED }

@export var ENGINE_POWER := 100.0
@export var MAX_RPM_FORWARD := 3.0
@export var MAX_RPM_REVERSE := 3.0
@export var BRAKE_POWER := 3.0
@export var commander: Commander:
	set(value):
		# let the turret knows who our new commander object is
		$Turret.commander = value
		commander = value
		commander.vehicle = self
@export var tank_state = STATE.RUNNING

# https://www.desmos.com/calculator/nkfahemaxk
func SPEED_CURVE(t: float) -> float:
	if (is_zero_approx(t)):
		return 0.0
	#return exp(-0.5/(t*t)) * sign(t) * ENGINE_POWER
	return tanh(t)*tanh(t) * sign(t) * ENGINE_POWER
func SPEED_CURVE_DERIV(t: float) -> float:
	if (is_zero_approx(t)):
		return 0.0
	return atanh(tanh(t))-tanh(t) * sign(t) * ENGINE_POWER
	
	
var engineRPM := Vector2() # x is left, y is right
# not really real RPM
func simulate_rpm(delta: float, input: Vector2) -> void:
	# lambda to reuse calculation
	var calculation := func(c: float, t: float) -> float: # current, target, brake
		var max = t * (MAX_RPM_FORWARD if t > 0.0 else MAX_RPM_REVERSE)
			
		# decide if brake
		var brake := 1.0
		# make sure that value is heading towards zero
		# i think i just recreated xor
		if (!input.is_zero_approx() && c * (max - c) < 0): 
			#print("braking")
			brake = BRAKE_POWER
		print("Max: ", max)	
		return move_toward(c, max, delta * brake)
	
	# call calculation for each side of track
	engineRPM.x = calculation.call(engineRPM.x, input.x)
	engineRPM.y = calculation.call(engineRPM.y, input.y)

func apply_tank_movement() -> void:	
	# turn rpm into actual speed, multiplied by engine power
	var engineTorque := Vector2(SPEED_CURVE(engineRPM.x), SPEED_CURVE(engineRPM.y))
	var leftTrackForce := Vector2.DOWN * engineTorque.x
	var rightTrackForce := Vector2.DOWN * engineTorque.y
	print("RPM: ", engineRPM)
	print("Torque: ", engineTorque)
	
	# non-functional, display a line to visualize force vector
	#$LeftTrack/VectorDisplay.update(leftTrackForce)
	#$RightTrack/VectorDisplay.update(rightTrackForce)
	
	# apply force, this is more related to velocity
	apply_force(leftTrackForce.rotated(global_rotation), $LeftTrack.position.rotated(global_rotation))
	apply_force(rightTrackForce.rotated(global_rotation), $RightTrack.position.rotated(global_rotation))
	
# do not touch this abdomination because it works
static func convert_tank_input(dir: Vector2) -> Vector2:	
	if !dir:
		return dir
		
	if (abs(dir.y) < sin(PI/4) - 0.00001): 
		# ignore y input between in the inner half of the circle
		return Vector2(1.0, -1.0) * sign(dir.x) * dir.length()
	else:
		var x = round(dir.x * sqrt(2)) # very specific
		return Vector2(1.0+x, 1.0-x).clampf(-1.0, 1.0) * -sign(dir.y) * dir.length()
	
func _physics_process(delta: float) -> void:
	match tank_state:
		STATE.RUNNING:
			# movement
			#print(commander.tank_input)
			# get the input from commander
			simulate_rpm(delta, convert_tank_input(commander.tank_input))
			apply_tank_movement()
