# MagicMissileSpell.gd
# Magic Missile spell implementation - homing projectile, always hits

class_name MagicMissileSpell
extends Spell

# Magic Missile properties
var damage_base: int = 12
var damage_scaling: int = 2  # INT modifier * 2
var homing_speed: float = 10.0

# Missile scene reference
var magic_missile_scene: PackedScene

func _init():
	spell_name = "Magic_Missile"
	spell_type = SpellType.OFFENSIVE
	mana_cost = 8  # Cheap, reliable damage
	cast_time = 0.8  # Fast cast
	spell_range = 15.0
	
	# Load missile scene with error handling
	if ResourceLoader.exists("res://scenes/spells/MagicMissile.tscn"):
		magic_missile_scene = preload("res://scenes/spells/MagicMissile.tscn")
	else:
		print("MagicMissileSpell: ERROR - Missile scene not found!")

func execute(cast_position: Vector3, cast_direction: Vector3, character_stats: CharacterStats):
	"""Create homing magic missiles"""
	# Find target enemy in range
	var target = find_closest_enemy_in_range(cast_position, spell_range)
	
	if not target:
		print("MagicMissileSpell: No target in range!")
		return
	
	# Calculate number of missiles based on INT
	var int_modifier = character_stats.get_intelligence_modifier()
	var missile_count = 1 + max(0, int_modifier / 3)  # More missiles at high INT
	
	# Create missiles with slight delays
	for i in range(missile_count):
		create_homing_missile(cast_position, target, i * 0.1, character_stats)

func create_homing_missile(start_pos: Vector3, target: Node3D, delay: float, character_stats: CharacterStats):
	"""Create a single homing missile with delay"""
	if not magic_missile_scene:
		print("MagicMissileSpell: ERROR - No missile scene available!")
		return
		
	await Engine.get_main_loop().create_timer(delay).timeout
	
	var missile = magic_missile_scene.instantiate()
	if not missile:
		print("MagicMissileSpell: ERROR - Failed to instantiate missile!")
		return
		
	var scene_tree = Engine.get_main_loop() as SceneTree
	scene_tree.current_scene.add_child(missile)
	
	# Position missile
	missile.global_position = start_pos + Vector3(0, 1.5, 0)
	missile.target = target
	missile.damage = calculate_missile_damage(character_stats)
	missile.homing_speed = homing_speed
	
	# Add visual effects to missile
	var missile_effects = preload("res://scripts/spells/MagicMissileEffects.gd").new()
	var missile_visual = missile_effects.create_missile_projectile()
	missile.add_child(missile_visual)
	
	print("MagicMissileSpell: Created missile with ", missile.damage, " damage")

func calculate_missile_damage(character_stats: CharacterStats) -> int:
	"""Calculate missile damage based on INT scaling"""
	var int_modifier = character_stats.get_intelligence_modifier()
	return calculate_damage(damage_base, int_modifier, damage_scaling)

func find_closest_enemy_in_range(position: Vector3, range: float) -> Node3D:
	"""Find the closest enemy within range"""
	var scene_tree = Engine.get_main_loop() as SceneTree
	var enemies = scene_tree.get_nodes_in_group("enemies")
	
	var closest_enemy: Node3D = null
	var closest_distance: float = range + 1.0  # Start beyond range
	
	for enemy in enemies:
		if enemy is Node3D:
			var distance = position.distance_to(enemy.global_position)
			if distance <= range and distance < closest_distance:
				closest_enemy = enemy as Node3D
				closest_distance = distance
	
	return closest_enemy

func get_description() -> String:
	return "Fires homing energy missiles that always hit their target. Number of missiles and damage scale with Intelligence."
