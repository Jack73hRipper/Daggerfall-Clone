# BaseItem.gd
# Base class for all physics-based items in the game
# Items use RigidBody3D for realistic physics interactions

class_name BaseItem
extends RigidBody3D

# Item properties
@export var item_name: String = "Unknown Item"
@export var item_weight: float = 1.0
@export var item_value: int = 1
@export var item_description: String = "A mysterious item"

# Physics settings
@export var pickup_force: float = 5.0
@export var throw_force: float = 10.0

# References
@onready var sprite: Sprite3D = $Sprite3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var pickup_area: Area3D = $PickupArea

# Item state
var can_be_picked_up: bool = true
var is_being_carried: bool = false
var carried_by_player: Node = null

# Signals
signal item_picked_up(item: BaseItem, player: Node)
signal item_dropped(item: BaseItem)

func _ready() -> void:
	# Add to items group for cleanup purposes
	add_to_group("items")
	
	# Connect pickup area signal
	if pickup_area:
		pickup_area.body_entered.connect(_on_pickup_area_entered)
		pickup_area.body_exited.connect(_on_pickup_area_exited)
	
	# Set up physics
	gravity_scale = 1.0
	mass = item_weight
	
	print("Item created: ", item_name, " (Weight: ", item_weight, ")")

func _on_pickup_area_entered(body: Node3D) -> void:
	"""Handle when something enters pickup range"""
	if body.is_in_group("players") and can_be_picked_up and not is_being_carried:
		# Visual feedback - could add highlighting here
		print("Player in pickup range of: ", item_name)

func _on_pickup_area_exited(body: Node3D) -> void:
	"""Handle when something leaves pickup range"""
	if body.is_in_group("players"):
		print("Player left pickup range of: ", item_name)

func try_pickup(player: Node) -> bool:
	"""Attempt to pick up this item"""
	if not can_be_picked_up or is_being_carried:
		return false
	
	# Check if player can carry more weight (future implementation)
	if not can_player_carry_item(player):
		print("Player cannot carry ", item_name, " - too heavy!")
		return false
	
	# Pick up the item
	pickup_item(player)
	return true

func pickup_item(player: Node) -> void:
	"""Actually pick up the item"""
	is_being_carried = true
	carried_by_player = player
	
	# Don't disable physics here - let the player controller handle attachment
	# The physics will be disabled when attached to weapon hold
	
	# Emit signal
	item_picked_up.emit(self, player)
	print("Picked up: ", item_name)

func drop_item(drop_position: Vector3, drop_velocity: Vector3 = Vector3.ZERO) -> void:
	"""Drop the item at specified position"""
	if not is_being_carried:
		return
	
	# Reset state
	is_being_carried = false
	carried_by_player = null
	
	# Physics will be re-enabled by the player controller when detaching
	
	# Set position and velocity
	global_position = drop_position
	linear_velocity = drop_velocity
	
	# Emit signal
	item_dropped.emit(self)
	print("Dropped: ", item_name)

func throw_item(throw_position: Vector3, throw_direction: Vector3) -> void:
	"""Throw the item in a direction"""
	if not is_being_carried:
		return
	
	# Calculate throw velocity
	var throw_velocity = throw_direction.normalized() * throw_force
	
	# Drop with velocity
	drop_item(throw_position, throw_velocity)
	print("Threw: ", item_name)

func can_player_carry_item(_player: Node) -> bool:
	"""Check if player can carry this item (weight system)"""
	# Future implementation - check player's carrying capacity
	# For now, always return true
	return true

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_item_info() -> Dictionary:
	"""Get item information as dictionary"""
	return {
		"name": item_name,
		"weight": item_weight,
		"value": item_value,
		"description": item_description,
		"position": global_position,
		"carried": is_being_carried
	}

func set_item_sprite(texture: Texture2D) -> void:
	"""Set the sprite texture for this item"""
	if sprite:
		sprite.texture = texture

# =============================================================================
# DEBUG FUNCTIONS
# =============================================================================

func print_item_state() -> void:
	"""Print current item state for debugging"""
	print("=== Item State: ", item_name, " ===")
	print("Position: ", global_position)
	print("Weight: ", item_weight)
	print("Carried: ", is_being_carried)
	print("Can pickup: ", can_be_picked_up)
	print("=================================")
