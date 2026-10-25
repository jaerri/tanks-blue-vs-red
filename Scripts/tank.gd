class_name Tank
extends RigidBody2D

enum STATE { RUNNING, MAINTENANCE, DESTROYED }

@export var ENGINE_POWER := 100.0
@export var MAX_RPM_FORWARD := 3.0
@export var MAX_RPM_REVERSE := 2.0
@export var BRAKE_POWER := 3.0
@export var commander: Commander:
	set(value):
		# let the turret knows who our new commander object is
		$Turret.commander = value
		commander = value
@export var tank_state = STATE.RUNNING

static func SPEED_CURVE(t: float) -> float:
	if (is_zero_approx(t)):
		return 0.0
	# https://www.desmos.com/calculator/nkfahemaxk
	t-=0.1
	return exp(-0.5/(t*t)) * sign(t)
	
var engineRPM := Vector2() # x is left, y is right
# not really real RPM
func simulate_rpm(delta: float, input: Vector2) -> void:
	# lambda to reuse calculation
	var calculation := func(c: float, t: float) -> float: # current, target, brake
		var max = t * (MAX_RPM_FORWARD if t > 0.0 else MAX_RPM_REVERSE)
		if (is_equal_approx(c, max)): # clamp if close enough
			return max
			
		# decide if brake
		var brake := 1.0
		# make sure that value is heading towards zero
		# i think i just recreated xor
		if (!input.is_zero_approx() && c * (max - c) < 0): 
			#print("braking")
			brake = BRAKE_POWER
				
		return c + sign(max - c) * delta * brake
	
	# call calculation for each side of track
	engineRPM.x = calculation.call(engineRPM.x, input.x)
	engineRPM.y = calculation.call(engineRPM.y, input.y)
	#print(trackPower)
	#print(engineRPM)

func apply_tank_movement() -> void:	
	# turn rpm into actual speed, multiplied by engine power
	var engineTorque := Vector2(SPEED_CURVE(engineRPM.x), SPEED_CURVE(engineRPM.y)) * ENGINE_POWER
	var leftTrackForce := Vector2.DOWN * engineTorque.x
	var rightTrackForce := Vector2.DOWN * engineTorque.y
	#print("RPM: ", engineRPM)
	#print("Torque: ", engineTorque)
	
	# non-functional, display a line to visualize force vector
	#$LeftTrack/VectorDisplay.update(leftTrackForce)
	#$RightTrack/VectorDisplay.update(rightTrackForce)
	
	# apply force, this is more related to velocity
	apply_force(leftTrackForce.rotated(global_rotation), $LeftTrack.position.rotated(global_rotation))
	apply_force(rightTrackForce.rotated(global_rotation), $RightTrack.position.rotated(global_rotation))
	
# do not touch this abdomination because it works
static func convert_tank_input(dir: Vector2) -> Vector2:	
	var result := Vector2()

	if (dir):
		if(abs(dir.y) < sin(PI/4) - 0.00001): 
			# ignore y input between in the inner half of the circle
			result = Vector2(1.0, -1.0) * sign(dir.x)
		else:
			var x = round(dir.x * sqrt(2)) # very specific
			result = Vector2(1.0+x, 1.0-x).clampf(-1.0, 1.0) * -sign(dir.y)
	return result
	
func _physics_process(delta: float) -> void:
	match tank_state:
		STATE.RUNNING:
			# movement
			#print(commander.tank_input)
			# get the input from commander
			simulate_rpm(delta, convert_tank_input(commander.tank_input))
			apply_tank_movement()
