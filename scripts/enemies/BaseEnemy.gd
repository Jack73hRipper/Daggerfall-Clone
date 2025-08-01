# BaseEnemy.gd
# Base class for all enemies in the dungeon crawler

class_name BaseEnemy
extends CharacterBody3D

# Enemy Properties
@export var enemy_name: String = "Unknown Enemy"
@export var max_health: int = 20
@export var damage: int = 5
@export var move_speed: float = 2.0
@export var detection_range: float = 8.0
@export var attack_range: float = 2.0
@export var experience_reward: int = 10
@export var attack_cooldown: float = 1.0

# Current state
var current_health: int
var player: Node3D
var last_attack_time: float = 0.0
var attack_state_time: float = 0.0  # Track time in attack state

# AI States
enum AIState {
	IDLE,
	CHASE,
	ATTACK,
	DEAD
}

var current_state: AIState = AIState.IDLE

# Node references
@onready var model: Node3D = $EnemyModel
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var detection_area: Area3D = $DetectionArea
@onready var attack_area: Area3D = $AttackArea
@onready var animation_player: AnimationPlayer

func _ready():
	current_health = max_health
	print(enemy_name + " initializing...")
	
	setup_detection_area()
	setup_attack_area()
	setup_animations()
	
	# Connect area signals
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
		print(enemy_name + " connected detection area signals")
	else:
		print("ERROR: " + enemy_name + " has no DetectionArea!")
		
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.body_exited.connect(_on_attack_area_exited)
		print(enemy_name + " connected attack area signals")
	else:
		print("ERROR: " + enemy_name + " has no AttackArea!")
	
	print(enemy_name + " initialization complete")

func setup_animations():
	"""Find and setup animation player from the model"""
	if model:
		# Look for AnimationPlayer in the model hierarchy
		animation_player = find_animation_player(model)
		if animation_player:
			print("Found AnimationPlayer for ", enemy_name)
			print("Available animations: ", animation_player.get_animation_list())
			# Start with idle animation if available
			play_animation("idle")
		else:
			print("No AnimationPlayer found for ", enemy_name)
			# Debug the model hierarchy to see what's available
			debug_model_hierarchy(model, 0)

func find_animation_player(node: Node) -> AnimationPlayer:
	"""Recursively find AnimationPlayer in node hierarchy"""
	if node is AnimationPlayer:
		return node as AnimationPlayer
	
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	
	return null

func debug_model_hierarchy(node: Node, depth: int):
	"""Debug model hierarchy to find animation nodes"""
	var indent = "  ".repeat(depth)
	print(indent + "Node: " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		debug_model_hierarchy(child, depth + 1)

func play_animation(anim_name: String):
	"""Play animation if AnimationPlayer exists"""
	if not animation_player:
		return
	
	# Map generic animation names to specific model animations
	var actual_anim_name = map_animation_name(anim_name)
	
	if animation_player.has_animation(actual_anim_name):
		animation_player.play(actual_anim_name)
	else:
		# Fallback to first available animation
		var animations = animation_player.get_animation_list()
		if animations.size() > 0:
			animation_player.play(animations[0])

func map_animation_name(generic_name: String) -> String:
	"""Map generic animation names to model-specific names"""
	var animations = animation_player.get_animation_list()
	
	match generic_name:
		"idle":
			# Try different idle animation names
			for anim in animations:
				if "idle" in anim.to_lower() or "Idle" in anim:
					return anim
		"walk":
			# Try different walking animation names
			for anim in animations:
				if "walk" in anim.to_lower() or "Walk" in anim or "running" in anim.to_lower() or "Running" in anim:
					return anim
		"attack":
			# Try different attack animation names
			for anim in animations:
				if "attack" in anim.to_lower() or "Attack" in anim or "melee" in anim.to_lower() or "Melee" in anim:
					return anim
		"death":
			# Try different death animation names
			for anim in animations:
				if "death" in anim.to_lower() or "Death" in anim or "die" in anim.to_lower():
					return anim
		"fly":
			# For flying enemies like bats
			for anim in animations:
				if "fly" in anim.to_lower() or "Flying" in anim:
					return anim
	
	# If no match found, return the generic name
	return generic_name

func _physics_process(delta):
	if current_state == AIState.DEAD:
		return
	
	# Apply gravity for grounded enemies (not bats)
	if not is_flying_enemy():
		velocity.y += ProjectSettings.get_setting("physics/3d/default_gravity") * delta * -1
	
	match current_state:
		AIState.IDLE:
			process_idle(delta)
		AIState.CHASE:
			process_chase(delta)
		AIState.ATTACK:
			process_attack(delta)
	
	# Apply movement
	move_and_slide()

func is_flying_enemy() -> bool:
	"""Check if this enemy type flies"""
	return get_script() and get_script().resource_path.ends_with("BatEnemy.gd")

func setup_detection_area():
	"""Setup detection area for finding player"""
	if not detection_area:
		print("ERROR: No DetectionArea found for " + enemy_name)
		return
		
	var detection_collision = detection_area.get_node("CollisionShape3D")
	if not detection_collision:
		print("ERROR: No CollisionShape3D found in DetectionArea for " + enemy_name)
		return
		
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = detection_range
	detection_collision.shape = sphere_shape
	
	# Ensure the area is monitoring and can detect the player
	detection_area.monitoring = true
	detection_area.collision_layer = 0  # Don't collide with anything
	detection_area.collision_mask = 2   # Detect layer 2 (player is on layer 2)
	
	print(enemy_name + " detection area setup with radius: " + str(detection_range))

func setup_attack_area():
	"""Setup attack area for combat"""
	if not attack_area:
		print("ERROR: No AttackArea found for " + enemy_name)
		return
		
	var attack_collision = attack_area.get_node("CollisionShape3D")
	if not attack_collision:
		print("ERROR: No CollisionShape3D found in AttackArea for " + enemy_name)
		return
		
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = attack_range  # Use proper attack range, not detection range
	attack_collision.shape = sphere_shape
	
	# Ensure the area is monitoring and can detect the player
	attack_area.monitoring = true
	attack_area.collision_layer = 0  # Don't collide with anything
	attack_area.collision_mask = 2   # Detect layer 2 (player is on layer 2)
	
	print(enemy_name + " attack area setup with radius: " + str(attack_range))

func process_idle(_delta):
	"""Process idle state - just wait for player"""
	# Stop horizontal movement
	velocity.x = 0
	velocity.z = 0
	
	# Play idle animation if not already playing
	if animation_player and not animation_player.is_playing():
		play_animation("idle")

func process_chase(_delta):
	"""Process chase state - move toward player"""
	if not player:
		current_state = AIState.IDLE
		return
	
	# Play movement animation
	play_animation("walk")
	
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0  # Keep movement on ground plane
	
	# Set horizontal velocity
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# Smoothly rotate to face player instead of snapping with look_at
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		# Add model-specific rotation offsets
		target_rotation += get_model_rotation_offset()
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * _delta)

