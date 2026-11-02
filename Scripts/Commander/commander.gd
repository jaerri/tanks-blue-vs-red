class_name Commander
extends Node2D

signal fire()

var vehicle: PhysicsBody2D
var tank_input := Vector2()
## tell turret where to aim
var commander_target := Vector2()
## turret's actual target, not where to aim
var turret_target := Vector2()
