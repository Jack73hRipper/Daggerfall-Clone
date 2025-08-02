# PlayerController.gd
# First-person player controller with Doom-style responsive movement
# Designed for single-player with future multiplayer support

class_name PlayerController
extends CharacterBody3D

# Movement settings
@export var base_speed: float = 5.0
@export var sprint_speed: float = 12.0  # Increased from 8.0 for more noticeable difference
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0
@export var friction: float = 10.0

# Mouse look settings
@export var mouse_sensitivity: float = 0.002
@export var vertical_look_limit: float = 1.5  # Radians (about 85 degrees)

# Camera zoom settings
@export var min_zoom_distance: float = 0.0     # First person (camera at head)
@export var max_zoom_distance: float = 8.0     # Third person max distance
@export var zoom_speed: float = 0.5            # How fast to zoom per scroll
@export var zoom_smoothing: float = 10.0       # Smooth camera movement
var current_zoom_distance: float = 0.0         # Current camera distance
var target_zoom_distance: float = 0.0          # Target distance for smooth transitions

# Camera references
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

# Weapon holding system
@onready var weapon_hold: Node3D = $Head/Camera3D/WeaponHold

# Combat system
var is_attacking: bool = false
var attack_tween: Tween
var camera_shake_tween: Tween
var current_weapon: Node = null
var current_weapon_pivot: Node3D = null  # Pivot point for natural weapon swinging
var weapon_hit_area: Area3D
var current_attack_index: int = 0  # Track which attack in the sequence

# Character progression systems
var character_stats: CharacterStats
var equipment_manager: EquipmentManager
var inventory: Inventory

# Magic system
var spell_system: SpellSystem

# Player health system (now managed by CharacterStats)
var max_health: int = 100  # Will be overridden by character_stats
var current_health: int = 100  # Will be overridden by character_stats

# Player state
var is_sprinting: bool = false
var can_jump: bool = true

# Debug noclip mode
var noclip_enabled: bool = false
var noclip_speed: float = 10.0

# Interaction system
var nearby_items: Array = []
var carried_item: Node = null  # Will be BaseItem when picked up
@export var interaction_range: float = 2.0
@export var carry_distance: float = 1.5

# Input handling
var input_vector: Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Initialize character progression systems
	setup_character_progression()
	
	# Initialize spell system
	setup_spell_system()
	
	# Capture mouse cursor for first-person controls
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Add player to group for item detection
	add_to_group("player")  # Add to player group for enemy detection
	add_to_group("players")  # Keep existing group for compatibility
	
	# Set up collision layers and masks
	collision_layer = 2    # Player is on layer 2
	collision_mask = 1     # Player collides with layer 1 (world geometry)

