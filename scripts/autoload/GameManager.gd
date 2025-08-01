# GameManager.gd
# Global game state management singleton
# Handles core game systems and state transitions

extends Node

# Game state enumeration
enum GameState {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# Current game state
var current_state: GameState = GameState.MENU

# Player management
var players: Array[Node] = []
var local_player: Node = null

# Dungeon management
var current_dungeon: Node = null
var current_floor: int = 1

# Game settings
var game_settings: Dictionary = {
	"max_players": 4,
	"difficulty": 1,
	"friendly_fire": false
}

# Signals for state changes
signal state_changed(new_state: GameState)
signal player_joined(player: Node)
signal player_left(player: Node)
signal floor_changed(new_floor: int)

func _ready() -> void:
	print("GameManager initialized")
	# Load game settings
	load_settings()

func change_state(new_state: GameState) -> void:
	"""Change the current game state"""
	if current_state != new_state:
		var old_state = current_state
		current_state = new_state
		print("Game state changed from ", GameState.keys()[old_state], " to ", GameState.keys()[new_state])
		state_changed.emit(new_state)

func add_player(player: Node) -> void:
	"""Add a player to the game"""
	if players.size() < game_settings.max_players:
		players.append(player)
		if local_player == null:
			local_player = player
		player_joined.emit(player)
		print("Player added: ", player.name)

func remove_player(player: Node) -> void:
	"""Remove a player from the game"""
	if player in players:
		players.erase(player)
		if local_player == player:
			local_player = null
		player_left.emit(player)
		print("Player removed: ", player.name)

func advance_floor() -> void:
	"""Advance to the next dungeon floor"""
	current_floor += 1
	floor_changed.emit(current_floor)
	print("Advanced to floor: ", current_floor)

func reset_game() -> void:
	"""Reset game to initial state"""
	current_floor = 1
	players.clear()
	local_player = null
	current_dungeon = null
	change_state(GameState.MENU)
	print("Game reset")

func load_settings() -> void:
	"""Load game settings from file"""
	# TODO: Implement settings loading
	print("Settings loaded")

func save_settings() -> void:
	"""Save game settings to file"""
	# TODO: Implement settings saving
	print("Settings saved")

func get_player_count() -> int:
	"""Get current number of players"""
	return players.size()

func is_multiplayer() -> bool:
	"""Check if game is in multiplayer mode"""
	return players.size() > 1
