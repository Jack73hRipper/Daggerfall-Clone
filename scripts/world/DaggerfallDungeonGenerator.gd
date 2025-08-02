extends Node3D

const TILE_SIZE = 2.0

# Room Types with Properties (from design team)
enum RoomType {
	SMALL_CHAMBER,     # 8x8 to 12x12
	LARGE_CHAMBER,     # 16x16 to 24x24
	HALLWAY,           # 4x12 to 6x20
	SIDE_ROOM,         # 6x6 to 8x10
	BOSS_ROOM          # 20x20 to 32x32
}

# Wall Direction System (from design team)
enum WallDirection {
	NORTH,     # Faces south (blocks movement north)
	SOUTH,     # Faces north (blocks movement south)  
	EAST,      # Faces west (blocks movement east)
	WEST       # Faces east (blocks movement west)
}

# Corridor Types
enum CorridorType {
	STRAIGHT,          # Direct line between rooms
	L_SHAPED,          # One 90-degree turn
	ZIGZAG,            # Multiple turns for interesting paths
	WIDE_HALL          # 3-4 units wide instead of 2
}

# Room Data Structure (from design team)
class Room:
	var position: Vector2i
	var size: Vector2i
	var room_type: RoomType
	var ceiling_height: float
	var connections: Array[Vector2i] = []  # Connection points for corridors
	var connected: bool = false
	
	func _init(pos: Vector2i, sz: Vector2i, type: RoomType):
		position = pos
		size = sz
		room_type = type
		ceiling_height = get_ceiling_height(type)
	
	func get_center() -> Vector2i:
		return Vector2i(position.x + int(size.x / 2.0), position.y + int(size.y / 2.0))
	
	func get_connection_point() -> Vector2i:
		# Return a random point on the room's perimeter
		var side = randi() % 4
		match side:
			0: # Top
				return Vector2i(position.x + randi() % size.x, position.y)
			1: # Bottom
				return Vector2i(position.x + randi() % size.x, position.y + size.y - 1)
			2: # Left
				return Vector2i(position.x, position.y + randi() % size.y)
			3: # Right
				return Vector2i(position.x + size.x - 1, position.y + randi() % size.y)
		return get_center()
	
	func overlaps(other: Room) -> bool:
		var rect1 = Rect2i(position, size)
		var rect2 = Rect2i(other.position, other.size)
		return rect1.intersects(rect2)
	
	func get_ceiling_height(_type: RoomType) -> float:
		# Single unified ceiling height for all rooms
		return 4.0

# Corridor Data Structure
class Corridor:
	var start_room: Room
	var end_room: Room
	var path_points: Array[Vector2i] = []
	var corridor_type: CorridorType
	var width: int = 2
	
	func _init(room_a: Room, room_b: Room, type: CorridorType = CorridorType.L_SHAPED):
		start_room = room_a
		end_room = room_b
		corridor_type = type
		generate_path()
	
	func generate_path():
		var start_point = start_room.get_connection_point()
		var end_point = end_room.get_connection_point()
		
		match corridor_type:
			CorridorType.STRAIGHT:
				create_straight_path(start_point, end_point)
			CorridorType.L_SHAPED:
				create_l_shaped_path(start_point, end_point)
			CorridorType.WIDE_HALL:
				width = 3
				create_l_shaped_path(start_point, end_point)
	
	func create_straight_path(start: Vector2i, end: Vector2i):
		path_points = [start, end]
	
	func create_l_shaped_path(start: Vector2i, end: Vector2i):
		# Create L-shaped path with corner
		var corner = Vector2i(end.x, start.y)
		path_points = [start, corner, end]

# Main generator variables
var dungeon_size: Vector2i = Vector2i(50, 50)
var rooms: Array[Room] = []
var corridors: Array[Corridor] = []
var grid: Array[Array] = []
var spawn_points: Array[Vector3] = []

# Grid values
const WALL_INTERIOR = 0  # Interior dungeon walls (allow torches)
const FLOOR = 1
const DOOR = 2
const WALL_TOMB = 3      # Exterior tomb walls (no torches)

# Legacy constant for backward compatibility during transition
const WALL = WALL_INTERIOR

func _ready():
	print("Starting Daggerfall-style dungeon generation...")
	generate_dungeon()