func _input(event: InputEvent) -> void:
	# Handle escape key to show escape menu (works even when paused)
	if event.is_action_pressed("ui_cancel"):
		var escape_menu = _find_escape_menu()
		if escape_menu and not escape_menu.visible:
			escape_menu.show_menu()
		return  # Don't process other input when escape menu is shown
	
	# Don't process other input when game is paused
	if get_tree().paused:
		return
	
	# Handle mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event.relative)
	
	# Handle mouse wheel for camera zoom
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(-1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(1.0)
	
	# Handle spell casting input
	if spell_system:
		spell_system.handle_spell_input(event)
	
	# Debug input handling
	if event.is_action_pressed("debug_damage"):
		take_damage(10)  # Test damage for HUD
	
	# Noclip toggle (F3 key for debugging)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		toggle_noclip()
	
	if event.is_action_pressed("character_menu"):
		print("Character menu key pressed - handled by TestSceneController")

func _physics_process(delta: float) -> void:
	# Don't process physics when game is paused
	if get_tree().paused:
		return
		
	handle_input()
	handle_movement(delta)
	handle_gravity(delta)
	update_carried_item_position()
	update_camera_position(delta)  # Handle smooth camera zoom transitions
	
	# Handle stamina regeneration and consumption
	handle_stamina_system(delta)
	
	# Debug: Check if we're falling through floors
	if global_position.y < -5:
		print("FALLING THROUGH WORLD! Teleporting back...")
		# Teleport back to a safe position
		global_position = Vector3(8, 5, 11)  # Known spawn location but higher
		velocity = Vector3.ZERO
	
	# Apply movement
	move_and_slide()

func handle_input() -> void:
	"""Process movement input"""
	# Get input vector for movement
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	# Debug: Print input when carrying item
	if carried_item and input_vector.length() > 0:
		pass  # Removed debug print
	
	# Normalize diagonal movement
	input_vector = input_vector.normalized()
	
	# Handle sprint - only allow if we have stamina
	var was_sprinting = is_sprinting
	var wants_to_sprint = Input.is_action_pressed("sprint")
	
	# Only sprint if player wants to AND has stamina
	if wants_to_sprint and character_stats and character_stats.current_stamina_points > 0:
		is_sprinting = true
	else:
		is_sprinting = false
	
	# Debug sprint state changes (only when state actually changes)
	if is_sprinting != was_sprinting:
		if is_sprinting:
			print("SPRINTING: Speed increased to ", sprint_speed)
		else:
			if wants_to_sprint and character_stats and character_stats.current_stamina_points <= 0:
				print("CAN'T SPRINT: Out of stamina!")
			else:
				print("WALKING: Speed back to ", base_speed)
	
	# Handle jump
	if Input.is_action_just_pressed("jump"):
		if noclip_enabled:
			# In noclip mode, use jump for upward movement (handled in handle_movement)
			pass
		elif is_on_floor():
			velocity.y = jump_velocity
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking and current_weapon:
		perform_attack()
	
	# Handle item interaction
	if Input.is_action_just_pressed("interact"):
		handle_interaction()
	
	# Handle torch lighting
	if Input.is_action_just_pressed("light_torch"):
		handle_torch_interaction()

func handle_mouse_look(mouse_delta: Vector2) -> void:
	"""Handle first-person camera movement"""
	if mouse_delta.length() > 0:
		# Horizontal rotation (Y-axis) - rotate the entire player
		rotate_y(-mouse_delta.x * mouse_sensitivity)
		
		# Vertical rotation (X-axis) - rotate only the head/camera
		head.rotate_x(-mouse_delta.y * mouse_sensitivity)
		
		# Clamp vertical look to prevent over-rotation
		head.rotation.x = clamp(head.rotation.x, -vertical_look_limit, vertical_look_limit)

func zoom_camera(zoom_delta: float) -> void:
	"""Handle camera zoom with mouse wheel"""
	target_zoom_distance += zoom_delta
	target_zoom_distance = clamp(target_zoom_distance, min_zoom_distance, max_zoom_distance)
	
	# User feedback
	if target_zoom_distance <= 0.1:
		print("Camera: First Person")
	else:
		print("Camera: Third Person (distance: ", round(target_zoom_distance * 10) / 10, ")")

func update_camera_position(delta: float) -> void:
	"""Smoothly move camera between first and third person positions"""
	# Smoothly interpolate current zoom to target
	current_zoom_distance = lerp(current_zoom_distance, target_zoom_distance, zoom_smoothing * delta)
	
	# Position camera based on zoom distance
	if current_zoom_distance <= 0.1:  # Essentially first person
		camera.position = Vector3.ZERO
		# Show weapon in first person
		if weapon_hold:
			weapon_hold.visible = true
	else:
		# Third person - move camera back and slightly up from head
		var height_offset = current_zoom_distance * 0.3  # Slight upward angle
		camera.position = Vector3(0, height_offset, current_zoom_distance)
		# Hide weapon in third person to avoid weird floating weapon effect
		if weapon_hold:
			weapon_hold.visible = false

func toggle_noclip() -> void:
	"""Toggle noclip mode for debugging torch placement"""
	noclip_enabled = !noclip_enabled
	
	if noclip_enabled:
		print("NOCLIP ENABLED - Press F3 to disable, use WASD + Space/Shift to fly")
		# Disable collision with world geometry
		set_collision_mask_value(1, false)
	else:
		print("NOCLIP DISABLED - Normal collision restored")
		# Restore collision with world geometry
		set_collision_mask_value(1, true)
		# Reset velocity to prevent floating
		velocity = Vector3.ZERO

func _find_escape_menu():
	"""Find the EscapeMenu in the scene tree"""
	# Try to find UI layer first
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		var escape_menu = ui_layer.get_node_or_null("EscapeMenu")
		if escape_menu:
			return escape_menu
	
	# Fallback: search by name in the current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("EscapeMenu", true, false)
	
	return null

func handle_movement(delta: float) -> void:
	"""Handle movement with noclip support"""
	if noclip_enabled:
		handle_noclip_movement(delta)
	else:
		handle_normal_movement(delta)

func handle_noclip_movement(delta: float) -> void:
	"""Handle 3D flying movement in noclip mode"""
	var target_velocity: Vector3 = Vector3.ZERO
	
	if input_vector.length() > 0 or Input.is_action_pressed("jump") or Input.is_action_pressed("sprint"):
		# Get movement vectors
		var forward: Vector3 = -transform.basis.z
		var right: Vector3 = transform.basis.x
		
		# Horizontal movement
		var horizontal_movement = (forward * input_vector.y + right * input_vector.x).normalized()
		target_velocity = horizontal_movement * noclip_speed
		
		# Vertical movement (Space to go up, Shift to go down)
		if Input.is_action_pressed("jump"):
			target_velocity.y = noclip_speed
		elif Input.is_action_pressed("sprint"):  # Using sprint as "down" key
			target_velocity.y = -noclip_speed
	
	# Smooth movement with acceleration
	velocity = velocity.move_toward(target_velocity, acceleration * 2.0 * delta)

func handle_normal_movement(delta: float) -> void:
	"""Handle horizontal movement with acceleration and friction"""
	# Calculate target velocity based on input and player orientation
	var target_velocity: Vector3 = Vector3.ZERO
	
	if input_vector.length() > 0:
		# Get the current speed (base or sprint)
		var current_speed: float = sprint_speed if is_sprinting else base_speed
		
		# Calculate movement direction relative to player facing
		var forward: Vector3 = -transform.basis.z
		var right: Vector3 = transform.basis.x
		
		# Apply input to get target direction
		var movement_direction: Vector3 = (forward * input_vector.y + right * input_vector.x).normalized()
		target_velocity = movement_direction * current_speed
	
	# Apply acceleration/deceleration
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z)
	
	if target_velocity.length() > 0:
		# Accelerate towards target velocity
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, friction * delta)
	
	# Update velocity (preserve Y component for gravity/jumping)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

