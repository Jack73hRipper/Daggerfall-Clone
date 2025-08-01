# SpellSystem.gd
# Core magic system for tactical spellcasting
# Integrated with D&D 5E CharacterStats for INT/WIS scaling

class_name SpellSystem
extends Node

# Spell system enums
enum SpellType {
	OFFENSIVE,
	UTILITY,
	DEFENSIVE
}

enum CastState {
	READY,
	CASTING,
	COOLDOWN
}

# References
var player_controller: PlayerController
var character_stats: CharacterStats
var player_hud: PlayerHUD  # Cast bar integration

# Casting state
var current_cast_state: CastState = CastState.READY
var casting_timer: float = 0.0
var current_spell: Spell = null
var original_move_speed: float = 0.0

# Spell database
var spells: Dictionary = {}

# Visual effects system
var current_effect: SpellEffects = null

# Signals
signal spell_cast_started(spell_name: String)
signal spell_cast_completed(spell_name: String)
signal spell_cast_interrupted(spell_name: String)
signal mana_insufficient(required: int, available: int)

func _ready():
	# Get references
	player_controller = get_parent() as PlayerController
	if player_controller:
		character_stats = player_controller.character_stats
		original_move_speed = player_controller.base_speed
	
	# Initialize spell database
	initialize_spells()
	
	# Connect to damage events for spell interruption
	if character_stats:
		character_stats.health_changed.connect(_on_health_changed)

func get_player_hud() -> PlayerHUD:
	"""Get PlayerHUD reference dynamically"""
	if player_hud and is_instance_valid(player_hud):
		return player_hud
	
	# Try to find PlayerHUD
	print("SpellSystem: Looking for PlayerHUD...")
	player_hud = get_node("/root/Main/UI/PlayerHUD") if get_node_or_null("/root/Main/UI/PlayerHUD") else null
	if not player_hud:
		print("SpellSystem: PlayerHUD not found at /root/Main/UI/PlayerHUD, trying group...")
		# Try alternative paths
		var hud_nodes = get_tree().get_nodes_in_group("player_hud")
		print("SpellSystem: Found ", hud_nodes.size(), " nodes in player_hud group")
		player_hud = get_tree().get_first_node_in_group("player_hud") if hud_nodes.size() > 0 else null
	
	if player_hud:
		print("SpellSystem: Successfully found PlayerHUD: ", player_hud)
	else:
		print("SpellSystem: ERROR - PlayerHUD not found! Cast bar will not work.")
	
	return player_hud

func _process(delta):
	update_casting(delta)

func initialize_spells():
	"""Initialize all available spells"""
	# Load spell classes dynamically
	var fireball_class = load("res://scripts/player/spells/FireballSpell.gd")
	var heal_class = load("res://scripts/player/spells/HealSpell.gd") 
	var missile_class = load("res://scripts/player/spells/MagicMissileSpell.gd")
	
	# Create spell instances with error checking
	if fireball_class:
		var fireball_spell = fireball_class.new()
		if fireball_spell and fireball_spell.spell_name:
			spells["Fireball"] = fireball_spell
		else:
			print("SpellSystem: ERROR - Failed to create Fireball spell")
	
	if heal_class:
		var heal_spell = heal_class.new()
		if heal_spell and heal_spell.spell_name:
			spells["Heal"] = heal_spell
		else:
			print("SpellSystem: ERROR - Failed to create Heal spell")
	
	if missile_class:
		var missile_spell = missile_class.new()
		if missile_spell and missile_spell.spell_name:
			spells["Magic_Missile"] = missile_spell
		else:
			print("SpellSystem: ERROR - Failed to create Magic Missile spell")
	
	print("SpellSystem: Initialized ", spells.size(), " spells")

func get_safe_spell_name(spell: Spell) -> String:
	"""Safely get spell name with null checking"""
	if not spell or not is_instance_valid(spell):
		return "Invalid Spell"
	
	# Check if spell_name property exists and has a value
	if "spell_name" in spell and spell.spell_name and spell.spell_name != "":
		return spell.spell_name
	
	return "Unknown Spell"

func handle_spell_input(event: InputEvent):
	"""Handle spell casting input"""
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_1:
			cast_spell("Fireball")
		KEY_2:
			cast_spell("Heal")
		KEY_3:
			cast_spell("Magic_Missile")

func cast_spell(spell_name: String) -> bool:
	"""Attempt to cast a spell"""
	var spell = spells.get(spell_name)
	if not spell:
		print("SpellSystem: Spell not found: ", spell_name)
		return false
	
	# Additional null safety check
	if not spell or not is_instance_valid(spell):
		print("SpellSystem: ERROR - Invalid spell object for: ", spell_name)
		return false
	
	# Check if spell has the required properties
	if not spell.has_method("execute") or not ("spell_name" in spell):
		print("SpellSystem: ERROR - Spell object missing required properties: ", spell_name)
		return false
	
	# Check casting requirements
	if not can_cast_spell(spell):
		return false
	
	# Start casting process
	begin_spell_cast(spell)
	return true

func can_cast_spell(spell: Spell) -> bool:
	"""Check if a spell can be cast"""
	# Check if player is alive
	if not character_stats or not character_stats.is_alive():
		return false
	
	# Check if already casting
	if current_cast_state != CastState.READY:
		return false
	
	# Check mana cost
	if not character_stats.use_mana(spell.mana_cost):
		emit_signal("mana_insufficient", spell.mana_cost, character_stats.current_mana_points)
		return false
	
	return true