func generate_dungeon():
	"""Main generation pipeline following design team recommendations"""
	# Clear previous data
	clear_dungeon_data()
	
	print("=== Phase 1: Room Generation ===")
	initialize_grid()
	generate_main_rooms()
	add_secondary_rooms()
	
	print("=== Phase 2: Corridor System ===")
	connect_rooms_with_corridors()
	
	print("=== Phase 3: Wall Generation ===")
	mark_floor_areas()
	generate_walls_with_directions()
	create_doorways()
	
	print("=== Phase 4: 3D Building ===")
	build_3d_geometry()
	
	print("=== Phase 5: Wall-Mounted Torch Placement ===")
	place_wall_mounted_torches()
	
	print("=== Phase 6: Enemy Spawning ===")
	spawn_dungeon_enemies()
	
	print("=== Dungeon Generation Complete ===")

func clear_dungeon_data():
	"""Clear all previous dungeon data and 3D geometry"""
	# Clear 3D nodes immediately (not queue_free)
	var children_to_remove = []
	for child in get_children():
		children_to_remove.append(child)
	
	for child in children_to_remove:
		remove_child(child)
		child.queue_free()
	
	# Clear data structures
	rooms.clear()
	corridors.clear()
	spawn_points.clear()
	grid.clear()

func initialize_grid():
	"""Initialize the grid with tomb walls on perimeter and empty interior"""
	grid = []
	for x in range(dungeon_size.x):
		grid.append([])
		for y in range(dungeon_size.y):
			# Create tomb boundary walls on the perimeter
			if x == 0 or x == dungeon_size.x - 1 or y == 0 or y == dungeon_size.y - 1:
				grid[x].append(WALL_TOMB)
			else:
				# Interior starts empty - walls will be added only where needed
				grid[x].append(WALL_TOMB)  # Start with tomb walls, will be overwritten

func generate_main_rooms():
	"""Phase 1 Step 1: Place 3-5 large chambers randomly with minimum distance"""
	var main_room_count = randi_range(3, 5)
	var attempts = 0
	var max_attempts = 100
	
	while rooms.size() < main_room_count and attempts < max_attempts:
		var room_type = RoomType.LARGE_CHAMBER if randf() > 0.3 else RoomType.SMALL_CHAMBER
		var room_size = get_room_size(room_type)
		var room_pos = Vector2i(
			randi_range(5, dungeon_size.x - room_size.x - 5),
			randi_range(5, dungeon_size.y - room_size.y - 5)
		)
		
		var new_room = Room.new(room_pos, room_size, room_type)
		
		# Check minimum distance from other rooms
		var valid = true
		for existing_room in rooms:
			var distance = new_room.get_center().distance_to(existing_room.get_center())
			if distance < 15 or new_room.overlaps(existing_room):
				valid = false
				break
		
		if valid:
			rooms.append(new_room)
		
		attempts += 1
	
	print("Generated ", rooms.size(), " main rooms")

func add_secondary_rooms():
	"""Phase 1 Step 2: Fill gaps with small chambers and side rooms"""
	var secondary_room_count = randi_range(4, 8)
	var attempts = 0
	var max_attempts = 200
	
	while rooms.size() < rooms.size() + secondary_room_count and attempts < max_attempts:
		var room_type = RoomType.SIDE_ROOM if randf() > 0.4 else RoomType.SMALL_CHAMBER
		if randf() > 0.9:  # 10% chance for boss room
			room_type = RoomType.BOSS_ROOM
		
		var room_size = get_room_size(room_type)
		var room_pos = Vector2i(
			randi_range(3, dungeon_size.x - room_size.x - 3),
			randi_range(3, dungeon_size.y - room_size.y - 3)
		)
		
		var new_room = Room.new(room_pos, room_size, room_type)
		
		# Check spacing (smaller spacing for secondary rooms)
		var valid = true
		for existing_room in rooms:
			var distance = new_room.get_center().distance_to(existing_room.get_center())
			if distance < 8 or new_room.overlaps(existing_room):
				valid = false
				break
		
		if valid:
			rooms.append(new_room)
		
		attempts += 1
	
	print("Total rooms generated: ", rooms.size())

func get_room_size(room_type: RoomType) -> Vector2i:
	"""Get appropriate size range for room type"""
	match room_type:
		RoomType.SMALL_CHAMBER:
			return Vector2i(randi_range(8, 12), randi_range(8, 12))
		RoomType.LARGE_CHAMBER:
			return Vector2i(randi_range(16, 24), randi_range(16, 24))
		RoomType.HALLWAY:
			return Vector2i(randi_range(4, 6), randi_range(12, 20))
		RoomType.SIDE_ROOM:
			return Vector2i(randi_range(6, 8), randi_range(6, 10))
		RoomType.BOSS_ROOM:
			return Vector2i(randi_range(20, 32), randi_range(20, 32))
	return Vector2i(8, 8)

