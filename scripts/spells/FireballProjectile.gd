# FireballProjectile.gd
# Fireball projectile with physics and explosion mechanics

class_name FireballProjectile
extends RigidBody3D

# Projectile properties
var direction: Vector3
var damage: int = 20
var explosion_radius: float = 3.0
var travel_speed: float = 15.0
var max_distance: float = 30.0  # Increased from 20 to 30
var traveled_distance: float = 0.0

# Track last position for distance calculation
var last_position: Vector3
var spawn_time: float = 0.0

func _ready():
	# Record spawn time
	spawn_time = Time.get_unix_time_from_system()
	
	# Set collision layers properly
	collision_layer = 16  # Projectile layer (layer 5)
	collision_mask = 1    # Only collide with world geometry (layer 1), NOT player (layer 2)
	
	# Configure physics
	gravity_scale = 0.1   # Slight gravity for realistic arc
	lock_rotation = true  # Prevent spinning
	
	# Initialize distance tracking from spawn point
	traveled_distance = 0.0
	last_position = global_position
	
	# Set up physics - wait one frame to ensure direction is set
	call_deferred("setup_movement")
	
	# Set up collision detection for explosion
	body_entered.connect(_on_collision)
	
	# Set up auto-cleanup after max distance
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = max_distance / travel_speed + 2.0  # More generous time buffer
	cleanup_timer.timeout.connect(_on_max_distance_reached)
	add_child(cleanup_timer)
	cleanup_timer.start()

func setup_movement():
	"""Setup projectile movement after direction is set"""
	if direction.length() > 0:
		linear_velocity = direction.normalized() * travel_speed
		print("FireballProjectile: Setup complete - Pos=", global_position, " Dir=", direction.normalized(), " Vel=", linear_velocity)
		
		# Reset distance tracking from this point
		traveled_distance = 0.0
		last_position = global_position
	else:
		print("FireballProjectile: ERROR - No direction set!")
		# Default forward direction
		linear_velocity = Vector3(0, 0, -travel_speed)

func _physics_process(delta):
	# Track distance traveled more accurately
	var current_position = global_position
	var distance_this_frame = last_position.distance_to(current_position)
	
	# Only count distance if we're actually moving (prevents accumulation when stuck)
	if distance_this_frame > 0.01:  # Minimum movement threshold
		traveled_distance += distance_this_frame
	
	last_position = current_position
	
	# Debug: Print velocity and position occasionally
	if fmod(get_time_alive(), 1.0) < delta:  # Every 1 second instead of 0.5
		print("FireballProjectile: Pos=", global_position, " Vel=", linear_velocity, " Distance=", traveled_distance, " Time=", get_time_alive())
	
	# Check if max distance reached
	if traveled_distance >= max_distance:
		print("FireballProjectile: Max distance reached: ", traveled_distance, " (limit: ", max_distance, ")")
		_on_max_distance_reached()

func _on_collision(body):
	"""Handle collision with any body"""
	if body != self and body.name != "Player":  # Don't collide with self or player directly
		print("FireballProjectile: Collision with ", body.name, " at position ", global_position)
		explode_at_position(global_position)

func _on_max_distance_reached():
	"""Handle max distance reached"""
	explode_at_position(global_position)

func explode_at_position(pos: Vector3):
	"""Create explosion effect and deal area damage"""
	print("FireballProjectile: Exploding at ", pos, " with ", damage, " damage")
	
	# Create explosion effects
	create_explosion_effects(pos)
	
	# Deal area damage
	deal_area_damage(pos, explosion_radius, damage)
	
	# Remove projectile
	queue_free()

func create_explosion_effects(pos: Vector3):
	"""Create visual and audio effects for explosion"""
	var explosion_effects = preload("res://scripts/spells/FireballEffects.gd").new()
	explosion_effects.create_explosion_effect(pos, explosion_radius)
	print("FireballProjectile: Created explosion effects at ", pos)

func deal_area_damage(center: Vector3, radius: float, damage_amount: int):
	"""Deal damage to all enemies in explosion radius"""
	var scene_tree = get_tree()
	var enemies = scene_tree.get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if enemy is Node3D:
			var distance = center.distance_to(enemy.global_position)
			if distance <= radius:
				# Deal damage to enemy
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage_amount)
					print("FireballProjectile: Dealt ", damage_amount, " damage to ", enemy.name)
	
	# Check if player is in explosion (friendly fire protection)
	var players = scene_tree.get_nodes_in_group("players")
	for player in players:
		if player is Node3D:
			var distance = center.distance_to(player.global_position)
			if distance <= radius:
				# Only damage player if fireball has traveled sufficient distance AND time
				if traveled_distance > 4.0 and get_time_alive() > 0.3:  # Must travel 4 units AND exist for 0.3 seconds
					if player.has_method("take_damage"):
						var friendly_fire_damage = int(damage_amount / 3.0)  # Reduced friendly fire damage (1/3 instead of 1/2)
						player.take_damage(friendly_fire_damage)
						print("FireballProjectile: Friendly fire - dealt ", friendly_fire_damage, " damage to player")
				else:
					print("FireballProjectile: Prevented self-damage - fireball too close to caster (distance: ", traveled_distance, ", time: ", get_time_alive(), ")")

func get_time_alive() -> float:
	"""Get how long this projectile has existed"""
	return Time.get_unix_time_from_system() - spawn_time
