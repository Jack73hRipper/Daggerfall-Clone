# CharacterStats.gd
# Core D&D 5E-inspired character statistics system

class_name CharacterStats
extends Resource

# Core D&D 5E Attributes (8-20 range, 10 = average)
@export var strength: int = 10      # STR - Physical power, melee damage, carrying capacity
@export var dexterity: int = 10     # DEX - Agility, AC bonus, ranged damage
@export var constitution: int = 10  # CON - Health, stamina, endurance
@export var intelligence: int = 10  # INT - Mana, spell power, investigation
@export var wisdom: int = 10        # WIS - Perception, divine magic, insight
@export var charisma: int = 10      # CHA - Social interactions, leadership, luck

# Progression Stats
@export var level: int = 1
@export var experience_points: int = 0
@export var proficiency_bonus: int = 2

# Derived Stats (calculated from attributes)
var max_hit_points: int = 100
var current_hit_points: int = 100
var max_mana_points: int = 50
var current_mana_points: int = 50
var max_stamina_points: int = 100
var current_stamina_points: int = 100

# Signals for UI updates
signal stats_changed
signal health_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal stamina_changed(current: int, maximum: int)
signal level_up(new_level: int)

func _init():
	calculate_derived_stats()

func get_modifier(attribute_score: int) -> int:
	"""Calculate D&D 5E attribute modifier"""
	return (attribute_score - 10) / 2  # Integer division is intentional for D&D modifiers

func get_strength_modifier() -> int:
	return get_modifier(strength)

func get_dexterity_modifier() -> int:
	return get_modifier(dexterity)

func get_constitution_modifier() -> int:
	return get_modifier(constitution)

func get_intelligence_modifier() -> int:
	return get_modifier(intelligence)

func get_wisdom_modifier() -> int:
	return get_modifier(wisdom)

func get_charisma_modifier() -> int:
	return get_modifier(charisma)

func calculate_derived_stats():
	"""Recalculate all derived statistics from base attributes"""
	# Health calculation (base 60 + CON modifier per level)
	var con_bonus = get_constitution_modifier()
	max_hit_points = 60 + (con_bonus * level)
	max_hit_points = max(max_hit_points, level * 5)  # Minimum 5 HP per level
	
	# Mana calculation (base 20 + INT modifier * 5)
	var int_bonus = get_intelligence_modifier()
	max_mana_points = 20 + (int_bonus * 5)
	max_mana_points = max(max_mana_points, 10)  # Minimum 10 mana
	
	# Stamina calculation (base 80 + CON modifier * 3)
	max_stamina_points = 80 + (con_bonus * 3)
	max_stamina_points = max(max_stamina_points, 50)  # Minimum 50 stamina
	
	# Ensure current values don't exceed maximums
	current_hit_points = min(current_hit_points, max_hit_points)
	current_mana_points = min(current_mana_points, max_mana_points)
	current_stamina_points = min(current_stamina_points, max_stamina_points)
	
	# Emit all stat change signals to update UI
	emit_signal("stats_changed")
	emit_signal("health_changed", current_hit_points, max_hit_points)
	emit_signal("mana_changed", current_mana_points, max_mana_points)
	emit_signal("stamina_changed", current_stamina_points, max_stamina_points)

func modify_attribute(attribute: String, value: int):
	"""Modify a base attribute and recalculate derived stats"""
	match attribute.to_lower():
		"strength", "str":
			strength = clamp(value, 8, 20)
		"dexterity", "dex":
			dexterity = clamp(value, 8, 20)
		"constitution", "con":
			constitution = clamp(value, 8, 20)
		"intelligence", "int":
			intelligence = clamp(value, 8, 20)
		"wisdom", "wis":
			wisdom = clamp(value, 8, 20)
		"charisma", "cha":
			charisma = clamp(value, 8, 20)
	
	calculate_derived_stats()

func take_damage(amount: int):
	"""Apply damage to character"""
	current_hit_points = max(0, current_hit_points - amount)
	emit_signal("health_changed", current_hit_points, max_hit_points)

func heal(amount: int):
	"""Restore health to character"""
	current_hit_points = min(max_hit_points, current_hit_points + amount)
	emit_signal("health_changed", current_hit_points, max_hit_points)

func use_mana(amount: int) -> bool:
	"""Try to spend mana - returns false if insufficient"""
	if current_mana_points >= amount:
		current_mana_points -= amount
		emit_signal("mana_changed", current_mana_points, max_mana_points)
		return true
	return false

func restore_mana(amount: int):
	"""Restore mana to character"""
	current_mana_points = min(max_mana_points, current_mana_points + amount)
	emit_signal("mana_changed", current_mana_points, max_mana_points)

func use_stamina(amount: int) -> bool:
	"""Try to spend stamina - returns false if insufficient"""
	if current_stamina_points >= amount:
		current_stamina_points -= amount
		emit_signal("stamina_changed", current_stamina_points, max_stamina_points)
		return true
	return false

func restore_stamina(amount: int):
	"""Restore stamina to character"""
	current_stamina_points = min(max_stamina_points, current_stamina_points + amount)
	emit_signal("stamina_changed", current_stamina_points, max_stamina_points)

func is_alive() -> bool:
	"""Check if character is alive"""
	return current_hit_points > 0

func get_stat_summary() -> Dictionary:
	"""Get all stats as a dictionary for display/save purposes"""
	return {
		"strength": strength,
		"dexterity": dexterity,
		"constitution": constitution,
		"intelligence": intelligence,
		"wisdom": wisdom,
		"charisma": charisma,
		"level": level,
		"experience": experience_points,
		"hp_current": current_hit_points,
		"hp_max": max_hit_points,
		"mana_current": current_mana_points,
		"mana_max": max_mana_points,
		"stamina_current": current_stamina_points,
		"stamina_max": max_stamina_points
	}

func load_from_dict(data: Dictionary):
	"""Load character stats from dictionary (for save/load)"""
	strength = data.get("strength", 10)
	dexterity = data.get("dexterity", 10)
	constitution = data.get("constitution", 10)
	intelligence = data.get("intelligence", 10)
	wisdom = data.get("wisdom", 10)
	charisma = data.get("charisma", 10)
	level = data.get("level", 1)
	experience_points = data.get("experience", 0)
	current_hit_points = data.get("hp_current", max_hit_points)
	current_mana_points = data.get("mana_current", max_mana_points)
	current_stamina_points = data.get("stamina_current", max_stamina_points)
	
	calculate_derived_stats()
