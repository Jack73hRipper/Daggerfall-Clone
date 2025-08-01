# AnimatedTarget.gd
# Enhanced test target with character animations

class_name AnimatedTarget
extends StaticBody3D

@export var max_health: int = 30
var current_health: int

# Animation references
@onready var animation_player: AnimationPlayer
@onready var character_model: Node3D

# Animation state
var is_playing_hit_animation: bool = false
var is_dead: bool = false

# Movement and patrol system
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var move_speed: float = 1.5  # Slower speed to match animation better
var patrol_wait_time: float = 2.0
var is_patrolling: bool = false
var patrol_timer: float = 0.0
var is_moving_to_patrol: bool = false

# Detection area for player proximity
var player_detection_area: Area3D
var player_nearby: bool = false

# Combat system
var attack_damage: int = 10
var attack_range: float = 2.0
var attack_cooldown: float = 1.5  # Reduced for more frequent attacks
var last_attack_time: float = 0.0
var is_attacking: bool = false
var combat_state: String = "idle"  # idle, pursuing, attacking, circling
var circle_timer: float = 0.0
var circle_direction: int = 1  # 1 or -1 for clockwise/counterclockwise

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	
	# Find the character model (first child that's not AnimationPlayer or CollisionShape3D)
	for child in get_children():
		if child is not AnimationPlayer and child is not CollisionShape3D and child is not Area3D:
			character_model = child
			break
	
	# Find the AnimationPlayer inside the character model
	if character_model:
		animation_player = find_animation_player_in_model(character_model)
		if animation_player:
			print("SUCCESS: Found AnimationPlayer in ", name)
			print("Available animations: ", animation_player.get_animation_list())
			# Test if we can play an animation immediately
			var animations = animation_player.get_animation_list()
			if animations.size() > 0:
				print("Testing first animation: ", animations[0])
		else:
			print("ERROR: No AnimationPlayer found in character model for ", name)
			# Debug: print the structure of the character model
			print("Character model structure:")
			debug_print_node_structure(character_model, 0)
	else:
		print("ERROR: No character model found for ", name)
	
	# Set up player detection area
	setup_player_detection()
	
	# Start with idle animation
	await get_tree().process_frame  # Wait a frame for everything to be ready
	
	# Debug: Log spawn position
	print(name, " spawned at position: ", global_position)
	
	play_animation("Idle")
	
	# Set up patrol points around the spawn location
	setup_patrol_points()
	
	# Start patrolling after a short delay
	await get_tree().create_timer(1.0).timeout
	start_patrol()

func _physics_process(delta: float) -> void:
	"""Handle movement and patrol logic"""
	if is_dead:
		return
	
	if player_nearby and not is_playing_hit_animation:
		# Handle combat behavior
		handle_combat_behavior(delta)
		# Stop patrolling when player is nearby
		is_patrolling = false
		is_moving_to_patrol = false
	elif not player_nearby and patrol_points.size() > 0 and not is_playing_hit_animation:
		# Reset combat state and resume patrolling
		combat_state = "idle"
		if not is_patrolling:
			start_patrol()
		else:
			update_patrol_movement(delta)

func setup_patrol_points() -> void:
	"""Create patrol points around the spawn location"""
	var spawn_pos = global_position
	patrol_points.clear()
	
	# Create 3-4 patrol points in a small area around spawn
	var patrol_radius = 4.0
	var num_points = 3
	
	for i in num_points:
		var angle = (i * 2.0 * PI) / num_points
		var offset = Vector3(
			cos(angle) * patrol_radius,
			0,  # Keep same Y level
			sin(angle) * patrol_radius
		)
		patrol_points.append(spawn_pos + offset)
	
	print("Set up ", patrol_points.size(), " patrol points for ", name)

func start_patrol() -> void:
	"""Begin patrolling behavior"""
	if patrol_points.size() == 0:
		return
		
	is_patrolling = true
	current_patrol_index = 0
	is_moving_to_patrol = true
	play_animation("Walk")
	print(name, " started patrolling")

func update_patrol_movement(delta: float) -> void:
	"""Update patrol movement"""
	if not is_patrolling or patrol_points.size() == 0:
		return
	
	var target_point = patrol_points[current_patrol_index]
	var distance_to_target = global_position.distance_to(target_point)
	
	if is_moving_to_patrol:
		if distance_to_target < 0.5:  # Reached patrol point
			is_moving_to_patrol = false
			patrol_timer = patrol_wait_time
			play_animation("Idle")
			print(name, " reached patrol point ", current_patrol_index)
		else:
			# Move towards target
			var direction = (target_point - global_position).normalized()
			var new_position = global_position + direction * move_speed * delta
			# Temporarily disable ground snapping to debug positioning
			# new_position.y = snap_to_ground(new_position)
			global_position = new_position
			
			# Ensure walk animation is playing
			if animation_player and animation_player.current_animation != "Walk":
				play_animation("Walk")
			
			# Face movement direction (rotate around Y axis only)
			if direction.length() > 0.1:
				var target_rotation = atan2(direction.x, direction.z)
				rotation.y = target_rotation
	else:
		# Waiting at patrol point
		patrol_timer -= delta
		if patrol_timer <= 0:
			# Move to next patrol point
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			is_moving_to_patrol = true
			play_animation("Walk")
			print(name, " moving to patrol point ", current_patrol_index)