func connect_rooms_with_corridors():
	"""Phase 2: Create corridor system connecting all rooms with guaranteed connectivity"""
	if rooms.size() <= 1:
		return
	
	# Start with the first room as the connected network
	var connected_rooms: Array[Room] = [rooms[0]]
	var unconnected_rooms: Array[Room] = []
	
	# Add all other rooms to unconnected list
	for i in range(1, rooms.size()):
		unconnected_rooms.append(rooms[i])
	
	# Connect each unconnected room to the nearest connected room
	while unconnected_rooms.size() > 0:
		var best_distance = 999999.0
		var best_unconnected = null
		var best_connected = null
		
		# Find the shortest connection between any unconnected room and any connected room
		for unconnected in unconnected_rooms:
			for connected in connected_rooms:
				var distance = unconnected.get_center().distance_to(connected.get_center())
				if distance < best_distance:
					best_distance = distance
					best_unconnected = unconnected
					best_connected = connected
		
		# Create the corridor
		if best_unconnected and best_connected:
			var corridor = Corridor.new(best_unconnected, best_connected, CorridorType.L_SHAPED)
			corridors.append(corridor)
			
			# Move the room from unconnected to connected
			connected_rooms.append(best_unconnected)
			unconnected_rooms.erase(best_unconnected)
			
			# Mark both rooms as connected
			best_unconnected.connected = true
			best_connected.connected = true
	
	print("Generated ", corridors.size(), " corridors - all rooms connected")

func mark_floor_areas():
	"""Mark all room and corridor areas as floor in the grid"""
	# Mark room floors
	for room in rooms:
		for x in range(room.position.x, room.position.x + room.size.x):
			for y in range(room.position.y, room.position.y + room.size.y):
				if x >= 0 and x < dungeon_size.x and y >= 0 and y < dungeon_size.y:
					grid[x][y] = FLOOR
	
	# Mark corridor floors
	for corridor in corridors:
		for i in range(corridor.path_points.size() - 1):
			var start = corridor.path_points[i]
			var end = corridor.path_points[i + 1]
			mark_corridor_segment(start, end, corridor.width)

func mark_corridor_segment(start: Vector2i, end: Vector2i, width: int):
	"""Mark a corridor segment as floor with given width"""
	var half_width = int(width / 2.0)
	
	if start.x == end.x:  # Vertical corridor
		for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			for w in range(-half_width, half_width + 1):
				var x = start.x + w
				if x >= 0 and x < dungeon_size.x and y >= 0 and y < dungeon_size.y:
					grid[x][y] = FLOOR
	else:  # Horizontal corridor
		for x in range(min(start.x, end.x), max(start.x, end.x) + 1):
			for w in range(-half_width, half_width + 1):
				var y = start.y + w
				if x >= 0 and x < dungeon_size.x and y >= 0 and y < dungeon_size.y:
					grid[x][y] = FLOOR

func generate_walls_with_directions():
	"""Phase 3: Generate walls using directional system"""
	# For each room, generate walls around perimeter
	for room in rooms:
		generate_room_walls(room)

func generate_room_walls(room: Room):
	"""Generate walls around room perimeter with proper directions"""
	var pos = room.position
	var size = room.size
	
	# North wall (top edge) - faces south
	for x in range(pos.x - 1, pos.x + size.x + 1):
		place_wall(Vector2i(x, pos.y - 1), WallDirection.NORTH)
	
	# South wall (bottom edge) - faces north
	for x in range(pos.x - 1, pos.x + size.x + 1):
		place_wall(Vector2i(x, pos.y + size.y), WallDirection.SOUTH)
	
	# West wall (left edge) - faces east
	for y in range(pos.y - 1, pos.y + size.y + 1):
		place_wall(Vector2i(pos.x - 1, y), WallDirection.WEST)
	
	# East wall (right edge) - faces west
	for y in range(pos.y - 1, pos.y + size.y + 1):
		place_wall(Vector2i(pos.x + size.x, y), WallDirection.EAST)

func place_wall(pos: Vector2i, _direction: WallDirection):
	"""Place an interior wall at position with specific direction, unless it's floor area"""
	if pos.x >= 0 and pos.x < dungeon_size.x and pos.y >= 0 and pos.y < dungeon_size.y:
		if grid[pos.x][pos.y] != FLOOR:  # Don't place walls over floor areas
			grid[pos.x][pos.y] = WALL_INTERIOR  # Use interior walls for room boundaries

