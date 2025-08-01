# Weapon.gd
# 3D weapon item class extending BaseItem
# Uses actual 3D models for weapons with proper physics

class_name Weapon
extends BaseItem

# Weapon-specific properties
@export var weapon_type: String = "sword"
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var weapon_range: float = 1.5

# 3D Model references
@onready var weapon_model: Node3D = $WeaponModel
@onready var mesh_instance: MeshInstance3D = $WeaponModel/MeshInstance3D

# Weapon states
var is_equipped: bool = false

func _ready() -> void:
	# Call parent ready first
	super._ready()
	
	# Set weapon-specific properties
	if weapon_type == "sword":
		item_name = "Iron Sword"
		item_weight = 3.0
		item_value = 25
		item_description = "A sturdy iron sword, well-balanced for combat"
		damage = 15
		attack_speed = 1.0
	elif weapon_type == "dagger":
		item_name = "Steel Dagger"
		item_weight = 1.0
		item_value = 15
		item_description = "A sharp steel dagger, perfect for quick strikes"
		damage = 8
		attack_speed = 1.5  # Daggers attack faster
	else:
		# Default weapon stats
		item_name = "Unknown Weapon"
		item_weight = 2.0
		item_value = 10
		damage = 10
		attack_speed = 1.0
	
	print("Weapon created: ", item_name, " (Damage: ", damage, ")")

func equip_weapon(player: Node) -> void:
	"""Equip this weapon to a player"""
	if is_being_carried and carried_by_player == player:
		is_equipped = true
		print("Equipped: ", item_name)

func unequip_weapon() -> void:
	"""Unequip this weapon"""
	is_equipped = false
	print("Unequipped: ", item_name)

func get_weapon_info() -> Dictionary:
	"""Get weapon-specific information"""
	var info = get_item_info()
	info["weapon_type"] = weapon_type
	info["damage"] = damage
	info["attack_speed"] = attack_speed
	info["range"] = weapon_range
	info["equipped"] = is_equipped
	return info

# Override pickup to handle weapon-specific logic
func pickup_item(player: Node) -> void:
	"""Override pickup for weapon-specific behavior"""
	super.pickup_item(player)
	# Could add weapon-specific pickup effects here
	print("Picked up weapon: ", item_name)

# Override drop to handle weapon-specific logic  
func drop_item(drop_position: Vector3, drop_velocity: Vector3 = Vector3.ZERO) -> void:
	"""Override drop for weapon-specific behavior"""
	if is_equipped:
		unequip_weapon()
	super.drop_item(drop_position, drop_velocity)
	print("Dropped weapon: ", item_name)
