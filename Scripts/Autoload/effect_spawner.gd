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
	

	