func is_adjacent_to_floor(pos: Vector2i) -> bool:
	"""Check if position is adjacent to any floor tile (simplified since we're now precise about wall creation)"""
	var adjacent_positions = [
		Vector2i(pos.x, pos.y - 1),  # North
		Vector2i(pos.x + 1, pos.y),  # East
		Vector2i(pos.x, pos.y + 1),  # South
		Vector2i(pos.x - 1, pos.y)   # West
	]
	
	for adj_pos in adjacent_positions:
		if adj_pos.x >= 0 and adj_pos.x < dungeon_size.x and adj_pos.y >= 0 and adj_pos.y < dungeon_size.y:
			if grid[adj_pos.x][adj_pos.y] == FLOOR:
				return true
	return false

func create_doorways():
	"""Create doorways where corridors meet rooms"""
	for corridor in corridors:
		# Create doorways at room connection points
		for point in corridor.path_points:
			if point.x >= 0 and point.x < dungeon_size.x and point.y >= 0 and point.y < dungeon_size.y:
				# Check if this point is adjacent to a room
				for room in rooms:
					if is_point_adjacent_to_room(point, room):
						grid[point.x][point.y] = DOOR

func is_point_adjacent_to_room(point: Vector2i, room: Room) -> bool:
	"""Check if point is adjacent to room boundary"""
	var room_rect = Rect2i(room.position, room.size)
	var expanded_rect = Rect2i(room.position - Vector2i(1, 1), room.size + Vector2i(2, 2))
	return expanded_rect.has_point(point) and not room_rect.has_point(point)

func get_wall_height_at_position(_pos: Vector2i) -> float:
	"""Simplified: Single wall height for all positions"""
	return 4.0

func is_position_in_room_walls(pos: Vector2i, room: Room) -> bool:
	"""Check if position is part of room's wall perimeter"""
	var room_rect = Rect2i(room.position - Vector2i(1, 1), room.size + Vector2i(2, 2))
	var inner_rect = Rect2i(room.position, room.size)
	return room_rect.has_point(pos) and not inner_rect.has_point(pos)

func build_3d_geometry():
	"""Phase 4: Build the actual 3D geometry"""
	var floor_count = 0
	var wall_count = 0
	var door_count = 0
	var height_stats = {}  # Track wall height distribution
	
	# Build floors
	for x in range(dungeon_size.x):
		for y in range(dungeon_size.y):
			var world_pos = Vector3(x * TILE_SIZE, 0, y * TILE_SIZE)
			
			if grid[x][y] == FLOOR or grid[x][y] == DOOR:
				var floor_instance = create_floor_node()
				floor_instance.position = world_pos
				add_child(floor_instance)
				floor_count += 1
				
				# Set spawn point in first room
				if spawn_points.is_empty() and rooms.size() > 0:
					if rooms[0].position.x <= x and x < rooms[0].position.x + rooms[0].size.x:
						if rooms[0].position.y <= y and y < rooms[0].position.y + rooms[0].size.y:
							spawn_points.append(world_pos + Vector3(0, 1.0, 0))
	
	# Build walls with room-specific heights (both interior and tomb walls)
	for x in range(dungeon_size.x):
		for y in range(dungeon_size.y):
			if grid[x][y] == WALL_INTERIOR or grid[x][y] == WALL_TOMB:
				var pos = Vector2i(x, y)
				var wall_height = get_wall_height_at_position(pos)
				var is_tomb_wall = (grid[x][y] == WALL_TOMB)
				var wall_instance = create_wall_node(wall_height, is_tomb_wall)
				wall_instance.position = Vector3(x * TILE_SIZE, 0, y * TILE_SIZE)
				add_child(wall_instance)
				wall_count += 1
				
				# Track height stats for analysis
				var height_key = str(wall_height)
				if height_key in height_stats:
					height_stats[height_key] += 1
				else:
					height_stats[height_key] = 1
	
	# Build simple ceilings at uniform height
	build_simple_ceilings()

	print("Built ", floor_count, " floors, ", wall_count, " walls, ", door_count, " doors with simple unified ceilings")
	print("Wall Height Distribution: ", height_stats)
	print("Using unified 4.0 unit height for all walls and ceilings")