func handle_gravity(delta: float) -> void:
	"""Apply gravity to the player (skip in noclip mode)"""
	if not noclip_enabled and not is_on_floor():
		velocity.y -= gravity * delta

func handle_stamina_system(delta: float) -> void:
	"""Handle stamina consumption and regeneration"""
	if not character_stats:
		return
	
	# Stamina consumption for sprinting
	if is_sprinting and input_vector.length() > 0:
		# Consume stamina while sprinting (20 stamina per second)
		var stamina_cost = 20.0 * delta
		var stamina_cost_int = max(1, int(stamina_cost))  # Ensure at least 1 stamina per frame when sprinting
		
		character_stats.use_stamina(stamina_cost_int)
	else:
		# Regenerate stamina when not sprinting (15 stamina per second)
		var stamina_regen = 15.0 * delta
		var stamina_regen_int = max(1, int(stamina_regen))  # Ensure at least 1 stamina regenerated per frame
		character_stats.restore_stamina(stamina_regen_int)
	
	# Mana regeneration over time (5 mana per second)
	var mana_regen = 5.0 * delta
	var mana_regen_int = max(1, int(mana_regen))  # Ensure at least 1 mana regenerated per frame
	character_stats.restore_mana(mana_regen_int)

func handle_interaction() -> void:
	"""Handle item pickup/drop interactions"""
	if carried_item:
		# Drop carried item
		drop_carried_item()
	else:
		# Try to pick up nearby item
		attempt_pickup()

