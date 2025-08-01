# MagicMissile.gd
# Magic Missile projectile with homing behavior

class_name MagicMissile
extends Area3D

# Missile properties
var target: Node3D
var damage: int = 12
var homing_speed: float = 10.0
var max_lifetime: float = 5.0

# Movement
var velocity: Vector3
var lifetime: float = 0.0

func _ready():
	# Set up collision detection
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Set up lifetime timer
	var timer = Timer.new()
	timer.wait_time = max_lifetime
	timer.timeout.connect(_on_max_lifetime_reached)
	add_child(timer)
	timer.start()

func _physics_process(delta):
	lifetime += delta
	
	if target and is_instance_valid(target):
		# Calculate direction to target
		var direction = (target.global_position - global_position).normalized()
		
		# Update velocity with homing
		velocity = velocity.lerp(direction * homing_speed, 0.1)
		
		# Move towards target
		global_position += velocity * delta
		
		# Rotate to face direction
		if velocity.length() > 0.1:
			look_at(global_position + velocity.normalized(), Vector3.UP)
	else:
		# No target, move in straight line
		global_position += velocity * delta

func _on_body_entered(body):
	"""Handle collision with enemy"""
	if body == target or body.is_in_group("enemies"):
		hit_target(body)

func _on_area_entered(area):
	"""Handle collision with enemy detection areas"""
	var enemy = area.get_parent()
	if enemy == target or enemy.is_in_group("enemies"):
		hit_target(enemy)

func hit_target(hit_body):
	"""Deal damage and destroy missile"""
	if hit_body.has_method("take_damage"):
		hit_body.take_damage(damage)
		print("MagicMissile: Hit ", hit_body.name, " for ", damage, " damage")
	
	# Create hit effects
	create_hit_effects()
	
	# Destroy missile
	queue_free()

func create_hit_effects():
	"""Create visual effects on hit"""
	var impact_effects = preload("res://scripts/spells/MagicMissileEffects.gd").new()
	impact_effects.create_impact_effect(global_position, target)
	print("MagicMissile: Created impact effects")

func _on_max_lifetime_reached():
	"""Handle max lifetime reached"""
	print("MagicMissile: Max lifetime reached, destroying")
	queue_free()
