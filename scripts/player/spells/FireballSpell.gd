# FireballSpell.gd
# Fireball spell implementation - ranged projectile with area damage

class_name FireballSpell
extends Spell

# Fireball properties
var damage_base: int = 20
var damage_scaling: int = 3  # INT modifier * 3
var area_radius: float = 3.0
var projectile_speed: float = 15.0
var max_distance: float = 20.0

# Projectile scene reference
var fireball_projectile_scene: PackedScene

func _init():
	spell_name = "Fireball"
	spell_type = SpellType.OFFENSIVE
	mana_cost = 15
	cast_time = 1.0
	spell_range = 20.0
	
	# Load projectile scene with error handling
	if ResourceLoader.exists("res://scenes/spells/FireballProjectile.tscn"):
		fireball_projectile_scene = preload("res://scenes/spells/FireballProjectile.tscn")
	else:
		print("FireballSpell: ERROR - Projectile scene not found!")

func execute(cast_position: Vector3, cast_direction: Vector3, character_stats: CharacterStats):
	"""Create and launch a fireball projectile"""
	if not fireball_projectile_scene:
		print("FireballSpell: ERROR - No projectile scene available!")
		return
	
	# Create fireball projectile
	var fireball = fireball_projectile_scene.instantiate()
	if not fireball:
		print("FireballSpell: ERROR - Failed to instantiate fireball projectile!")
		return
	var scene_tree = Engine.get_main_loop() as SceneTree
	scene_tree.current_scene.add_child(fireball)
	
	# Position fireball further in front of player to avoid immediate collision
	var spawn_position = cast_position + Vector3(0, 1.5, 0) + (cast_direction * 2.5)  # Increased from 1.5 to 2.5
	fireball.global_position = spawn_position
	
	print("FireballSpell: Spawning fireball at ", spawn_position, " from player at ", cast_position)
	
	# Set fireball properties
	fireball.direction = cast_direction.normalized()
	fireball.damage = calculate_fireball_damage(character_stats)
	fireball.explosion_radius = area_radius
	
	# Add visual effects to projectile
	var projectile_effects = preload("res://scripts/spells/FireballEffects.gd").new()
	var projectile_visual = projectile_effects.create_projectile_effect()
	fireball.add_child(projectile_visual)
	
	print("FireballSpell: Launched fireball with damage ", fireball.damage)
	fireball.travel_speed = projectile_speed
	fireball.max_distance = max_distance
	
	print("FireballSpell: Launched fireball with ", fireball.damage, " damage")

func calculate_fireball_damage(character_stats: CharacterStats) -> int:
	"""Calculate fireball damage based on INT scaling"""
	var int_modifier = character_stats.get_intelligence_modifier()
	return calculate_damage(damage_base, int_modifier, damage_scaling)

func get_description() -> String:
	return "Hurls a fiery projectile that explodes on impact, dealing area damage. Damage scales with Intelligence."