func attempt_pickup() -> void:
	"""Try to pick up the nearest item"""
	var closest_item: Node = null
	var closest_distance: float = interaction_range
	
	# Find all items in the scene
	var items = get_tree().get_nodes_in_group("items")
	
	for item in items:
		if item.has_method("try_pickup"):
			var distance = global_position.distance_to(item.global_position)
			if distance < closest_distance and not item.is_being_carried:
				closest_distance = distance
				closest_item = item
	
	# Try to pick up the closest item
	if closest_item and closest_item.try_pickup(self):
		carried_item = closest_item
		# Attach weapon immediately after pickup
		call_deferred("attach_weapon_to_hold", carried_item)
		print("Picked up: ", closest_item.item_name)

func drop_carried_item() -> void:
	"""Drop the currently carried item"""
	if not carried_item:
		return
	
	# Detach from weapon hold first
	detach_weapon_from_hold(carried_item)
	
	# Calculate drop position in front of player
	var drop_position = global_position + get_forward_direction() * 1.0
	drop_position.y = global_position.y  # Keep at player height
	
	# Drop the item
	carried_item.drop_item(drop_position, Vector3.ZERO)
	carried_item = null
	print("Dropped item")

func handle_torch_interaction() -> void:
	"""Handle torch lighting/extinguishing"""
	if carried_item and carried_item.has_method("light_torch"):
		if carried_item.is_lit:
			if carried_item.extinguish_torch():
				print("Torch extinguished")
		else:
			if carried_item.light_torch():
				print("Torch lit!")
			else:
				print("Cannot light torch - no fuel remaining")
	else:
		print("No torch equipped to light")

func update_carried_item_position() -> void:
	"""Update position of carried item to follow player"""
	# This function is no longer needed since weapons are attached to camera
	# The attachment happens once during pickup, not every frame
	pass

func attach_weapon_to_hold(weapon: Node) -> void:
	"""Attach weapon to the camera weapon hold point"""
	if not weapon_hold:
		print("Warning: WeaponHold node not found!")
		return
	
	# Only attach if not already attached
	if weapon.get_parent() == weapon_hold:
		return
	
	# Disable physics while held
	weapon.freeze = true
	weapon.set_collision_layer_value(1, false)  # Disable collision with world
	weapon.set_collision_mask_value(1, false)   # Disable collision detection
	
	# Store original parent for later
	var original_parent = weapon.get_parent()
	
	# Reparent weapon to weapon hold point
	original_parent.remove_child(weapon)
	weapon_hold.add_child(weapon)
	
	# Reset transform to be relative to weapon hold
	weapon.transform = Transform3D.IDENTITY
	
	# Position weapon appropriately based on type
	position_weapon_in_hand(weapon)
	
	# Set as current weapon for combat
	current_weapon = weapon
	print("Equipped ", weapon.name, " for combat")

