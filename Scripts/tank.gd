class_name Tank
extends CharacterBody2D

signal destroy(tank: Tank)

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
		if commander: 
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

func _simulate_rpm(current: float, target: float, maximum: float, delta: float) -> float:
	if is_zero_approx(target):
		return move_toward(current, 0.0, delta)
	elif (current * (maximum - current) < 0): 
		# decide if brake
		# make sure that value is heading towards zero
		# i think i just recreated xor
		return move_toward(current, maximum, delta * BRAKE_POWER)
	else:
		# normal acceleration
		return move_toward(current, maximum, delta * abs(target))
	
func _accelerate(delta: float, input: Vector2) -> void:
	# movement
	speed = _simulate_rpm(speed, input.y, MAX_SPEED * sign(input.y), delta)
	# steering
	#steer = simulate_rpm(steer, input.x, MAX_STEER * sign(input.x), delta)
	steer = input.x

func _apply_tank_movement(delta: float) -> void:	
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
	_update_maintenance(delta)
	if maintenance_active or maintenance_exit_left > 0.0:
		speed = 0.0
		steer = 0.0
		velocity = Vector2.ZERO
		return
	# movement
	#print(commander.tank_input)
	# get the input from commander
	if commander:
		_accelerate(delta, commander.tank_input * Vector2(1, -1))
		_apply_tank_movement(delta)
		%EngineSound.pitch_scale = clampf(absf(speed) + 0.4 * absf(steer), 0.4, 1.8)

var destroyed: bool = false;
func _on_hitbox_die() -> void:
	if destroyed:
		return
	destroyed = true
	_finish_supply()
	maintenance_active = false
	maintenance_exit_left = 0.0
	$Turret.maintenance_locked = true
	# remove commanders aka disable the tank
	commander = null
	
	# destruction effects
	EffectSpawner.spawn_combat_effect(global_position, true)
	%EngineSound.stop()
	modulate = Color.DIM_GRAY

	# tell everybd we are dead
	destroy.emit(self)

func _on_hitbox_health_changed(_old: float, new: float) -> void:
	%ProgressBar.value = new


var maintenance_active := false
var maintenance_exit_left := 0.0
var supply_spot: Node2D
var supply_changed := false
var ammo_tick := 0.0
var maintenance_label: Label

func _ready() -> void:
	if commander is Player:
		var layer := CanvasLayer.new()
		add_child(layer)
		maintenance_label = Label.new()
		maintenance_label.position = Vector2(20, 20)
		maintenance_label.add_theme_font_size_override("font_size", 18)
		maintenance_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(maintenance_label)

func nearest_supply() -> Node2D:
	var closest: Node2D
	var distance := 56.0
	for spot in get_tree().get_nodes_in_group("supply_spots"):
		if spot.cooldown_left > 0.0:
			continue
		var d: float = global_position.distance_to(spot.global_position)
		if d < distance:
			distance = d
			closest = spot
	return closest

func toggle_maintenance() -> void:
	if destroyed or not commander is Player or maintenance_exit_left > 0.0:
		return
	if maintenance_active:
		_leave_maintenance()
		return
	var spot := nearest_supply()
	if spot == null:
		return
	var ammo := $Turret.ammo_counter as AmmoCounter
	if spot.supply_type == 0 and $Hitbox.health >= $Hitbox.MAX_HEALTH:
		return
	if spot.supply_type == 1 and (ammo == null or ammo.remaining >= ammo.capacity):
		return
	supply_spot = spot
	supply_changed = false
	ammo_tick = 0.0
	maintenance_active = true
	$Turret.maintenance_locked = true
	$Turret.angular_velocity = 0.0
	speed = 0.0
	steer = 0.0
	velocity = Vector2.ZERO

func _finish_supply() -> void:
	if is_instance_valid(supply_spot) and supply_changed:
		supply_spot.consume()
	supply_spot = null
	supply_changed = false

func _leave_maintenance() -> void:
	_finish_supply()
	maintenance_active = false
	maintenance_exit_left = 2.0

func _update_maintenance(delta: float) -> void:
	if destroyed:
		if is_instance_valid(maintenance_label): maintenance_label.text = "TANK DESTROYED"
		return
	if maintenance_exit_left > 0.0:
		maintenance_exit_left = maxf(0.0, maintenance_exit_left - delta)
		$Turret.angular_velocity = 0.0
		if maintenance_exit_left <= 0.0: $Turret.maintenance_locked = false
	elif maintenance_active:
		$Turret.angular_velocity = 0.0
		if not is_instance_valid(supply_spot) or global_position.distance_to(supply_spot.global_position) > 56.0:
			_leave_maintenance()
		elif supply_spot.supply_type == 0:
			var before: float = $Hitbox.health
			$Hitbox.change_damage(20.0 * delta)
			supply_changed = supply_changed or $Hitbox.health > before
			if $Hitbox.health >= $Hitbox.MAX_HEALTH: _leave_maintenance()
		else:
			var ammo := $Turret.ammo_counter as AmmoCounter
			if ammo == null:
				_leave_maintenance()
			else:
				ammo_tick += delta
				while ammo_tick >= 0.5 and ammo.remaining < ammo.capacity:
					ammo_tick -= 0.5
					supply_changed = ammo.change_ammo(1) or supply_changed
				if ammo.remaining >= ammo.capacity: _leave_maintenance()
	if is_instance_valid(maintenance_label):
		if maintenance_exit_left > 0.0:
			maintenance_label.text = "LEAVING MAINTENANCE %.1fs — controls locked" % maintenance_exit_left
		elif maintenance_active:
			maintenance_label.text = "REPLENISHING — E to leave | Movement and weapons locked"
		else:
			var nearby := nearest_supply()
			maintenance_label.text = "E: replenish at green HEALTH or gold AMMO spots"
			if nearby != null:
				maintenance_label.text = "E: replenish HEALTH" if nearby.supply_type == 0 else "E: replenish AMMO"
