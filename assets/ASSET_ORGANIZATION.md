# Asset Organization Guide

This document outlines the organized folder structure for all game assets in the Daggerfall Clone project.

## 📁 Directory Structure

```
assets/
├── 3d/                          # All 3D models and scenes
│   ├── monsters/                # Enemy creatures (✓ organized)
│   │   ├── Bat.fbx
│   │   ├── Slime.fbx
│   │   └── Skeleton_Minion.glb
│   ├── weapons/                 # Weapons and combat items (✓ organized)
│   │   ├── Sword.fbx
│   │   └── Dagger.fbx
│   ├── characters/              # Character models
│   │   ├── player/              # Player character models and animations
│   │   └── npcs/                # Non-player character models
│   ├── items/                   # Non-weapon items
│   │   ├── armor/               # Armor pieces (helmets, chest, etc.)
│   │   ├── consumables/         # Potions, food, scrolls
│   │   └── treasures/           # Coins, gems, quest items
│   ├── environment/             # Environmental objects
│   │   ├── furniture/           # Tables, chairs, beds, chests
│   │   ├── props/               # Decorative objects, barrels, crates
│   │   └── lighting/            # Torches, candles, magical lights
│   ├── effects/                 # Visual effects
│   │   ├── spells/              # Spell effect models
│   │   └── particles/           # Particle effect resources
│   ├── dungeon/                 # Dungeon architecture (existing)
│   ├── decorative/              # Decorative elements (existing)
│   └── objects/                 # General objects (existing)
│
├── audio/                       # All audio files
│   ├── music/                   # Background music and ambient tracks
│   └── sfx/                     # Sound effects
│       ├── combat/              # Weapon sounds, spell casting, hits
│       ├── ambient/             # Environmental sounds, dungeon ambience
│       └── ui/                  # Menu sounds, button clicks, notifications
│
├── textures/                    # 2D textures and images
│   ├── ui/                      # User interface graphics
│   ├── materials/               # Material textures (stone, wood, metal)
│   └── icons/                   # Item icons, spell icons, UI elements
│
└── data/                        # Game data files (existing)
    ├── config/
    ├── dungeon_templates/
    ├── enemies/
    └── items/
```

## 🎯 Usage Guidelines

### When Adding New Assets:

1. **3D Models**: Always place in the appropriate subfolder under `3d/`
   - Monsters → `3d/monsters/`
   - Weapons → `3d/weapons/`
   - Armor → `3d/items/armor/`
   - Environment props → `3d/environment/props/`

2. **Audio Files**: Organize by type and purpose
   - Combat sounds → `audio/sfx/combat/`
   - Background music → `audio/music/`
   - UI sounds → `audio/sfx/ui/`

3. **Textures**: Keep organized by usage
   - Item icons → `textures/icons/`
   - UI elements → `textures/ui/`
   - Material textures → `textures/materials/`

### Naming Conventions:

- Use **PascalCase** for 3D models: `FireballSpell.fbx`, `IronSword.glb`
- Use **snake_case** for audio: `sword_hit.ogg`, `dungeon_ambient.wav`
- Use **kebab-case** for textures: `health-potion-icon.png`, `stone-wall-texture.jpg`

### Benefits:

- ✅ Easy to find assets
- ✅ Prevents asset loss during git operations
- ✅ Clean project structure
- ✅ Scalable for future content
- ✅ Team-friendly organization

## 🧹 Cleanup Recommendations

Once you've moved essential assets to organized folders, consider removing:
- `Animated Monster Pack by @Quaternius/` (monsters moved to `3d/monsters/`)
- `KayKit_Skeletons_1.0_FREE/` (skeleton moved to `3d/monsters/`)
- `Ultimate RPG Items Pack - Aug 2019/` (weapons moved to `3d/weapons/`)

Keep only what you need for a clean, manageable project!