func position_weapon_in_hand(weapon: Node) -> void:
	"""Position weapon properly in the player's hand/view with proper pivot setup"""
	var item_type = "unknown"
	
	# Check if it's a weapon
	if weapon.has_method("get_weapon_info"):
		var weapon_info = weapon.get_weapon_info()
		item_type = weapon_info.get("weapon_type", "unknown")
	# Check if it's a torch
	elif weapon.has_method("get_torch_info"):
		item_type = "torch"
	# Check if it has general item info
	elif weapon.has_method("get_item_info"):
		var item_info = weapon.get_item_info()
		item_type = item_info.get("item_type", "unknown")
	
	# Create a pivot point at the grip (where player holds the item)
	# This allows natural movement from the grip point
	var pivot_node = Node3D.new()
	pivot_node.name = "ItemPivot"
	
	# Remove weapon from current parent and add pivot
	var current_parent = weapon.get_parent()
	current_parent.remove_child(weapon)
	current_parent.add_child(pivot_node)
	pivot_node.add_child(weapon)
	
	# Position the pivot based on item type
	match item_type:
		"sword":
			# Pivot at hilt position in right hand - BEHIND player for proper idle position
			pivot_node.position = Vector3(0.3, -0.3, -0.8)  # Much further back, lower
			pivot_node.rotation_degrees = Vector3(-20, 25, 10)  # Better idle angle
			# Weapon extends BACK from pivot so sword is behind player
			weapon.position = Vector3(0, 0, -0.4)  # NEGATIVE Z = sword extends behind player
			weapon.rotation_degrees = Vector3(-25, 0, 0)  # Angle blade down and back
		"dagger":
			# Pivot at grip position - BEHIND player
			pivot_node.position = Vector3(0.2, -0.2, -0.6)  # Further back
			pivot_node.rotation_degrees = Vector3(-15, 15, 5)
			# Weapon extends back from pivot
			weapon.position = Vector3(0, 0, -0.3)  # NEGATIVE Z = dagger behind player
			weapon.rotation_degrees = Vector3(-20, 0, 0)  # Angle down and back
		"torch":
			# Torch positioning - held up and forward for visibility and lighting
			pivot_node.position = Vector3(0.4, -0.1, 0.2)  # Right side, slightly forward for light
			pivot_node.rotation_degrees = Vector3(-10, 30, 15)  # Angled up and outward
			# Torch extends upward from grip
			weapon.position = Vector3(0, 0.3, 0)  # Torch head above grip
			weapon.rotation_degrees = Vector3(0, 0, 0)  # Keep torch upright
		_:
			# Default positioning for unknown items
			pivot_node.position = Vector3(0.3, -0.3, -0.7)  # Much further back
			pivot_node.rotation_degrees = Vector3(-18, 20, 8)
			# Standard offset with item extending back
			weapon.position = Vector3(0, 0, -0.4)  # NEGATIVE Z = item behind player
			weapon.rotation_degrees = Vector3(-22, 0, 0)  # Point item down and back
	
	# Set as current weapon/item for interaction (store the actual item, not pivot)
	var actual_item = pivot_node.get_child(0) if pivot_node.get_child_count() > 0 else weapon
	# But we'll animate the pivot for natural movement
	current_weapon_pivot = pivot_node
	current_weapon = actual_item
	print("Equipped ", actual_item.name, " (", item_type, ") with pivot setup")

func detach_weapon_from_hold(weapon: Node) -> void:
	"""Detach weapon from hold point and return to world (handles pivot system)"""
	var weapon_to_detach = weapon
	var pivot_parent = null
	
	# Check if weapon is in a pivot system
	if weapon.get_parent() and weapon.get_parent().name == "WeaponPivot":
		pivot_parent = weapon.get_parent()
		weapon_to_detach = weapon  # The actual weapon to detach
	
	if not weapon_to_detach:
		return
	
	# Calculate world position for drop from the actual weapon
	var world_pos = weapon_to_detach.global_position
	var world_rot = weapon_to_detach.global_rotation
	
	# Remove weapon from pivot (if exists) or direct parent
	if pivot_parent:
		pivot_parent.remove_child(weapon_to_detach)
		# Clean up pivot node
		weapon_hold.remove_child(pivot_parent)
		pivot_parent.queue_free()
	else:
		weapon_hold.remove_child(weapon_to_detach)
	
	# Add weapon back to scene
	get_tree().current_scene.add_child(weapon_to_detach)
	
	# Set world position
	weapon_to_detach.global_position = world_pos
	weapon_to_detach.global_rotation = world_rot
	
	# Re-enable physics
	weapon_to_detach.freeze = false
	weapon_to_detach.set_collision_layer_value(1, true)   # Re-enable collision with world
	weapon_to_detach.set_collision_mask_value(1, true)    # Re-enable collision detection
	
	# Clear current weapon references
	if current_weapon == weapon_to_detach:
		current_weapon = null
		current_weapon_pivot = null
		print("Unequipped weapon and cleaned up pivot")

# =============================================================================
# COMBAT SYSTEM
# =============================================================================

func perform_attack() -> void:
	"""Execute attack with current weapon"""
	if is_attacking or not current_weapon:
		return
	
	print("Attacking with ", current_weapon.name)
	is_attacking = true
	
	# Get weapon info for attack timing
	var weapon_info = current_weapon.get_weapon_info()
	var attack_speed = weapon_info.get("attack_speed", 1.0)
	var _damage = weapon_info.get("damage", 10)  # For future use
	
	# Calculate attack duration (faster attack_speed = shorter duration)
	var attack_duration = 0.4 / attack_speed
	
	# Setup hit detection area
	setup_weapon_hitbox()
	
	# Perform swing animation
	perform_swing_animation(attack_duration)