func handle_combat_behavior(delta: float) -> void:
	"""Handle dynamic combat behavior"""
	if is_attacking:
		return
	
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Face the player (with some smoothing)
	if direction_to_player.length() > 0.1:
		var target_rotation = atan2(direction_to_player.x, direction_to_player.z)
		var rotation_diff = target_rotation - rotation.y
		# Normalize rotation difference to -PI to PI
		while rotation_diff > PI:
			rotation_diff -= 2 * PI
		while rotation_diff < -PI:
			rotation_diff += 2 * PI
		
		# Smooth rotation
		rotation.y += rotation_diff * delta * 3.0
	
	# Decide combat behavior based on distance and state
	if distance_to_player <= attack_range:
		# Close enough to attack
		if can_attack():
			combat_state = "attacking"
			attempt_attack_player()
		else:
			# Can't attack yet, circle around or back up slightly
			combat_state = "circling"
			circle_around_player(player, delta)
	elif distance_to_player <= attack_range + 1.0:
		# Just outside attack range, circle and look for openings
		combat_state = "circling"
		circle_around_player(player, delta)
	else:
		# Too far, pursue the player
		combat_state = "pursuing"
		pursue_player(player, delta)

func can_attack() -> bool:
	"""Check if enough time has passed since last attack"""
	var current_time = Time.get_ticks_msec() / 1000.0
	return current_time - last_attack_time >= attack_cooldown

func circle_around_player(player: Node3D, delta: float) -> void:
	"""Circle around the player in combat"""
	circle_timer += delta
	
	# Change direction occasionally for unpredictability
	if circle_timer > randf_range(2.0, 4.0):
		circle_direction *= -1
		circle_timer = 0.0
	
	# Calculate circling movement
	var to_player = player.global_position - global_position
	var perpendicular = Vector3(to_player.z, 0, -to_player.x).normalized()
	var circle_move = perpendicular * circle_direction * move_speed * 0.7 * delta
	
	# Add slight forward/backward movement randomly
	var forward = to_player.normalized() * randf_range(-0.3, 0.1) * move_speed * delta
	
	# Apply movement but maintain ground level
	var new_position = global_position + circle_move + forward
	# Temporarily disable ground snapping to debug positioning
	# new_position.y = snap_to_ground(new_position)
	global_position = new_position
	
	# Play appropriate animation
	if animation_player and animation_player.current_animation != "Walk":
		play_animation("Walk")

func pursue_player(player: Node3D, delta: float) -> void:
	"""Move toward the player"""
	var direction = (player.global_position - global_position).normalized()
	var new_position = global_position + direction * move_speed * 0.8 * delta
	# Temporarily disable ground snapping to debug positioning
	# new_position.y = snap_to_ground(new_position)
	global_position = new_position
	
	# Play appropriate animation
	if animation_player and animation_player.current_animation != "Walk":
		play_animation("Walk")

func snap_to_ground(position: Vector3) -> float:
	"""Use raycast to find ground level and return proper Y coordinate"""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		Vector3(position.x, position.y + 2.0, position.z),  # Start above
		Vector3(position.x, position.y - 3.0, position.z)   # End below
	)
	query.collision_mask = 1  # Only collide with world geometry (layer 1)
	
	var result = space_state.intersect_ray(query)
	if result:
		# Found ground, return ground level
		print(name, " found ground at Y=", result.position.y, " for position ", position)
		return result.position.y
	else:
		# No ground found, keep current Y or use a default
		print(name, " no ground found at position ", position, " - keeping Y=", position.y)
		return position.y

func setup_player_detection() -> void:
	"""Create detection area to sense when player is nearby"""
	player_detection_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 3.0  # Smaller radius for closer combat
	
	collision_shape.shape = sphere_shape
	player_detection_area.add_child(collision_shape)
	add_child(player_detection_area)
	
	# Set collision mask to detect player on layer 2
	player_detection_area.collision_mask = 2  # Detect layer 2 (player)
	player_detection_area.collision_layer = 0  # Don't put detection area on any layer
	
	# Connect signals
	player_detection_area.body_entered.connect(_on_player_entered)
	player_detection_area.body_exited.connect(_on_player_exited)
	
	print(name, " set up player detection with collision mask 2")

func find_animation_player_in_model(node: Node) -> AnimationPlayer:
	"""Recursively find AnimationPlayer in the character model"""
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var result = find_animation_player_in_model(child)
		if result:
			return result
	
	return null

