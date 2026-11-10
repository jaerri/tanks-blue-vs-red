extends Node

func spawn(scene: PackedScene, update_position_to_node: Node2D) -> void:
	var effect: Node2D = scene.instantiate()
	get_tree().root.add_child(effect)
	
	if update_position_to_node:
		var remote = RemoteTransform2D.new()
		update_position_to_node.add_child(remote)
		remote.remote_path = effect.get_path()
		
	if effect is GPUParticles2D:
		effect.emitting = true
		update_position_to_node.tree_exiting.connect(func():
			effect.emitting = false	
		)
		effect.finished.connect(effect.queue_free)

# Effects live independently so disabling a destroyed tank cannot stop them.
func spawn_combat_effect(at: Vector2, tank_explosion: bool = false) -> Node2D:
	var effect := Node2D.new()
	effect.set_script(load("res://Scripts/combat_effect.gd"))
	effect.set("tank_explosion", tank_explosion)
	get_tree().root.add_child(effect)
	effect.global_position = at
	return effect
