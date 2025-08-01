# Constants.gd
# Global constants and enumerations for the game

extends Node

# =============================================================================
# GAME CONSTANTS
# =============================================================================

# Game version
const VERSION: String = "0.1.0-alpha"
const GAME_NAME: String = "Daggerfall Clone"

# =============================================================================
# PLAYER CONSTANTS
# =============================================================================

# Movement speeds (units per second)
const PLAYER_WALK_SPEED: float = 5.0
const PLAYER_RUN_SPEED: float = 8.0
const PLAYER_CROUCH_SPEED: float = 2.5

# Player physics
const PLAYER_JUMP_VELOCITY: float = 12.0
const PLAYER_GRAVITY: float = 25.0
const PLAYER_FRICTION: float = 10.0
const PLAYER_ACCELERATION: float = 8.0

# Player stats
const MAX_HEALTH: int = 100
const MAX_STAMINA: int = 100
const MAX_MANA: int = 100

# =============================================================================
# INVENTORY CONSTANTS
# =============================================================================

# Weight system
const BASE_CARRYING_CAPACITY: float = 50.0  # Base capacity without STR bonus
const STR_CARRY_MULTIPLIER: float = 5.0     # Additional capacity per STR point
const ENCUMBERED_THRESHOLD: float = 0.8     # 80% of max capacity
const OVERLOADED_THRESHOLD: float = 1.0     # 100% of max capacity

# Movement penalties
const ENCUMBERED_SPEED_PENALTY: float = 0.7  # 70% speed when encumbered
const OVERLOADED_SPEED_PENALTY: float = 0.3  # 30% speed when overloaded

# =============================================================================
# COMBAT CONSTANTS
# =============================================================================

# Damage types
enum DamageType {
	PHYSICAL,
	FIRE,
	ICE,
	LIGHTNING,
	POISON,
	MAGIC
}

# Attack types
enum AttackType {
	MELEE,
	RANGED,
	SPELL
}

# =============================================================================
# D&D 5E STATS
# =============================================================================

# Ability scores
enum Ability {
	STRENGTH,
	DEXTERITY,
	CONSTITUTION,
	INTELLIGENCE,
	WISDOM,
	CHARISMA
}

# Stat ranges
const MIN_STAT: int = 3
const MAX_STAT: int = 20
const DEFAULT_STAT: int = 10

# =============================================================================
# ITEM CONSTANTS
# =============================================================================

# Item types
enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	MATERIAL,
	QUEST,
	MISC
}

# Item rarity
enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# Weapon types
enum WeaponType {
	SWORD,
	AXE,
	MACE,
	DAGGER,
	BOW,
	CROSSBOW,
	STAFF,
	WAND
}

# Armor types
enum ArmorType {
	HELMET,
	CHEST,
	LEGS,
	BOOTS,
	GLOVES,
	SHIELD
}

# =============================================================================
# DUNGEON CONSTANTS
# =============================================================================

# Room types
enum RoomType {
	CHAMBER,
	CORRIDOR,
	ENTRANCE,
	EXIT,
	TREASURE,
	BOSS,
	SECRET
}

# Tile types
enum TileType {
	WALL,
	FLOOR,
	DOOR,
	STAIRS_UP,
	STAIRS_DOWN,
	TRAP,
	WATER,
	PIT
}

# Dungeon generation
const MIN_ROOM_SIZE: int = 4
const MAX_ROOM_SIZE: int = 12
const MIN_ROOMS_PER_FLOOR: int = 8
const MAX_ROOMS_PER_FLOOR: int = 15

# =============================================================================
# UI CONSTANTS
# =============================================================================

# Screen dimensions (for UI scaling)
const REFERENCE_RESOLUTION: Vector2 = Vector2(1920, 1080)

# Input action names
const INPUT_MOVE_FORWARD: String = "move_forward"
const INPUT_MOVE_BACKWARD: String = "move_backward"
const INPUT_MOVE_LEFT: String = "move_left"
const INPUT_MOVE_RIGHT: String = "move_right"
const INPUT_JUMP: String = "jump"
const INPUT_RUN: String = "run"
const INPUT_CROUCH: String = "crouch"
const INPUT_INTERACT: String = "interact"
const INPUT_ATTACK: String = "attack"
const INPUT_BLOCK: String = "block"
const INPUT_INVENTORY: String = "inventory"
const INPUT_PAUSE: String = "pause"

# Hotkey slots
const HOTKEY_SLOTS: int = 10

# =============================================================================
# AUDIO CONSTANTS
# =============================================================================

# Audio bus names
const MASTER_BUS: String = "Master"
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"
const VOICE_BUS: String = "Voice"

# =============================================================================
# NETWORKING CONSTANTS (for future multiplayer)
# =============================================================================

const MAX_PLAYERS: int = 4
const DEFAULT_PORT: int = 7777
const MAX_PACKET_SIZE: int = 1024

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

static func get_ability_modifier(ability_score: int) -> int:
	"""Calculate D&D 5E ability modifier from ability score"""
	return (ability_score - 10) / 2

static func clamp_stat(value: int) -> int:
	"""Clamp a stat value to valid range"""
	return clamp(value, MIN_STAT, MAX_STAT)

static func get_rarity_color(rarity: ItemRarity) -> Color:
	"""Get color associated with item rarity"""
	match rarity:
		ItemRarity.COMMON:
			return Color.WHITE
		ItemRarity.UNCOMMON:
			return Color.GREEN
		ItemRarity.RARE:
			return Color.BLUE
		ItemRarity.EPIC:
			return Color.PURPLE
		ItemRarity.LEGENDARY:
			return Color.GOLD
		_:
			return Color.WHITE
