# Technical Architecture

## Project Structure Overview

```
DaggerfallClone/
├── scenes/          # Scene files (.tscn)
├── scripts/         # Script files (.gd)
├── assets/          # Art and audio assets
├── data/            # Game data (JSON/resources)
├── docs/            # Documentation
└── tools/           # Development utilities
```

## Godot 4 Node Hierarchy

### Main Scene Structure
```
Main (Node3D)
├── GameManager (autoload singleton)
├── Player (CharacterBody3D)
│   ├── CameraController (Node3D)
│   │   └── Camera3D
│   ├── PlayerMesh (Sprite3D)
│   ├── CollisionShape3D
│   └── InteractionArea (Area3D)
├── World (Node3D)
│   ├── DungeonGenerator (Node3D)
│   ├── CurrentLevel (Node3D)
│   └── Items (Node3D)
├── UI (CanvasLayer)
│   ├── HUD
│   ├── Inventory
│   └── MainMenu
└── Audio (Node3D)
    ├── MusicPlayer (AudioStreamPlayer)
    ├── SFXPlayer (AudioStreamPlayer3D)
    └── VoicePlayer (AudioStreamPlayer)
```

## Singleton Architecture (Autoload)

### GameManager
- **Purpose**: Global game state management
- **Responsibilities**:
  - Game state transitions (menu, playing, paused)
  - Player management and tracking
  - Floor progression logic
  - Save/load functionality

### Constants
- **Purpose**: Game-wide constants and enumerations
- **Contains**:
  - Player stats and movement values
  - Item types and damage types
  - UI constants and input mappings
  - D&D 5E stat system values

### NetworkManager (Future)
- **Purpose**: Multiplayer networking (currently stubbed)
- **Future Responsibilities**:
  - Host/client management
  - RPC synchronization
  - Player connection handling
  - Network state validation

## Data Management

### JSON-Based Configuration
- **Items**: `data/items/base_items.json`
- **Enemies**: `data/enemies/base_enemies.json`
- **Dungeons**: `data/dungeon_templates/basic_rooms.json`
- **Settings**: `data/config/default_settings.json`

### Resource-Based Systems
- **Custom Resources** for complex data structures
- **Scriptable Objects** for game content
- **Scene-based prefabs** for reusable components

## Physics and Interaction Systems

### Player Physics
```gdscript
# CharacterBody3D implementation
extends CharacterBody3D

var speed: float = 5.0
var jump_velocity: float = 12.0
var gravity: float = 25.0

func _physics_process(delta):
    handle_gravity(delta)
    handle_input()
    handle_movement()
    move_and_slide()
```

### Item Physics
```gdscript
# RigidBody3D with Sprite3D visual
extends RigidBody3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var item_data: Dictionary
var weight: float
```

### Interaction System
```gdscript
# Area3D-based detection
extends Area3D

signal interaction_available(object)
signal interaction_lost(object)

func _on_body_entered(body):
    if body.is_in_group("players"):
        interaction_available.emit(self)
```

## Rendering and Visual Systems

### Sprite Integration
- **Sprite3D nodes** for characters and items
- **Fixed rotation** or **angle-switching** based on camera
- **Consistent pixel density** across all sprites
- **Billboard rendering** for UI elements in 3D space

### Material System
```gdscript
# Shader for pixelated look
shader_type canvas_item;

uniform bool pixel_snap : hint_toggle = true;
uniform float pixel_size : hint_range(1.0, 8.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    if (pixel_snap) {
        uv = floor(uv * pixel_size) / pixel_size;
    }
    COLOR = texture(TEXTURE, uv);
}
```

### Level Geometry
- **BoxMesh primitives** for walls and floors
- **2D textures** applied to 3D geometry
- **Modular construction** from room templates
- **Collision shape** generation from layout data

## State Management Patterns

### Game State Machine
```gdscript
enum GameState {
    MENU,
    LOADING, 
    PLAYING,
    PAUSED,
    GAME_OVER
}

func change_state(new_state: GameState):
    match new_state:
        GameState.MENU:
            show_main_menu()
        GameState.LOADING:
            start_loading_sequence()
        GameState.PLAYING:
            begin_gameplay()
```

### Player State Management
```gdscript
extends CharacterBody3D
class_name Player

var stats: Dictionary = {
    "strength": 10,
    "dexterity": 10, 
    "constitution": 10,
    "intelligence": 10,
    "wisdom": 10,
    "charisma": 10
}

var inventory: Array[Dictionary] = []
var health: int = 100
var stamina: int = 100
var mana: int = 100
```

## Asset Pipeline

### Sprite Import Settings
```gdscript
# Import settings for sprites
filter = false  # Maintain pixel art look
mipmaps = false  # Prevent blurring
```

### Audio Asset Organization
- **3D Audio**: Position-based sound effects
- **2D Audio**: UI sounds and music
- **Audio Bus Structure**: Master > Music/SFX/Voice
- **Dynamic Range**: Normalized audio levels

## Performance Optimization

### Object Pooling
```gdscript
# Item spawning with pooling
class_name ItemPool extends Node

var item_pool: Array[RigidBody3D] = []
var pool_size: int = 100

func get_item() -> RigidBody3D:
    if item_pool.is_empty():
        return create_new_item()
    return item_pool.pop_back()

func return_item(item: RigidBody3D):
    item.reset()
    item_pool.push_back(item)
```

### Level Streaming
- **Room-based loading** for large dungeons
- **Asset preloading** for common items
- **Garbage collection** management
- **Memory profiling** tools integration

## Networking Architecture (Future)

### Client-Server Model
- **Host acts as server** for game logic
- **Clients send input** to server
- **Server validates** and broadcasts state
- **Lag compensation** for smooth gameplay

### Data Synchronization
```gdscript
# Multiplayer synchronization example
@rpc("any_peer", "call_local")
func sync_player_state(pos: Vector3, rot: Vector3, health: int):
    if not multiplayer.is_server():
        position = pos
        rotation = rot
        current_health = health
```

## Error Handling and Debugging

### Logging System
```gdscript
# Custom logging utility
class_name Logger extends RefCounted

enum LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR
}

static func log(message: String, level: LogLevel = LogLevel.INFO):
    var timestamp = Time.get_datetime_string_from_system()
    print("[", timestamp, "] [", LogLevel.keys()[level], "] ", message)
```

### Debug Tools
- **In-game console** for runtime commands
- **Performance overlay** showing FPS/memory
- **Network status** display for multiplayer
- **Debug draw** for collision shapes and AI paths

## Build and Deployment

### Export Settings
- **Windows executable** as primary target
- **Asset bundling** for distribution
- **Version management** in export names
- **Debug vs Release** configurations

### Continuous Integration
- **Automated testing** for core systems
- **Build verification** on commits
- **Asset validation** pipeline
- **Performance regression** detection
