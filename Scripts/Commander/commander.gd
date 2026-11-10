class_name Commander
extends Node2D

@warning_ignore("unused_signal")
signal fire()

var vehicle: PhysicsBody2D
var tank_input := Vector2()
## tell turret where to aim
var commander_target := Vector2()
## turret's actual target, not where to aim
var turret_target := Vector2()