func debug_print_node_structure(node: Node, depth: int) -> void:
	"""Print the node structure for debugging"""
	var indent = ""
	for i in depth:
		indent += "  "
	print(indent, node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		debug_print_node_structure(child, depth + 1)

func get_available_animations() -> Array:
	"""Get list of available animation names"""
	var animations = []
	if animation_player:
		animations = animation_player.get_animation_list()
	return animations

func play_animation(anim_name: String, force: bool = false) -> void:
	"""Play an animation if it exists"""
	if is_dead and not force:
		return
		
	if not animation_player:
		print("No animation player available for ", name)
		return
		
	var available_animations = get_available_animations()
	if anim_name in available_animations:
		animation_player.play(anim_name)
		
		# Enable looping for movement animations
		if anim_name in ["Walk", "Run"]:
			var animation = animation_player.get_animation(anim_name)
			if animation:
				animation.loop_mode = Animation.LOOP_LINEAR
		
		print("Playing animation: ", anim_name, " on ", name)
	else:
		print("Animation '", anim_name, "' not found in ", name, ". Available: ", available_animations)

func _on_player_entered(body: Node3D) -> void:
	"""Handle when player enters detection area"""
	if body.is_in_group("players") and not is_dead:
		player_nearby = true
		print(name, " detected player - entering combat mode")

func _on_player_exited(body: Node3D) -> void:
	"""Handle when player leaves detection area"""
	if body.is_in_group("players"):
		player_nearby = false
		is_attacking = false
		if not is_dead:
			play_animation("Idle")
		print(name, " lost player - exiting combat mode")

func attempt_attack_player() -> void:
	"""Try to attack the player if in range and cooldown is ready"""
	if is_attacking or is_dead or is_playing_hit_animation:
		return
	
	if not can_attack():
		return
	
	# Find player
	var player = get_tree().get_first_node_in_group("players")
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= attack_range:
		perform_attack(player)

func perform_attack(target: Node3D) -> void:
	"""Execute attack on target"""
	if is_attacking or is_dead:
		return
	
	is_attacking = true
	
	# Add slight delay for more natural feel
	await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
	
	# Choose attack animation based on available animations
	var available_animations = get_available_animations()
	var attack_animation = ""
	
	if "Sword_Attack" in available_animations:
		attack_animation = "Sword_Attack"
	elif "Attack" in available_animations:
		attack_animation = "Attack"
	elif "Attacking" in available_animations:
		attack_animation = "Attacking"
	
	if attack_animation != "":
		play_animation(attack_animation)
		print(name, " attacking with ", attack_animation)
		
		# Deal damage after a variable delay for more natural timing
		await get_tree().create_timer(randf_range(0.4, 0.7)).timeout
		
		# Check if target is still in range
		if target and global_position.distance_to(target.global_position) <= attack_range * 1.2:
			if target.has_method("take_damage"):
				# Vary damage slightly for more organic feel
				var actual_damage = attack_damage + randi_range(-2, 2)
				target.take_damage(actual_damage)
				print(name, " dealt ", actual_damage, " damage to player")
		
		# Wait for attack animation to finish with some variation
		await get_tree().create_timer(randf_range(0.8, 1.2)).timeout
	else:
		print(name, " has no attack animation available")
		await get_tree().create_timer(1.0).timeout
	
	is_attacking = false
	
	# Update attack cooldown with slight randomization
	last_attack_time = Time.get_ticks_msec() / 1000.0
	attack_cooldown = randf_range(1.2, 2.0)  # Vary cooldown for unpredictability

func take_damage(damage: int) -> void:
	"""Take damage and handle reactions"""
	if is_dead:
		return
		
	current_health -= damage
	print("AnimatedTarget took ", damage, " damage! Health: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
	else:
		play_hit_reaction()

func play_hit_reaction() -> void:
	"""Play hit reaction animation"""
	if is_playing_hit_animation or is_dead:
		return
		
	is_playing_hit_animation = true
	
	# Play receive hit animation
	play_animation("RecieveHit")
	
	# Wait for animation to finish, then return to appropriate state
	await get_tree().create_timer(1.0).timeout
	
	is_playing_hit_animation = false
	
	if not is_dead:
		if player_nearby:
			var available_animations = get_available_animations()
			if "Attacking_Idle" in available_animations:
				play_animation("Attacking_Idle")
			else:
				play_animation("Idle")
		else:
			play_animation("Idle")

func die() -> void:
	"""Handle death sequence"""
	if is_dead:
		return
		
	is_dead = true
	print("AnimatedTarget destroyed with style!")
	
	# Play death animation
	play_animation("Death", true)
	
	# Wait for death animation to finish
	await get_tree().create_timer(3.0).timeout
	
	# Remove from scene
	queue_free()
