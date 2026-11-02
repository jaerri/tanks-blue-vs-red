class_name Tank
extends CharacterBody2D

enum STATE { RUNNING, MAINTENANCE, DESTROYED }

@export var ENGINE_POWER := 100.0
@export var MAX_SPEED := 2.0
@export var MAX_STEER := 0.1
@export var BRAKE_POWER := 3.0
@export var commander: Commander:
	set(value):
		# let the turret knows who our new commander object is
		$Turret.commander = value
		commander = value
		commander.vehicle = self
@export var tank_state: STATE = STATE.RUNNING

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
	
var speed := 0.0 # -1 backward, 1 forward
var steer := 0.0 # -1 left, 1 right

func simulate_rpm(current: float, target: float, max: float, delta: float) -> float:
	# decide if brake
	var brake := 1.0
	# make sure that value is heading towards zero
	# i think i just recreated xor
	if (!is_zero_approx(target) && current * (max - current) < 0): 
		#print("braking")
		brake = BRAKE_POWER
	return move_toward(current, max, delta * brake)
	
func accelerate(delta: float, input: Vector2) -> void:
	# movement
	speed = simulate_rpm(speed, input.y, MAX_SPEED * sign(input.y), delta)
	# steering
	steer = simulate_rpm(steer, input.x, MAX_STEER * sign(input.x), delta)

func apply_tank_movement(delta: float) -> void:	
	velocity = -global_transform.y * SPEED_CURVE(speed)
	rotate(SPEED_CURVE(steer) * delta)
	print("speed: ", speed)
	print("steer: ", steer)
	move_and_slide()
	
func _physics_process(delta: float) -> void:
	match tank_state:
		STATE.RUNNING:
			# movement
			#print(commander.tank_input)
			# get the input from commander
			accelerate(delta, commander.tank_input)
			apply_tank_movement(delta)
