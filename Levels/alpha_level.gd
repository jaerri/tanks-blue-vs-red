extends Node2D

var remaining := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		remaining += 1
		e.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	remaining -= 1
	if remaining <= 0:
		win()
		
func win() -> void:
	await get_tree().create_timer(1).timeout # wait 1 sec
	get_tree().change_scene_to_file("res://UI/end_screen.tscn")
