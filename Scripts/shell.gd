class_name Shell
extends Node2D

var data: ShellData
var target_distance: float
var velocity := Vector2()

func go(_data: ShellData, target: Vector2) -> void:
	data = _data
	# calculate how much to go
	target_distance = min(target.distance_to(global_position), data.MAX_RANGE)
	# set velocity
	velocity = (target - global_position).normalized()
	rotation = velocity.angle()
	
	# setup explosive radius
	$ExplosiveHurtbox/CollisionShape2D.shape.radius = data.EXPLOSIVE_RANGE
	# set child callables to its corresponding damage method
	$KineticHurtbox.get_damage = get_kinetic_damage
	$ExplosiveHurtbox.get_damage = get_explosive_damage
	
# at this point my code flow is pretty bad
var destroyed := false
func destroy(destroy_effect: Callable):
	# only destroy once pls
	if (destroyed):
		return
	destroyed = true
	
	destroy_effect.call()
	queue_free()

var exploded := false
func explode():
	if (exploded):
		return
	exploded = true
	print("explode")
	velocity = Vector2()
	
	# enable explosiooo
	$ExplosiveHurtbox/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.1).timeout
	destroy(explosive_hit_effect)

func kinetic_hit_effect() -> void:
	pass
func explosive_hit_effect() -> void:
	pass

# get kinetic also means shell has hit, destroy
func get_kinetic_damage(hitbox: Hitbox) -> float:
	print("dist: ", total_distance)
	print("range ratio: " + str(total_distance/data.MAX_RANGE))
	print("kinetic ratio: " + str(data.KINETIC_DAMAGE_CURVE.sample(total_distance / data.MAX_RANGE)))
	destroy(kinetic_hit_effect)
	return lerpf(
		data.MIN_KINETIC_DAMAGE, 
		data.MAX_KINETIC_DAMAGE, 
		data.KINETIC_DAMAGE_CURVE.sample(total_distance / data.MAX_RANGE)
	)

# explosive does not call explode, allow multiple hits
func get_explosive_damage(hitbox: Hitbox) -> float:
	print("explosive")
	var r = hitbox.global_position.distance_to($ExplosiveHurtbox.global_position)
	return data.EXPLOSIVE_DAMAGE * max(0.0, 1.0 - r / data.EXPLOSIVE_RANGE)

var total_distance := 0.0
func _physics_process(delta: float) -> void:	
	var offset = data.FLIGHT_SPEED * delta
	# basic integration, move along velocity
	position += velocity * offset
	# add distance to total each step
	total_distance += offset
	# destroy if out of range or reached location
	if total_distance >= target_distance:
		explode()

func _on_kinetic_hurtbox_sth_entered() -> void:
	print("hi wall")
	destroy(kinetic_hit_effect)