func setup_weapon_hitbox() -> void:
	"""Create hit detection area for the weapon"""
	if weapon_hit_area:
		weapon_hit_area.queue_free()
	
	weapon_hit_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	
	# Get weapon info for range
	var weapon_info = current_weapon.get_weapon_info()
	var weapon_range = weapon_info.get("weapon_range", 2.0)
	var weapon_type = weapon_info.get("weapon_type", "sword")
	
	# Size hitbox based on weapon type
	match weapon_type:
		"sword":
			shape.size = Vector3(1.5, 1.0, weapon_range)
		"dagger":
			shape.size = Vector3(1.0, 0.8, weapon_range * 0.7)
		_:
			shape.size = Vector3(1.2, 1.0, weapon_range)
	
	collision_shape.shape = shape
	weapon_hit_area.add_child(collision_shape)
	weapon_hold.add_child(weapon_hit_area)
	
	# Position hitbox in front of player
	weapon_hit_area.position = Vector3(0, 0, -weapon_range / 2)
	
	# Initially disable the hitbox
	weapon_hit_area.monitoring = false
	weapon_hit_area.body_entered.connect(_on_weapon_hit)

func perform_swing_animation(duration: float) -> void:
	"""Animate weapon swing using pivot point - natural slashing with forward motion!"""
	if attack_tween:
		attack_tween.kill()
	
	attack_tween = create_tween()
	attack_tween.set_parallel(true)
	
	# Use the pivot node for natural swinging
	var pivot_to_animate = current_weapon_pivot if current_weapon_pivot else current_weapon
	if not pivot_to_animate:
		print("Warning: No weapon pivot to animate!")
		return
	
	# Store original transform of the PIVOT (both rotation and position)
	var original_rotation = pivot_to_animate.rotation_degrees
	var original_position = pivot_to_animate.position
	
	# Get weapon type for different swing patterns
	var weapon_info = current_weapon.get_weapon_info() if current_weapon.has_method("get_weapon_info") else {}
	var weapon_type = weapon_info.get("weapon_type", "sword")
	
	# Define pivot-based swing motions with FORWARD MOTION for slashing
	var windup_rotation: Vector3
	var swing_rotation: Vector3
	var windup_position: Vector3
	var swing_position: Vector3
	
	match weapon_type:
		"sword":
			# THREE-ATTACK SEQUENCE: Right Diagonal → Left Horizontal → Overhead
			match current_attack_index:
				0: # RIGHT DIAGONAL SLASH - bring sword forward and across
					windup_rotation = original_rotation + Vector3(-30, 60, -15)     
					windup_position = original_position + Vector3(0.4, 0.2, 0.3)   # Bring forward from behind
					swing_rotation = original_rotation + Vector3(40, -50, 25)       
					swing_position = original_position + Vector3(-0.6, -0.1, -0.2)  # Slash across and back
				
				1: # LEFT HORIZONTAL SLASH - sweep from left to right
					windup_rotation = original_rotation + Vector3(-10, -50, -25)      
					windup_position = original_position + Vector3(-0.4, 0.1, 0.3)  # Bring forward from behind
					swing_rotation = original_rotation + Vector3(10, 50, 25)         
					swing_position = original_position + Vector3(0.6, 0.1, -0.2)   # Sweep across
				
				2: # OVERHEAD THRUST - raise up and strike down
					windup_rotation = original_rotation + Vector3(-60, 0, 0)        
					windup_position = original_position + Vector3(0, 0.6, 0.4)     # Raise high and forward
					swing_rotation = original_rotation + Vector3(40, 0, 0)          
					swing_position = original_position + Vector3(0, -0.2, -0.3)    # Strike down    
		
		"dagger":
			# Dagger: Quick stabs (tighter movements)
			windup_rotation = original_rotation + Vector3(0, -30, -15)      
			swing_rotation = original_rotation + Vector3(0, 40, 20)         
			windup_position = original_position + Vector3(0.2, 0, 0.1)      
			swing_position = original_position + Vector3(-0.3, 0, -0.3)     
		
		_: # Default three-attack sequence
			match current_attack_index:
				0: # Right diagonal
					windup_rotation = original_rotation + Vector3(-35, 45, -15)     
					swing_rotation = original_rotation + Vector3(50, -50, 25)       
					windup_position = original_position + Vector3(0.5, 0.25, 0.15)  
					swing_position = original_position + Vector3(-0.7, -0.15, -0.35) 
				1: # Left horizontal
					windup_rotation = original_rotation + Vector3(0, -50, -25)      
					swing_rotation = original_rotation + Vector3(0, 50, 25)         
					windup_position = original_position + Vector3(-0.5, 0.1, 0.15) 
					swing_position = original_position + Vector3(0.7, 0.1, -0.35)  
				2: # Overhead
					windup_rotation = original_rotation + Vector3(-70, 0, 0)        
					swing_rotation = original_rotation + Vector3(50, 0, 0)          
					windup_position = original_position + Vector3(0, 0.6, 0.25)    
					swing_position = original_position + Vector3(0, -0.3, -0.5)    
	
	# Advance to next attack in sequence
	current_attack_index = (current_attack_index + 1) % 3
	
	# Enable hitbox during the swing
	weapon_hit_area.monitoring = true
	
	# Phase 1: Wind-up (25% of duration) - VISIBLE dramatic buildup
	var windup_time = duration * 0.25
	attack_tween.tween_property(pivot_to_animate, "rotation_degrees", windup_rotation, windup_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(pivot_to_animate, "position", windup_position, windup_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Phase 2: Strike (35% of duration) - DRAMATIC sweeping slash
	var swing_time = duration * 0.35
	attack_tween.tween_property(pivot_to_animate, "rotation_degrees", swing_rotation, swing_time).set_delay(windup_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	attack_tween.tween_property(pivot_to_animate, "position", swing_position, swing_time).set_delay(windup_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	
	# Phase 3: Recovery (40% of duration) - Return to guard
	var recovery_time = duration * 0.4
	var recovery_delay = windup_time + swing_time
	attack_tween.tween_property(pivot_to_animate, "rotation_degrees", original_rotation, recovery_time).set_delay(recovery_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	attack_tween.tween_property(pivot_to_animate, "position", original_position, recovery_time).set_delay(recovery_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Disable hitbox after strike phase (60% through animation = end of strike)
	attack_tween.tween_callback(func(): weapon_hit_area.monitoring = false).set_delay(duration * 0.6)
	
	# End attack state when animation completes
	attack_tween.tween_callback(func(): is_attacking = false).set_delay(duration)
	
	# Print which attack is being performed
	var attack_names = ["RIGHT DIAGONAL SLASH", "LEFT HORIZONTAL SLASH", "OVERHEAD THRUST"]
	var attack_name = attack_names[(current_attack_index - 1 + 3) % 3]  # -1 because we already incremented
	print("Performing ", attack_name, " - blade should swing dramatically!")

func _on_weapon_hit(body: Node3D) -> void:
	"""Handle when weapon hits something"""
	if body == self:  # Don't hit ourselves
		return
	
	var weapon_info = current_weapon.get_weapon_info()
	var damage = weapon_info.get("damage", 10)
	var weapon_type = weapon_info.get("weapon_type", "unknown")
	
	print("Hit ", body.name, " with ", weapon_type, " for ", damage, " damage!")
	
	# Add screen shake for impact feedback
	add_screen_shake(0.15, 3.0)
	
	# Add damage to target if it has health
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Different impact effects based on weapon type
	match weapon_type:
		"sword":
			print("💥 CLANG! Heavy sword impact!")
		"dagger":
			print("⚡ SLICE! Quick dagger strike!")
		_:
			print("💢 HIT! Weapon impact!")
	
	# Add hit effect (brief pause for impact feel)
	if attack_tween:
		attack_tween.pause()
		await get_tree().create_timer(0.05).timeout  # Shorter pause for responsiveness
		if attack_tween:
			attack_tween.play()

func add_screen_shake(duration: float, intensity: float) -> void:
	"""Add camera shake effect for combat impact"""
	if camera_shake_tween:
		camera_shake_tween.kill()
	
	camera_shake_tween = create_tween()
	var original_position = head.position
	var shake_count = int(duration * 60)  # 60 FPS shake
	
	for i in range(shake_count):
		var shake_offset = Vector3(
			randf_range(-intensity, intensity) * 0.005,  # Subtle shake
			randf_range(-intensity, intensity) * 0.005,
			0
		)
		camera_shake_tween.tween_property(head, "position", original_position + shake_offset, 1.0/60.0)
	
	# Return to original position
	camera_shake_tween.tween_property(head, "position", original_position, 0.1)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_look_direction() -> Vector3:
	"""Get the direction the player is looking"""
	return -camera.global_transform.basis.z

func get_forward_direction() -> Vector3:
	"""Get the forward direction of the player (ignoring vertical look)"""
	return -transform.basis.z

func get_right_direction() -> Vector3:
	"""Get the right direction of the player"""
	return transform.basis.x

func setup_character_progression():
	"""Initialize character progression systems"""
	# Create character stats
	character_stats = CharacterStats.new()
	
	# Create equipment manager
	equipment_manager = EquipmentManager.new()
	equipment_manager.name = "EquipmentManager"
	add_child(equipment_manager)
	
	# Create inventory
	inventory = Inventory.new()
	inventory.name = "Inventory"
	add_child(inventory)
	
	# Update health values from character stats
	max_health = character_stats.max_hit_points
	current_health = character_stats.current_hit_points
	
	# Connect to character stats signals
	character_stats.connect("health_changed", _on_character_health_changed)
	
	print("Character progression systems initialized")
	print("Stats: STR:", character_stats.strength, " DEX:", character_stats.dexterity, " CON:", character_stats.constitution)
	print("Health: ", current_health, "/", max_health)

func setup_spell_system():
	"""Initialize the spell system"""
	spell_system = SpellSystem.new()
	spell_system.name = "SpellSystem"
	add_child(spell_system)
	print("Spell system initialized")

func _on_character_health_changed(current: int, maximum: int):
	"""Handle character health changes"""
	current_health = current
	max_health = maximum
	
	# Check if player died
	if current_health <= 0:
		print("Player died! Health reached 0.")
		# For now, respawn with full health
		character_stats.current_hit_points = character_stats.max_hit_points
		current_health = character_stats.current_hit_points

func get_character_stats() -> CharacterStats:
	"""Get the character stats resource."""
	return character_stats

func get_equipment_manager() -> EquipmentManager:
	"""Get the equipment manager."""
	return equipment_manager

func get_inventory() -> Inventory:
	"""Get the inventory."""
	return inventory

func take_damage(amount: int) -> void:
	"""Take damage and update character stats"""
	if character_stats:
		character_stats.take_damage(amount)
		print("Player took ", amount, " damage! Health: ", character_stats.current_hit_points, "/", character_stats.max_hit_points)
	else:
		# Fallback for if stats aren't initialized yet
		current_health = max(0, current_health - amount)
		print("Player took ", amount, " damage! Health: ", current_health, "/", max_health)

func heal(amount: int):
	"""Heal the player"""
	if character_stats:
		character_stats.heal(amount)
		print("Player healed for ", amount, " health! Health: ", character_stats.current_hit_points, "/", character_stats.max_hit_points)
	else:
		# Fallback for if stats aren't initialized yet
		current_health = min(max_health, current_health + amount)
		print("Player healed for ", amount, " health! Health: ", current_health, "/", max_health)

# =============================================================================
# DEBUG FUNCTIONS
# =============================================================================

func print_player_state() -> void:
	"""Print current player state for debugging"""
	print("=== Player State ===")
	print("Position: ", global_position)
	print("Velocity: ", velocity)
	print("On Floor: ", is_on_floor())
	print("Sprinting: ", is_sprinting)
	print("===================")
