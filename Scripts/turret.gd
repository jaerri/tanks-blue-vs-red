class_name Turret
extends RigidBody2D

@export var TURRET_TURN_POWER := 100.0
@export var shell_data: ShellData
@export var commander: Commander:
	set(value):
		commander = value
		commander.fire.connect(fire)
var turret_target := Vector2()

const TURRET_DEADZONE := deg_to_rad(1)
const PITCH_DEADZONE := 1.0 
const BULLET_TRAIL = preload("res://Scenes/Effects/bullet_trail.tscn")

var actual_aimpoint: Vector2:
	set(val):
		commander.turret_target = val # update commander where we are aiming at
		actual_aimpoint = val

var _body: Node2D
var body_last_rotation: float
var additional_rotation: float:
	get():
		if _body:
			set_deferred("body_last_rotation", _body.rotation)
			return _body.rotation - body_last_rotation
		else:
			return 0.0

func turn_to(delta: float, pos: Vector2) -> void:
	# get the current rotation of the current
	var rot: float = global_rotation
	# get the rotation from the turret to the mouse position
	var targetAngle: float = global_position.angle_to_point(pos)
	
	# makes the turret rotates with the body (if there is)
	rotate(additional_rotation)
	
	#print("mouse: ", pos)
	#print("rot: ", rad_to_deg(rot))
	#print("target: ", rad_to_deg(targetAngle))
	# fix the turret to target angle if close enough
	if (abs(targetAngle - rot) < TURRET_DEADZONE && abs(additional_rotation) < TURRET_DEADZONE):
		#if (randf() < 0.7):
		set_global_rotation(targetAngle)
		#print("stop")
	else:
		# calculate how much to rotate and which direction
		var torque = TURRET_TURN_POWER * signf(angle_difference(rot, targetAngle)) * delta
		#print("rotate ", "right" if torque > 0 else "left")
		apply_torque(torque)

var reloading := false
func fire() -> void:
	# cooldown
	if reloading:
		return
	# create shell
	var shell: Shell = shell_data.Shell.instantiate()
	shell.global_position = $MuzzlePosition.global_position
	# setup to fire where we looking
	add_child(shell)
	# go
	shell.go(shell_data, actual_aimpoint)
	# muzzle effect & sounds
	$MuzzlePosition/FiringEffect/AnimationPlayer.play("cannon_firing")
	EffectSpawner.spawn(BULLET_TRAIL, shell)	
	
	# reload mechanic
	reloading = true
	print("reloading...")	
	get_tree().create_timer(shell_data.RELOAD_SEC).timeout.connect(func():
		reloading = false
		print("up")
	)

@export var GUN_PITCH_RATE := 200.0
var fly_distance: float
func change_rate(r: float) -> float:
	var rate := clampf(pow(1-r, 0.25), 0.1, 1)
	return rate * GUN_PITCH_RATE
	
func change_pitch(delta: float, target: Vector2) -> void:
	var starting_pos: Vector2 = $MuzzlePosition.global_position
	# adjust fly distance, aka the pitch of the cannon
	var new_distance := clampf(starting_pos.distance_to(target), shell_data.MIN_RANGE, shell_data.MAX_RANGE)
	#print("pitch ", fly_distance, " ", new_distance)
	fly_distance = move_toward(fly_distance, new_distance, change_rate(fly_distance/shell_data.MAX_RANGE) * delta)
	# calculate actual point the bullet might hit
	actual_aimpoint = starting_pos + Vector2.from_angle($MuzzlePosition.global_rotation) * fly_distance

func _ready() -> void:
	_body = self.get_parent()
	body_last_rotation = _body.rotation
	# listen to when commander orders to fire
	fly_distance = shell_data.MAX_RANGE / 2

func _physics_process(delta: float) -> void:
	if (commander != null):
		turn_to(delta, commander.commander_target)
		change_pitch(delta, commander.commander_target)
	
	
