# TestSceneController.gd
# Controls the test scene and manages dungeon generation

extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var dungeon_generator = $DaggerfallDungeonGenerator
@onready var player_hud = $UILayer/PlayerHUD
@onready var character_menu = $UILayer/CharacterMenu
@onready var ui_layer = $UILayer

# Weapon scenes
const SWORD_SCENE = preload("res://scenes/items/WarriorSword.tscn")
const DAGGER_SCENE = preload("res://scenes/items/RogueDagger.tscn")

func _ready() -> void:
	print("TestScene starting...")
	
	# Add UI layer to group for spell effects
	ui_layer.add_to_group("ui_layer")
	
	# Position player at the spawn point after dungeon is generated
	await get_tree().process_frame  # Wait for dungeon to generate
	var spawn_points = dungeon_generator.get_spawn_points()
	if spawn_points.size() > 0:
		player.position = spawn_points[0]
		print("TestScene setup complete - player spawned")
		print("=== COMBAT TESTING SETUP ===")
		print("- Look for SWORD near your starting position")
		print("- Press E to pick up weapons")
		print("- Left-click to attack when equipped")
		print("- Look for SKELETON, SLIME, and BAT ENEMIES in rooms")
		print("==============================")
	else:
		print("No spawn points found - using default position")
		player.position = Vector3(0, 1, 0)
	
	# Enemies are now spawned automatically by the dungeon generator
	# spawn_test_targets()  # Replaced with real enemies
	
	# Spawn weapons for testing
	spawn_test_weapons()
	
	# Connect HUD to player stats (wait a bit for player to initialize)
	await get_tree().create_timer(0.5).timeout
	if player.has_method("get_character_stats"):
		var stats = player.get_character_stats()
		if stats:
			player_hud.connect_to_character_stats(stats)
			print("HUD connected to player character stats")
			
			# Also connect character menu
			var equipment = player.get_equipment_manager()
			var inventory = player.get_inventory()
			character_menu.connect_character_data(stats, equipment, inventory)
			print("Character menu connected to player data")
		else:
			print("Warning: Player character_stats not found")
	else:
		print("Warning: Player doesn't have get_character_stats method")

func _input(event: InputEvent) -> void:
	# Allow regenerating dungeon with F5 key
	if event.is_action_pressed("debug_regenerate"):  # F5 key
		print("F5 pressed - Regenerating dungeon...")
		
		# Call the regeneration function
		if dungeon_generator and dungeon_generator.has_method("regenerate_dungeon"):
			dungeon_generator.regenerate_dungeon()
		else:
			print("ERROR: dungeon_generator not found or missing regenerate_dungeon method")
			return
		
		# Wait for generation to complete
		await get_tree().process_frame
		await get_tree().process_frame  # Extra frame for cleanup
		
		# Respawn player
		var spawn_points = dungeon_generator.get_spawn_points()
		if spawn_points.size() > 0:
			player.position = spawn_points[0]
			print("Dungeon regenerated successfully")
		else:
			print("No spawn points found after regeneration")
		
		# Enemies are now spawned automatically by the dungeon generator
		# spawn_test_targets()  # Replaced with real enemies
		
		# Respawn weapons
		spawn_test_weapons()
	
	# Handle character menu toggle
	if event.is_action_pressed("character_menu"):
		if character_menu:
			character_menu.toggle_menu()
		else:
			print("Character menu not found")

func spawn_test_targets() -> void:
	"""Spawn test targets for combat testing - DEPRECATED: Now using real enemies from dungeon generator"""
	# This function is no longer used - enemies are spawned by DaggerfallDungeonGenerator
	# in the spawn_dungeon_enemies() function during dungeon generation Phase 6
	print("Note: Test targets deprecated - real enemies are spawned by dungeon generator")

func spawn_test_weapons() -> void:
	"""Spawn test weapons for combat testing"""
	# Clear existing weapons (items group)
	var existing_weapons = get_tree().get_nodes_in_group("items")
	for weapon in existing_weapons:
		weapon.queue_free()
	
	# Get room positions from dungeon generator
	var room_centers = dungeon_generator.get_room_centers()
	if room_centers.size() < 2:
		print("Not enough rooms for weapon spawning")
		return
	
	# Spawn sword in the first room (player spawn room)
	var sword_instance = SWORD_SCENE.instantiate()
	add_child(sword_instance)
	
	# Position sword near player spawn but not directly on top
	var sword_pos = room_centers[0]
	sword_pos.x += 2.0  # Offset from center
	sword_pos.y += 0.5  # Slightly above floor
	sword_instance.position = sword_pos
	
	print("Spawned sword at ", sword_pos)
	
	# Spawn dagger in the second room if available
	if room_centers.size() > 1:
		var dagger_instance = DAGGER_SCENE.instantiate()
		add_child(dagger_instance)
		
		var dagger_pos = room_centers[1]
		dagger_pos.x -= 2.0  # Offset in other direction
		dagger_pos.y += 0.5
		dagger_instance.position = dagger_pos
		
		print("Spawned dagger at ", dagger_pos)