func get_model_rotation_offset() -> float:
	"""Get rotation offset for different enemy models"""
	if "Slime" in enemy_name:
		return PI * 1.5  # 270 degrees (-90 degrees) - try different angle
	elif "Bat" in enemy_name:
		return 0.0  # No offset - try default orientation first
	else:
		return 0.0  # No offset for skeleton and other models

func process_attack(_delta):
	"""Process attack state - attack player when ready"""
	if not player:
		current_state = AIState.IDLE
		attack_state_time = 0.0
		return
	
	attack_state_time += _delta
	
	# Stop horizontal movement when attacking
	velocity.x = 0
	velocity.z = 0
	
	# Check if player is still in attack range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > attack_range * 1.2:  # Small buffer to prevent flickering
		current_state = AIState.CHASE
		attack_state_time = 0.0
		print(enemy_name + " player moved away, returning to CHASE")
		return
	
	# Timeout mechanism - if stuck in attack state too long, go back to chase
	if attack_state_time > 5.0:  # 5 second timeout
		current_state = AIState.CHASE
		attack_state_time = 0.0
		print(enemy_name + " attack state timeout, returning to CHASE")
		return
	
	# Attack if cooldown is ready
	var time_since_last = Time.get_ticks_msec() / 1000.0
	
	if time_since_last - last_attack_time >= attack_cooldown:
		perform_attack()
		last_attack_time = time_since_last

func perform_attack():
	"""Execute attack on player"""
	# Play attack animation
	play_animation("attack")
	
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		print(enemy_name + " attacks for " + str(damage) + " damage!")

func take_damage(amount: int):
	"""Take damage and handle death"""
	current_health -= amount
	print(enemy_name + " takes " + str(amount) + " damage! Health: " + str(current_health) + "/" + str(max_health))
	
	if current_health <= 0:
		die()

func die():
	"""Handle enemy death"""
	current_state = AIState.DEAD
	print(enemy_name + " has been defeated!")
	
	# Play death animation
	play_animation("death")
	
	# Give player experience
	if player and player.has_method("gain_experience"):
		player.gain_experience(experience_reward)
	
	# Remove from scene after a delay to allow death animation
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _on_detection_area_entered(body):
	"""Player entered detection range"""
	print(enemy_name + " detected something: " + body.name + " (groups: " + str(body.get_groups()) + ")")
	if body.is_in_group("player"):
		player = body
		if current_state == AIState.IDLE:
			current_state = AIState.CHASE
			print(enemy_name + " started chasing player!")

func _on_detection_area_exited(body):
	"""Player left detection range"""
	if body.is_in_group("player"):
		print(enemy_name + " lost sight of player")
		player = null
		current_state = AIState.IDLE

func _on_attack_area_entered(body):
	"""Player entered attack range"""
	if body.is_in_group("player") and current_state == AIState.CHASE:
		current_state = AIState.ATTACK
		attack_state_time = 0.0  # Reset attack timer
		print(enemy_name + " entered ATTACK state")

func _on_attack_area_exited(body):
	"""Player left attack range"""
	if body.is_in_group("player") and current_state == AIState.ATTACK:
		current_state = AIState.CHASE
		attack_state_time = 0.0  # Reset attack timer
		print(enemy_name + " left ATTACK state, back to CHASE")
