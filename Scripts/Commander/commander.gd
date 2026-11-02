class_name Commander
extends Node2D

signal fire()

var vehicle: PhysicsBody2D
var tank_input := Vector2()
var commander_target := Vector2()
var turret_target := Vector2()