func begin_spell_cast(spell: Spell):
	"""Start the casting process"""
	if not spell:
		print("SpellSystem: ERROR - Tried to cast null spell!")
		return
	
	current_cast_state = CastState.CASTING
	current_spell = spell
	casting_timer = spell.cast_time
	
	# Reduce movement speed during casting (design decision: 50% speed)
	if player_controller:
		player_controller.base_speed = original_move_speed * 0.5
	
	# Show cast bar
	var hud = get_player_hud()
	if hud:
		print("SpellSystem: Showing cast bar for spell: ", spell.spell_name)
		hud.show_cast_bar(spell.spell_name, spell.cast_time)
	else:
		print("SpellSystem: ERROR - Cannot show cast bar, player_hud is null!")
	
	# Start casting effects
	play_casting_effects(spell)
	
	var spell_name = get_safe_spell_name(spell)
	emit_signal("spell_cast_started", spell_name)
	print("SpellSystem: Started casting ", spell_name)

func update_casting(delta: float):
	"""Update casting state each frame"""
	if current_cast_state != CastState.CASTING:
		return
	
	casting_timer -= delta
	
	# Update cast bar progress
	var hud = get_player_hud()
	if hud and current_spell:
		var progress = get_casting_progress()
		hud.update_cast_bar_progress(progress, casting_timer)
	
	if casting_timer <= 0.0:
		complete_spell_cast()

func complete_spell_cast():
	"""Complete the spell casting process"""
	if current_spell:
		# Execute the spell
		execute_spell(current_spell)
		
		var spell_name = get_safe_spell_name(current_spell)
		emit_signal("spell_cast_completed", spell_name)
		print("SpellSystem: Completed casting ", spell_name)
		
		# Show success effect on cast bar
		var hud = get_player_hud()
		if hud:
			hud.show_cast_success_effect()
		
		current_spell = null
	
	# Reset casting state
	reset_casting_state()

func interrupt_spell_cast():
	"""Interrupt the current spell casting"""
	if current_cast_state == CastState.CASTING and current_spell:
		var spell_name = get_safe_spell_name(current_spell)
		emit_signal("spell_cast_interrupted", spell_name)
		print("SpellSystem: Spell casting interrupted: ", spell_name)
		
		# Show interruption effect on cast bar
		var hud = get_player_hud()
		if hud:
			hud.show_cast_interrupt_effect()
		
		# Note: Mana is already spent - failed casts waste mana (design decision)
		current_spell = null
	
	reset_casting_state()

func reset_casting_state():
	"""Reset casting state to ready"""
	current_cast_state = CastState.READY
	casting_timer = 0.0
	
	# Stop visual effects
	if current_effect:
		if current_effect.has_method("stop_casting_effects"):
			current_effect.stop_casting_effects()
		elif current_effect.has_method("stop_healing_effects"):
			current_effect.stop_healing_effects()
		current_effect.queue_free()
		current_effect = null
	
	# Restore normal movement speed
	if player_controller:
		player_controller.base_speed = original_move_speed

func execute_spell(spell: Spell):
	"""Execute a spell's effects"""
	if not player_controller:
		return
	
	# Get casting position and direction
	var cast_position = player_controller.global_position
	var cast_direction = -player_controller.camera.global_transform.basis.z
	
	# Execute spell-specific logic
	spell.execute(cast_position, cast_direction, character_stats)

func play_casting_effects(spell: Spell):
	"""Play visual and audio effects for spell casting"""
	if not spell:
		return
	
	# Create appropriate visual effects based on spell type
	match spell.spell_name:
		"Fireball":
			current_effect = preload("res://scripts/spells/FireballEffects.gd").new()
			player_controller.add_child(current_effect)
			current_effect.play_casting_effect(spell.cast_time)
		
		"Heal":
			current_effect = preload("res://scripts/spells/HealEffects.gd").new()
			player_controller.add_child(current_effect)
			current_effect.play_healing_effect(spell.cast_time)
		
		"Magic_Missile":
			current_effect = preload("res://scripts/spells/MagicMissileEffects.gd").new()
			player_controller.add_child(current_effect)
			current_effect.play_casting_effect(spell.cast_time)
		
		_:
			print("SpellSystem: No visual effects for spell: ", spell.spell_name)

func _on_health_changed(_current_hp: int, _max_hp: int):
	"""Handle health changes - interrupt casting if damaged"""
	# Check if health decreased (took damage)
	if current_cast_state == CastState.CASTING:
		# For now, any damage interrupts casting
		# Could be refined to only interrupt on significant damage
		interrupt_spell_cast()

func get_spell_info(spell_name: String) -> Dictionary:
	"""Get information about a spell for UI display"""
	var spell = spells.get(spell_name)
	if not spell:
		return {}
	
	return {
		"name": spell.spell_name,
		"mana_cost": spell.mana_cost,
		"cast_time": spell.cast_time,
		"description": spell.get_description()
	}

func is_casting() -> bool:
	"""Check if currently casting a spell"""
	return current_cast_state == CastState.CASTING

func get_casting_progress() -> float:
	"""Get casting progress (0.0 to 1.0)"""
	if current_cast_state != CastState.CASTING or not current_spell:
		return 0.0
	
	return 1.0 - (casting_timer / current_spell.cast_time)
