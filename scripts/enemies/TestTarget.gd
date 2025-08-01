# TestTarget.gd
# Simple test target for combat system testing

class_name TestTarget
extends StaticBody3D

@export var max_health: int = 30
var current_health: int

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")

func take_damage(damage: int) -> void:
	"""Take damage and handle destruction"""
	current_health -= damage
	print("TestTarget took ", damage, " damage! Health: ", current_health, "/", max_health)
	
	if current_health <= 0:
		print("TestTarget destroyed!")
		queue_free()