func get_room_type_name(room_type: RoomType) -> String:
	"""Get display name for room type"""
	match room_type:
		RoomType.SMALL_CHAMBER:
			return "Small Chamber"
		RoomType.LARGE_CHAMBER:
			return "Large Chamber"
		RoomType.HALLWAY:
			return "Hallway"
		RoomType.SIDE_ROOM:
			return "Side Room"
		RoomType.BOSS_ROOM:
			return "Boss Room"
	return "Unknown"

func create_floor_node() -> StaticBody3D:
	"""Create a floor tile"""
	var floor_node = StaticBody3D.new()
	floor_node.name = "Floor"
	floor_node.collision_layer = 1
	floor_node.collision_mask = 0
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(TILE_SIZE, 0.2, TILE_SIZE)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = -0.1
	
	var material = StandardMaterial3D.new()
	# Load wood floor texture
	var floor_texture = load("res://assets/textures/materials/wood_floor.png")
	if floor_texture:
		material.albedo_texture = floor_texture
		# Configure texture tiling for seamless floors
		material.uv1_scale = Vector3(1.0, 1.0, 1.0)  # Adjust tiling as needed
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	else:
		material.albedo_color = Color(0.4, 0.3, 0.2)  # Fallback stone floor color
	mesh_instance.material_override = material
	
	floor_node.add_child(mesh_instance)
	
	# Add collision for the floor
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(TILE_SIZE, 0.2, TILE_SIZE)
	collision.shape = box_shape
	collision.position.y = -0.1
	floor_node.add_child(collision)
	
	return floor_node

func create_wall_node(wall_height: float = 4.0, is_tomb_wall: bool = false) -> StaticBody3D:
	"""Create a wall tile with specified height and material type"""
	var wall_node = StaticBody3D.new()
	wall_node.name = "TombWall" if is_tomb_wall else "InteriorWall"
	wall_node.collision_layer = 1
	wall_node.collision_mask = 0
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(TILE_SIZE, wall_height, TILE_SIZE)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = wall_height / 2.0  # Center the wall vertically
	
	var material = StandardMaterial3D.new()
	
	if is_tomb_wall:
		# Tomb walls: darker, more weathered appearance
		var tomb_texture = load("res://assets/textures/materials/stone_wall.png")  # Could use different texture later
		if tomb_texture:
			material.albedo_texture = tomb_texture
			material.uv1_scale = Vector3(1.0, 1.0, 1.0)
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			# Make tomb walls darker and more imposing
			material.albedo_color = Color(0.4, 0.3, 0.3)  # Darker tint
		else:
			material.albedo_color = Color(0.3, 0.2, 0.2)  # Dark tomb stone
	else:
		# Interior walls: normal dungeon appearance
		var wall_texture = load("res://assets/textures/materials/stone_wall.png")
		if wall_texture:
			material.albedo_texture = wall_texture
			material.uv1_scale = Vector3(1.0, 1.0, 1.0)  # Adjust tiling as needed
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		else:
			material.albedo_color = Color(0.6, 0.5, 0.4)  # Fallback stone wall color
	
	mesh_instance.material_override = material
	
	wall_node.add_child(mesh_instance)
	
	# Add collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(TILE_SIZE, wall_height, TILE_SIZE)
	collision.shape = box_shape
	collision.position.y = wall_height / 2.0
	wall_node.add_child(collision)
	
	return wall_node

func build_room_ceiling(room: Room):
	"""Build ceiling for a specific room at its designated height"""
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			if x >= 0 and x < dungeon_size.x and y >= 0 and y < dungeon_size.y:
				if grid[x][y] == FLOOR:  # Only add ceiling over floor areas
					var ceiling_instance = create_ceiling_node()
					var world_pos = Vector3(x * TILE_SIZE, room.ceiling_height, y * TILE_SIZE)
					ceiling_instance.position = world_pos
					add_child(ceiling_instance)

func build_simple_ceilings():
	"""Build simple uniform ceilings at 4.0 height over all floor areas"""
	var ceiling_count = 0
	
	# Build ceiling over every floor tile at uniform height
	for x in range(dungeon_size.x):
		for y in range(dungeon_size.y):
			if grid[x][y] == FLOOR:
				var ceiling_instance = create_ceiling_node()
				var world_pos = Vector3(x * TILE_SIZE, 4.0, y * TILE_SIZE)
				ceiling_instance.position = world_pos
				add_child(ceiling_instance)
				ceiling_count += 1
	
	print("Built ", ceiling_count, " uniform ceiling tiles at 4.0 height")

