class_name Tank
extends CharacterBody2D

signal destroyed

@export var ENGINE_POWER := 75.0
@export var STEER_POWER := 1.0
@export var MAX_SPEED := 2.0
@export var MAX_STEER := 0.2
@export var BRAKE_POWER := 3.0
@export var commander: Commander:
	set(value):
		# let the turret knows who our new commander object is
		$Turret.commander = value
		commander = value
		commander.vehicle = self

# https://www.desmos.com/calculator/nkfahemaxk
func SPEED_CURVE(t: float) -> float:
	#return exp(-0.5/(t*t)) * sign(t)
	return tanh(t)*tanh(t) * sign(t)
# integral of SPEED_CURVE
func SPEED_CURVE_DX(t: float) -> float:
	return atanh(tanh(t))-tanh(t) * sign(t)
	
var speed := 0.0 # -1 backward, 1 forward
var steer := 0.0 # -1 left, 1 right

func simulate_rpm(current: float, target: float, max: float, delta: float) -> float:
	if is_zero_approx(target):
		return move_toward(current, 0.0, delta)
	elif (current * (max - current) < 0): 
		# decide if brake
		# make sure that value is heading towards zero
		# i think i just recreated xor
		return move_toward(current, max, delta * BRAKE_POWER)
	else:
		# normal acceleration
		return move_toward(current, max, delta * abs(target))
	
func accelerate(delta: float, input: Vector2) -> void:
	# movement
	speed = simulate_rpm(speed, input.y, MAX_SPEED * sign(input.y), delta)
	# steering
	#steer = simulate_rpm(steer, input.x, MAX_STEER * sign(input.x), delta)
	steer = input.x

func apply_tank_movement(delta: float) -> void:	
	velocity = global_transform.y * SPEED_CURVE(speed) * ENGINE_POWER
	rotate(
		STEER_POWER * delta * steer
		# constant steer for now
		#* SPEED_CURVE(steer)
	)
	#print("speed: ", speed)
	#print("steer: ", steer)
	move_and_slide()
	
func _physics_process(delta: float) -> void:
	# movement
	#print(commander.tank_input)
	# get the input from commander
	accelerate(delta, commander.tank_input * Vector2(1, -1))
	apply_tank_movement(delta)


func _on_hitbox_die() -> void:
	destroyed.emit()
	modulate = Color.DIM_GRAY
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_hitbox_health_changed(old: float, new: float) -> void:
	%ProgressBar.value = new
