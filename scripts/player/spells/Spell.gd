# Spell.gd
# Base class for all spells in the magic system

class_name Spell
extends Resource

# Spell type enum (duplicated here to avoid circular dependency)
enum SpellType {
	OFFENSIVE,
	UTILITY,
	DEFENSIVE
}

# Spell properties
@export var spell_name: String = ""
@export var spell_type: SpellType = SpellType.OFFENSIVE
@export var mana_cost: int = 10
@export var cast_time: float = 1.0
@export var spell_range: float = 10.0  # Renamed to avoid shadowing built-in 'range'

func execute(_cast_position: Vector3, _cast_direction: Vector3, _character_stats: CharacterStats):
	"""Override in derived classes to implement spell effects"""
	pass

func get_description() -> String:
	"""Override in derived classes to provide spell description"""
	return "A basic spell"

func calculate_damage(base_damage: int, stat_modifier: int, scaling_factor: int) -> int:
	"""Helper function to calculate spell damage with stat scaling"""
	return base_damage + (stat_modifier * scaling_factor)

func calculate_healing(base_healing: int, stat_modifier: int, scaling_factor: int) -> int:
	"""Helper function to calculate spell healing with stat scaling"""
	return base_healing + (stat_modifier * scaling_factor)