func create_ceiling_node() -> StaticBody3D:
	"""Create a ceiling tile"""
	var ceiling_node = StaticBody3D.new()
	ceiling_node.name = "Ceiling"
	ceiling_node.collision_layer = 1
	ceiling_node.collision_mask = 0
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(TILE_SIZE, 0.2, TILE_SIZE)
	mesh_instance.mesh = box_mesh
	mesh_instance.position.y = 0.1
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.25, 0.2)  # Darker stone ceiling color
	mesh_instance.material_override = material
	
	ceiling_node.add_child(mesh_instance)
	
	# Add collision (so players can't go above ceiling)
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(TILE_SIZE, 0.2, TILE_SIZE)
	collision.shape = box_shape
	collision.position.y = 0.1
	ceiling_node.add_child(collision)
	
	return ceiling_node

func get_spawn_points() -> Array[Vector3]:
	"""Return player spawn points"""
	return spawn_points

func get_room_centers() -> Array[Vector3]:
	"""Return center points of all generated rooms"""
	var centers: Array[Vector3] = []
	for room in rooms:
		var center_x = (room.position.x + room.size.x / 2.0) * TILE_SIZE
		var center_z = (room.position.y + room.size.y / 2.0) * TILE_SIZE
		centers.append(Vector3(center_x, 0, center_z))
	return centers

func regenerate_dungeon():
	"""Public function to regenerate dungeon - called by TestSceneController"""
	generate_dungeon()

# =============================================================================
# WALL-MOUNTED TORCH LIGHTING SYSTEM
# Wall torches spawn with configurable percentage chance during wall creation
# =============================================================================

var torch_scene: PackedScene
var total_torch_count: int = 0
var torch_spawn_chance: float = 0.1  # 10% chance (1 in 10 walls) - Adjust this for more/fewer torches

func place_wall_mounted_torches():
	"""Phase 5: Place wall-mounted sconce torches with percentage-based spawning"""
	# Load torch scene
	torch_scene = load("res://scenes/world/Torch.tscn")
	if not torch_scene:
		print("Warning: Could not load Torch.tscn - skipping torch placement")
		return
	
	total_torch_count = 0
	
	# Go through all interior walls and potentially add torches (skip tomb walls)
	for x in range(dungeon_size.x):
		for y in range(dungeon_size.y):
			if grid[x][y] == WALL_INTERIOR:
				# Check if this wall should have a torch (percentage chance)
				if randf() < torch_spawn_chance:
					# Make sure there's at least one adjacent floor tile for proper mounting
					if has_adjacent_floor(Vector2i(x, y)) and is_proper_room_wall(Vector2i(x, y)):
						place_wall_sconce_torch(Vector2i(x, y))
	
	print("Placed ", total_torch_count, " wall-mounted sconce torches (", 
		  int(torch_spawn_chance * 100), "% spawn rate)")

func is_proper_room_wall(wall_pos: Vector2i) -> bool:
	"""Check if this wall is actually on the perimeter of a room (not floating)"""
	# Check if this wall position is within 1 tile of any room boundary
	for room in rooms:
		var room_boundary = Rect2i(room.position - Vector2i(1, 1), room.size + Vector2i(2, 2))
		if room_boundary.has_point(wall_pos):
			# Make sure it's not inside the room itself
			var room_interior = Rect2i(room.position, room.size)
			if not room_interior.has_point(wall_pos):
				return true
	return false

func has_adjacent_floor(wall_pos: Vector2i) -> bool:
	"""Check if wall has at least one adjacent floor tile for proper torch mounting"""
	# Check all 4 directions for floor tiles
	var adjacent_positions = [
		Vector2i(wall_pos.x, wall_pos.y - 1),  # North
		Vector2i(wall_pos.x + 1, wall_pos.y),  # East
		Vector2i(wall_pos.x, wall_pos.y + 1),  # South
		Vector2i(wall_pos.x - 1, wall_pos.y)   # West
	]
	
	var floor_count = 0
	for pos in adjacent_positions:
		if pos.x >= 0 and pos.x < dungeon_size.x and pos.y >= 0 and pos.y < dungeon_size.y:
			if grid[pos.x][pos.y] == FLOOR:
				floor_count += 1
	
	# Only place torches on walls with 1-3 adjacent floors (proper room walls)
	# This prevents torches on isolated walls but allows most normal wall positions
	return floor_count >= 1 and floor_count <= 3

