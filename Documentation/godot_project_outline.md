# Godot 4 Project Structure & Development Template

## Project Directory Structure

```
ExtractionRoguelike/
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   └── ambient/
│   ├── graphics/
│   │   ├── ui/
│   │   ├── sprites/
│   │   ├── tiles/
│   │   └── vfx/
│   └── data/
│       ├── items/
│       ├── locations/
│       └── templates/
├── scenes/
│   ├── main/
│   │   ├── Main.tscn
│   │   └── GameManager.tscn
│   ├── overworld/
│   │   ├── OverworldMap.tscn
│   │   ├── Town.tscn
│   │   └── DescentPoint.tscn
│   ├── descent/
│   │   ├── DescentArea.tscn
│   │   ├── Room.tscn
│   │   └── ExitPoint.tscn
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── InventoryUI.tscn
│   │   ├── CharacterSheet.tscn
│   │   └── HUD.tscn
│   ├── entities/
│   │   ├── Player.tscn
│   │   ├── NPCs/
│   │   └── Items/
│   └── combat/
│       ├── CombatManager.tscn
│       └── TurnQueue.tscn
├── scripts/
│   ├── core/
│   ├── managers/
│   ├── entities/
│   ├── ui/
│   └── systems/
└── autoloads/
    ├── GameManager.gd
    ├── SaveSystem.gd
    └── EventBus.gd
```

## Core System Architecture

### 1. Autoload Singletons (Global Systems)

**GameManager.gd**
```gdscript
extends Node

# Core game state management
var current_state: GameState
var player_data: PlayerData
var world_data: WorldData

enum GameState {
    MAIN_MENU,
    OVERWORLD,
    DESCENT,
    COMBAT,
    INVENTORY,
    CHARACTER_SHEET
}

signal state_changed(new_state: GameState)
signal player_stats_changed()
```

**SaveSystem.gd**
```gdscript
extends Node

# Handles all save/load operations
var save_file_path = "user://savegame.save"

func save_game():
    # Save player data, world state, progression
    pass

func load_game():
    # Load saved data
    pass
```

**EventBus.gd**
```gdscript
extends Node

# Global event communication system
signal item_picked_up(item: Item)
signal combat_started()
signal descent_entered(location: DescentLocation)
signal extraction_initiated()
signal player_damaged(damage: int)
```

### 2. Core System Classes

**Player Data System**
```gdscript
# scripts/core/PlayerData.gd
class_name PlayerData
extends Resource

@export var stats: CharacterStats
@export var inventory: Inventory
@export var skills: SkillTree
@export var cybernetics: Array[Cybernetic]
@export var psyker_abilities: Array[PsykerAbility]
@export var current_location: Vector2
@export var faction_standings: Dictionary
```

**World Management**
```gdscript
# scripts/core/WorldData.gd
class_name WorldData
extends Resource

@export var overworld_locations: Array[OverworldLocation]
@export var discovered_locations: Array[Vector2]
@export var town_states: Dictionary
@export var faction_relations: Dictionary
@export var world_events: Array[WorldEvent]
```

### 3. Component-Based Entity System

**Base Entity**
```gdscript
# scripts/entities/Entity.gd
class_name Entity
extends Node2D

@export var stats: CharacterStats
@export var inventory: Inventory
@export var faction: String

var components: Dictionary = {}

func add_component(component: Component):
    components[component.get_class()] = component
    add_child(component)
```

**Player Controller**
```gdscript
# scripts/entities/Player.gd
class_name Player
extends Entity

@export var movement_component: MovementComponent
@export var combat_component: CombatComponent
@export var interaction_component: InteractionComponent

signal turn_ended()
signal action_performed(action: String)
```

### 4. Procedural Generation Framework

**Location Generator**
```gdscript
# scripts/systems/LocationGenerator.gd
class_name LocationGenerator
extends Node

var templates: Dictionary = {}
var generation_rules: Dictionary = {}

func generate_descent_area(overworld_pos: Vector2, area_type: String) -> DescentArea:
    var template = templates.get(area_type)
    var rules = generation_rules.get(area_type)
    
    # Generate rooms, connections, populate with content
    var area = DescentArea.new()
    return area
```

