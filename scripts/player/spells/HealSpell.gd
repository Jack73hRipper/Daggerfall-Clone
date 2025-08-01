# HealSpell.gd
# Heal spell implementation - self-cast healing utility

class_name HealSpell
extends Spell

# Heal properties  
var heal_base: int = 25
var heal_scaling: int = 4  # WIS modifier * 4

func _init():
	spell_name = "Heal"
	spell_type = SpellType.UTILITY
	mana_cost = 12
	cast_time = 1.5  # Longer cast time makes it more tactical
	spell_range = 0.0  # Self-cast only

func execute(cast_position: Vector3, cast_direction: Vector3, character_stats: CharacterStats):
	"""Heal the player"""
	var heal_amount = calculate_heal_amount(character_stats)
	
	# Apply healing
	character_stats.heal(heal_amount)
	
	# Create completion visual effects
	var heal_effects = preload("res://scripts/spells/HealEffects.gd").new()
	heal_effects.show_healing_complete(heal_amount, cast_position)
	
	print("HealSpell: Healed for ", heal_amount, " HP")

func calculate_heal_amount(character_stats: CharacterStats) -> int:
	"""Calculate healing amount based on WIS scaling"""
	var wis_modifier = character_stats.get_wisdom_modifier()
	return calculate_healing(heal_base, wis_modifier, heal_scaling)

func create_heal_effects(position: Vector3):
	"""Create healing visual effects"""
	# TODO: Add particle effects for healing
	# For now, just print feedback
	print("HealSpell: Creating heal effects at ", position)

func get_description() -> String:
	return "Restores health to the caster. Healing amount scales with Wisdom."