func place_wall_sconce_torch(wall_pos: Vector2i):
	"""Place a wall-mounted sconce torch on the specified wall"""
	if not torch_scene:
		return
	
	# Convert grid position to world position (center of wall tile)
	var world_pos = Vector3(wall_pos.x * TILE_SIZE, 0, wall_pos.y * TILE_SIZE)
	
	# Find which direction the torch should face (towards adjacent floor)
	var torch_direction = find_torch_facing_direction(wall_pos)
	
	# Create torch instance
	var torch_instance = torch_scene.instantiate()
	
	# Position torch on the wall surface facing the room (not inside the wall)
	var wall_surface_offset = get_wall_surface_offset(torch_direction)
	torch_instance.position = world_pos + Vector3(0, 2.0, 0) + wall_surface_offset
	
	# Rotate torch to face into the room/corridor
	torch_instance.rotation = get_wall_sconce_rotation(torch_direction)
	
	add_child(torch_instance)
	total_torch_count += 1

func find_torch_facing_direction(wall_pos: Vector2i) -> WallDirection:
	"""Find which direction the torch should face using priority-based selection for consistency"""
	# Check directions in priority order: North, East, South, West (deterministic)
	# Face TOWARD the floor (into the dungeon interior), not away from it
	var priority_directions = [
		{dir = WallDirection.NORTH, check = Vector2i(0, -1)},   # Floor to north = face north
		{dir = WallDirection.EAST, check = Vector2i(1, 0)},     # Floor to east = face east  
		{dir = WallDirection.SOUTH, check = Vector2i(0, 1)},    # Floor to south = face south
		{dir = WallDirection.WEST, check = Vector2i(-1, 0)}     # Floor to west = face west
	]
	
	# Return the FIRST valid direction found (ensures consistency)
	for direction in priority_directions:
		var check_pos = wall_pos + direction.check
		if check_pos.x >= 0 and check_pos.x < dungeon_size.x and check_pos.y >= 0 and check_pos.y < dungeon_size.y:
			if grid[check_pos.x][check_pos.y] == FLOOR:
				return direction.dir
	
	return WallDirection.SOUTH  # Default if no floor found

func get_wall_sconce_rotation(facing_direction: WallDirection) -> Vector3:
	"""Get rotation for wall-mounted torch to face into room/corridor"""
	match facing_direction:
		WallDirection.NORTH:
			return Vector3(0, 0, 0)        # Face north into room
		WallDirection.SOUTH: 
			return Vector3(0, PI, 0)       # Face south into room
		WallDirection.EAST:
			return Vector3(0, PI/2, 0)     # Face east into room
		WallDirection.WEST:
			return Vector3(0, -PI/2, 0)    # Face west into room
	return Vector3.ZERO

func get_wall_surface_offset(facing_direction: WallDirection) -> Vector3:
	"""Get offset to position torch on interior wall surface facing into dungeon"""
	# Offset must be greater than half wall thickness (1.0) to clear the wall
	var surface_offset = TILE_SIZE * 0.6  # 0.6 = 1.2 units - outside wall thickness
	
	# Move torch to the interior side of the wall (opposite to facing direction)
	match facing_direction:
		WallDirection.NORTH:
			return Vector3(0, 0, surface_offset)   # Wall faces north, torch on south side (interior)
		WallDirection.SOUTH:
			return Vector3(0, 0, -surface_offset)  # Wall faces south, torch on north side (interior) 
		WallDirection.EAST:
			return Vector3(-surface_offset, 0, 0)  # Wall faces east, torch on west side (interior)
		WallDirection.WEST:
			return Vector3(surface_offset, 0, 0)   # Wall faces west, torch on east side (interior)
	return Vector3.ZERO

func is_wall_at_position(pos: Vector2i) -> bool:
	"""Check if there's a wall (interior or tomb) at the given position"""
	if pos.x < 0 or pos.x >= dungeon_size.x or pos.y < 0 or pos.y >= dungeon_size.y:
		return true  # Consider out-of-bounds as walls
	return grid[pos.x][pos.y] == WALL_INTERIOR or grid[pos.x][pos.y] == WALL_TOMB

func is_door_at_position(pos: Vector2i) -> bool:
	"""Check if there's a door at the given position"""
	if pos.x < 0 or pos.x >= dungeon_size.x or pos.y < 0 or pos.y >= dungeon_size.y:
		return false
	return grid[pos.x][pos.y] == DOOR

# =============================================================================
# ENEMY SPAWNING SYSTEM
# =============================================================================