**Template System**
```gdscript
# scripts/systems/TemplateSystem.gd
class_name TemplateSystem
extends Node

var room_templates: Array[RoomTemplate]
var encounter_templates: Array[EncounterTemplate]
var loot_tables: Dictionary

func get_weighted_template(area_type: String, difficulty: int) -> Template:
    # Return appropriate template based on context
    pass
```

### 5. Turn-Based Combat System

**Turn Manager**
```gdscript
# scripts/combat/TurnManager.gd
class_name TurnManager
extends Node

var turn_queue: Array[Entity] = []
var current_entity_index: int = 0
var combat_active: bool = false

signal turn_started(entity: Entity)
signal turn_ended(entity: Entity)
signal combat_ended()

func process_turn():
    var current_entity = turn_queue[current_entity_index]
    current_entity.take_turn()
```

**Action System**
```gdscript
# scripts/combat/ActionSystem.gd
class_name ActionSystem
extends Node

enum ActionType {
    MOVE,
    ATTACK,
    USE_ITEM,
    INTERACT,
    PSYKER_ABILITY,
    CYBERNETIC_FUNCTION
}

func execute_action(actor: Entity, action: Action):
    match action.type:
        ActionType.MOVE:
            process_movement(actor, action)
        ActionType.ATTACK:
            process_attack(actor, action)
        # etc.
```

### 6. UI System Architecture

**UI Manager**
```gdscript
# scripts/ui/UIManager.gd
class_name UIManager
extends CanvasLayer

@export var inventory_ui: InventoryUI
@export var character_sheet: CharacterSheet
@export var hud: HUD

var ui_stack: Array[Control] = []

func show_ui(ui_name: String):
    # Handle UI transitions and stacking
    pass
```

## Development Phases

### Phase 1: Core Foundation (Weeks 1-3)
- [ ] Set up project structure and autoloads
- [ ] Implement basic player movement and input
- [ ] Create overworld map navigation
- [ ] Basic UI framework
- [ ] Simple save/load system

### Phase 2: Turn-Based Combat (Weeks 4-6)
- [ ] Turn manager implementation
- [ ] Basic combat mechanics
- [ ] Action system
- [ ] Combat UI
- [ ] Simple AI for testing

### Phase 3: Character Systems (Weeks 7-9)
- [ ] Stats and skills system
- [ ] Inventory and weight management
- [ ] Basic perk system
- [ ] Equipment and items
- [ ] Character progression UI

### Phase 4: World Systems (Weeks 10-12)
- [ ] Overworld/descent transition
- [ ] Basic procedural generation
- [ ] Town and NPC systems
- [ ] Faction relationships
- [ ] World persistence

### Phase 5: Advanced Features (Weeks 13-16)
- [ ] Cybernetics system
- [ ] Psyker abilities
- [ ] Advanced procedural generation
- [ ] Extraction mechanics
- [ ] Environmental hazards

### Phase 6: Polish and Balance (Weeks 17-20)
- [ ] Audio implementation
- [ ] Visual effects
- [ ] Balance testing
- [ ] Bug fixes
- [ ] Performance optimization

## Key Godot 4 Features to Leverage

### Scene System
- Use scenes for modular design
- Scene instances for procedural content
- Scene switching for state management

### Resource System
- Custom resources for data management
- Resource preloading for performance
- Serialization for save systems

### Signal System
- Event-driven architecture
- Decoupled communication
- UI responsiveness

### Node Architecture
- Component-based design
- Autoloads for global systems
- Groups for entity management

## Testing Strategy

### Unit Tests
- Individual system testing
- Component isolation
- Data validation

### Integration Tests
- System interaction testing
- Save/load validation
- Performance benchmarking

### Playtesting
- Core loop validation
- Balance testing
- User experience evaluation

## Performance Considerations

### Memory Management
- Object pooling for frequently created objects
- Resource cleanup
- Efficient data structures

### Optimization
- Profiling tools usage
- Efficient algorithms
- Minimal redundant calculations

### Scalability
- Modular architecture
- Configurable systems
- Performance settings

This template provides a solid foundation for building your extraction roguelike in Godot 4, with clear separation of concerns and room for iterative development.