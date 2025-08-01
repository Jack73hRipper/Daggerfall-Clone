# Daggerfall Clone

A multiplayer 3D dungeon crawler combining the best elements of classic g**Technical Implementation**

**Combat System Architecture**
- `PlayerController.gd`: Enhanced first-person controller with combat actions
- `BaseEnemy.gd`: Advanced enemy AI with state machine and animation mapping
- `BatEnemy.gd`: Specialized flying enemy with 3D movement and hover mechanics
- `Weapon.gd`: Base weapon class with timing and damage systems
- Area3D collision detection with proper layer masking
- Model-specific rotation offset system for natural enemy movement

**Enemy AI Behavior**
- State machine with IDLE, CHASE, ATTACK, and DEAD states
- Smart animation detection and mapping across different model types
- Physics-based movement with gravity for ground enemies
- 3D flight mechanics for flying enemies (bats)
- Player detection via Area3D collision with group management
- Smooth rotation system with lerp_angle for natural turning

**Atmospheric Rendering**
- `TorchFlicker.gd`: Dynamic torch lighting with flame effects
- GPU particle systems for realistic flame and smoke
- Wall-mounted torch placement in procedural dungeons
- Atmospheric lighting creating immersive dungeon environmentsl**: Procedural dungeons, exploration focus
- **Doom**: Responsive movement and combat feel  
- **Caves of Qud**: Creative character progression systems
- **Barony**: Physics-based interactions, cooperative multiplayer

## Current Development Status

### ✅ COMPLETED - Phase 1: Core Combat System (Week 1)

**Combat Mechanics**
- ✅ Left-click melee combat with weapon-specific timing
- ✅ Area3D hit detection system with proper collision layers
- ✅ Professional weapon models from Ultimate RPG Items Pack
- ✅ Textured Warrior Sword and Rogue Dagger with proper materials
- ✅ Player health system (100 HP) with damage feedback
- ✅ Death and respawn mechanics

**Enemy AI System**
- ✅ Complete enemy AI with BaseEnemy class and state machine
- ✅ Three enemy types: Skeleton Minion (15 HP), Slime (25 HP), Bat (10 HP)
- ✅ Advanced AI states: IDLE, CHASE, ATTACK, DEAD
- ✅ Smart animation mapping system for different model types
- ✅ Physics-based movement with gravity and 3D flight for bats
- ✅ Player detection areas with proper collision layer management
- ✅ Model-specific rotation offsets for natural forward movement
- ✅ Enemy spawning system integrated into dungeon generation

**Atmospheric Systems**
- ✅ Torch lighting system with flickering flame effects
- ✅ GPU particle systems for flame and smoke effects
- ✅ Wall-mounted torch placement in dungeon generation
- ✅ Dynamic lighting creating atmospheric dungeon ambiance

**Visual Character System**
- ✅ RPG character asset integration (Warrior, Rogue, Cleric models)
- ✅ Player character visual representation (Cleric model)
- ✅ Full animation system with proper looping
- ✅ Character model positioning and collision setup

**Core Systems**
- ✅ Enhanced first-person movement with sprint
- ✅ Procedural dungeon generation with 6-phase algorithm
- ✅ Physics-based item interactions
- ✅ Input system (WASD movement, Sprint, Interact, Attack)

### 🚧 IN PROGRESS - Phase 2: Character Progression System (Week 2)

**Stats & Progression Foundation**
- ✅ D&D 5E-inspired character stats (STR, DEX, CON, INT, WIS, CHA)
- ✅ Character stats resource system with modifiers and derived stats
- 🔄 Level progression and experience point tracking
- ✅ Health/Mana/Stamina system integration

**Equipment & Inventory System**
- ✅ Equipment manager with 10 slots (Main/Off Hand, Armor pieces, Accessories)
- ✅ 20-slot inventory system with item management
- 🔄 Equipment bonus calculation and stat integration
- 🔄 Item equipping/unequipping mechanics

**User Interface**
- ✅ Always-visible HUD with Health/Mana/Stamina bars
- ✅ Tabbed character menu (Stats/Equipment/Inventory)
- 🔄 Right-click context menus for item interactions
- 🔄 Clean, functional UI design with dungeon crawler aesthetic

**Integration Goals**
- [ ] Connect new stats system with existing combat mechanics
- [ ] Enhance weapon damage with STR/DEX modifiers
- [ ] Implement armor class calculation affecting combat
- [ ] Add character progression feedback and leveling rewards

### 📋 UPCOMING - Phase 3: System Integration & Polish

**Combat Enhancement**
- [ ] Fix ground snapping system for proper floor positioning  
- [ ] Add combat audio (sword swings, hits, enemy sounds)
- [ ] Implement visual combat effects (damage numbers, hit particles)
- [ ] Enhanced weapon variety with stat requirements and bonuses

**Advanced Features**
- [ ] Character creation and customization system
- [ ] Skill system implementation with practical applications
- [ ] Save/load character progression
- [ ] Multiplayer networking foundation
- [ ] Advanced dungeon generation with loot scaling

## Development Approach
- **Single-player first** - Build core mechanics before networking
- **Godot 4** engine with low-poly pixelated graphics
- **3D character models** with full animation systems
- **Physics-based** item interactions and combat

## Technical Implementation

**Combat System Architecture**
- `PlayerController.gd`: Enhanced first-person controller with combat actions
- `AnimatedTarget.gd`: Advanced enemy AI with state machine (idle/patrol/pursue/attack/circle)
- `Weapon.gd`: Base weapon class with timing and damage systems
- Area3D collision detection with proper layer masking
- Tween-based weapon swing animations

**Character Animation Pipeline**
- RPG Characters asset pack integration (Warrior.gltf, Rogue.gltf, Cleric.gltf)
- AnimationPlayer detection and management
- Animation looping for movement states
- State-based animation switching

**Enemy AI Behavior**
- Patrol system with randomized movement points
- Dynamic combat states with organic timing
- Player detection via Area3D collision spheres
- Ground-level movement with positioning systems

## Project Structure
```
├── scenes/          # Scene files (.tscn)
│   ├── enemies/     # Enemy character scenes
│   ├── items/       # Weapon and item scenes
│   ├── main/        # Main game scenes
│   ├── player/      # Player character scene
│   └── ui/          # User interface scenes
├── scripts/         # GDScript files
│   ├── autoload/    # Global managers
│   ├── enemies/     # Enemy AI scripts
│   ├── items/       # Item and weapon scripts
│   ├── player/      # Player controller and progression
│   │   └── progression/  # Stats, equipment, inventory
│   ├── ui/          # User interface scripts
│   └── world/       # Dungeon generation
├── assets/          # Art and audio assets
│   └── 3d/RPG Characters - Nov 2020/  # Character models
├── data/            # Game data and configuration
└── Documentation/   # Project documentation
```

## Getting Started
1. Clone this repository
2. Open `project.godot` in Godot 4
3. Run the main scene to test combat system
4. Check `Documentation/` for detailed design documents

---
*Built with Godot 4 | Solo Development Project*