var enemy_scenes: Array[PackedScene] = []
var total_enemy_count: int = 0

func spawn_dungeon_enemies():
	"""Phase 6: Spawn enemies throughout the dungeon"""
	# Load enemy scenes
	load_enemy_scenes()
	
	if enemy_scenes.is_empty():
		print("Warning: No enemy scenes loaded - skipping enemy spawning")
		return
	
	total_enemy_count = 0
	
	# Spawn enemies in each room
	for room in rooms:
		spawn_room_enemies(room)
	
	print("Spawned ", total_enemy_count, " enemies in dungeon")

func load_enemy_scenes():
	"""Load all enemy scene files"""
	var skeleton_scene = load("res://scenes/enemies/SkeletonMinion.tscn")
	var slime_scene = load("res://scenes/enemies/Slime.tscn")
	var bat_scene = load("res://scenes/enemies/Bat.tscn")
	
	if skeleton_scene:
		enemy_scenes.append(skeleton_scene)
	if slime_scene:
		enemy_scenes.append(slime_scene)
	if bat_scene:
		enemy_scenes.append(bat_scene)

func spawn_room_enemies(room: Room):
	"""Spawn enemies in a specific room"""
	var enemy_count = get_room_enemy_count(room.room_type)
	
	for i in range(enemy_count):
		var spawn_pos = get_random_room_position(room)
		if spawn_pos != Vector2i(-1, -1):
			spawn_enemy_at_position(spawn_pos)

func get_room_enemy_count(room_type: RoomType) -> int:
	"""Get appropriate number of enemies for room type"""
	match room_type:
		RoomType.SMALL_CHAMBER:
			return randi_range(0, 1)  # 0-1 enemies
		RoomType.LARGE_CHAMBER:
			return randi_range(1, 2)  # 1-2 enemies
		RoomType.HALLWAY:
			return 0  # No enemies in hallways
		RoomType.SIDE_ROOM:
			return randi_range(0, 1)  # 0-1 enemies
		RoomType.BOSS_ROOM:
			return randi_range(2, 3)  # 2-3 enemies (future: replace with boss)
	return 0

func get_random_room_position(room: Room) -> Vector2i:
	"""Get a random valid position inside a room for enemy spawning"""
	var attempts = 0
	var max_attempts = 20
	
	while attempts < max_attempts:
		var x = randi_range(room.position.x + 1, room.position.x + room.size.x - 2)
		var y = randi_range(room.position.y + 1, room.position.y + room.size.y - 2)
		var pos = Vector2i(x, y)
		
		if is_valid_enemy_spawn_position(pos):
			return pos
		
		attempts += 1
	
	return Vector2i(-1, -1)  # Invalid position

func is_valid_enemy_spawn_position(pos: Vector2i) -> bool:
	"""Check if position is valid for enemy spawning"""
	if pos.x < 0 or pos.x >= dungeon_size.x or pos.y < 0 or pos.y >= dungeon_size.y:
		return false
	
	# Must be on floor
	if grid[pos.x][pos.y] != FLOOR:
		return false
	
	# Don't spawn too close to spawn points (player starting area)
	for spawn_point in spawn_points:
		var spawn_grid = Vector2i(int(spawn_point.x / TILE_SIZE), int(spawn_point.z / TILE_SIZE))
		if pos.distance_to(spawn_grid) < 5:  # Keep 5 tile radius clear
			return false
	
	return true

func spawn_enemy_at_position(grid_pos: Vector2i):
	"""Spawn a random enemy at the specified grid position"""
	if enemy_scenes.is_empty():
		return
	
	# Choose random enemy type
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy_instance = enemy_scene.instantiate()
	
	# Convert grid position to world position
	var world_pos = Vector3(grid_pos.x * TILE_SIZE, 0.0, grid_pos.y * TILE_SIZE)
	
	# Special positioning for different enemy types
	print("Spawning enemy: " + enemy_instance.name + " at position: " + str(world_pos))
	
	if "Bat" in enemy_instance.name or enemy_instance.get_script() == preload("res://scripts/enemies/BatEnemy.gd"):
		# Bats fly at a reasonable height, not ceiling level
		world_pos.y = 1.8  # Lower height to avoid ceiling clipping
		print("Adjusted bat height to: " + str(world_pos.y))
	else:
		# Ground enemies should be exactly on the floor
		world_pos.y = 0.0
	
	enemy_instance.position = world_pos
	
	add_child(enemy_instance)
	total_enemy_count += 1
