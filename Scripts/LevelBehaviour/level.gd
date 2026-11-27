class_name Level
extends Node2D

## Next level scene to load on victory (set in editor or by level selector)
@export var next_level: PackedScene
## End screen scene to show on win/lose
@export var end_screen_scene: PackedScene

var remaining := 0
var player: Tank
var _game_ended := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(end_screen_scene)
	
	# Count enemies in the "enemy" group and connect to their destroy signals
	var enemies = get_tree().get_nodes_in_group("enemy")
	remaining = enemies.size()
	for e in enemies:
		var tank = e as Tank
		if tank:
			tank.destroy.connect(_on_enemy_destroy)

	# Track the player tank in the "player" group for defeat condition
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Tank
		if player:
			player.destroy.connect(_on_player_destroy)

func _on_enemy_destroy(tank: Tank) -> void:
	remaining -= 1
	print(tank.name, " destroyed! Remaining: ", remaining)

func _on_player_destroy(tank: Tank) -> void:
	lose()

func win() -> void:
	if _game_ended:
		return
	_game_ended = true
	print("Level won!")
	_show_end_screen("VICTORY")

func lose() -> void:
	if _game_ended:
		return
	_game_ended = true
	print("Level lost!")
	_show_end_screen("MISSION FAILED")

func _show_end_screen(result: String) -> void:
	get_tree().change_scene_to_packed(end_screen_scene)
