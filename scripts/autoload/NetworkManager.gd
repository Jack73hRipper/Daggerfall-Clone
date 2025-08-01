# NetworkManager.gd
# Handles multiplayer networking (future implementation)
# Currently stubbed for single-player development

extends Node

# Network state
var is_host: bool = false
var is_network_connected: bool = false
var server_port: int = 7777
var max_players: int = 4

# Connected players
var connected_players: Dictionary = {}

# Signals
signal player_connected(id: int)
signal player_disconnected(id: int)
signal connection_established()
signal connection_failed()

func _ready() -> void:
	print("NetworkManager initialized (single-player mode)")
	# Connect multiplayer signals for future implementation
	# multiplayer.peer_connected.connect(_on_player_connected)
	# multiplayer.peer_disconnected.connect(_on_player_disconnected)

# =============================================================================
# HOST FUNCTIONS (for future implementation)
# =============================================================================

func start_host(_port: int = 7777) -> bool:
	"""Start hosting a multiplayer game"""
	print("Host functionality not yet implemented - single-player mode only")
	return false
	
	# Future implementation:
	# var peer = ENetMultiplayerPeer.new()
	# var error = peer.create_server(port, max_players)
	# if error == OK:
	#     multiplayer.multiplayer_peer = peer
	#     is_host = true
	#     is_connected = true
	#     server_port = port
	#     connection_established.emit()
	#     return true
	# return false

func stop_host() -> void:
	"""Stop hosting the game"""
	print("Stopping host (single-player mode)")
	is_host = false
	is_network_connected = false
	connected_players.clear()

# =============================================================================
# CLIENT FUNCTIONS (for future implementation)
# =============================================================================

func join_game(_ip: String, _port: int = 7777) -> bool:
	"""Join a multiplayer game"""
	print("Join functionality not yet implemented - single-player mode only")
	return false
	
	# Future implementation:
	# var peer = ENetMultiplayerPeer.new()
	# var error = peer.create_client(ip, port)
	# if error == OK:
	#     multiplayer.multiplayer_peer = peer
	#     is_host = false
	#     is_connected = true
	#     return true
	# return false

func disconnect_from_game() -> void:
	"""Disconnect from multiplayer game"""
	print("Disconnecting (single-player mode)")
	is_network_connected = false
	connected_players.clear()

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_local_player_id() -> int:
	"""Get the local player's network ID"""
	if is_network_connected:
		return multiplayer.get_unique_id()
	return 1  # Single-player ID

func is_multiplayer_active() -> bool:
	"""Check if multiplayer is currently active"""
	return is_network_connected and connected_players.size() > 0

func get_player_count() -> int:
	"""Get number of connected players"""
	if is_multiplayer_active():
		return connected_players.size() + 1  # +1 for local player
	return 1  # Single-player

# =============================================================================
# RPC FUNCTIONS (for future implementation)
# =============================================================================

@rpc("any_peer", "call_local")
func sync_player_position(_player_id: int, _position: Vector3, _rotation: Vector3) -> void:
	"""Synchronize player position across network"""
	# Future implementation for multiplayer
	pass

@rpc("any_peer", "call_local") 
func sync_item_pickup(_player_id: int, _item_id: String) -> void:
	"""Synchronize item pickup across network"""
	# Future implementation for multiplayer
	pass

@rpc("any_peer", "call_local")
func sync_damage_dealt(_attacker_id: int, _target_id: int, _damage: int) -> void:
	"""Synchronize damage across network"""
	# Future implementation for multiplayer
	pass

# =============================================================================
# SIGNAL HANDLERS (for future implementation)
# =============================================================================

func _on_player_connected(id: int) -> void:
	"""Handle player connection"""
	connected_players[id] = {
		"name": "Player_" + str(id),
		"ready": false
	}
	player_connected.emit(id)
	print("Player connected: ", id)

func _on_player_disconnected(id: int) -> void:
	"""Handle player disconnection"""
	if id in connected_players:
		connected_players.erase(id)
	player_disconnected.emit(id)
	print("Player disconnected: ", id)

# =============================================================================
# DEBUG FUNCTIONS
# =============================================================================

func print_network_status() -> void:
	"""Print current network status for debugging"""
	print("=== Network Status ===")
	print("Mode: Single-player")
	print("Host: ", is_host)
	print("Connected: ", is_network_connected)
	print("Players: ", get_player_count())
	print("=====================")
