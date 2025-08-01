# Pivot-Based Weapon System Documentation

## Overview
The weapon system has been updated to use a natural pivot point for weapon swinging animations. Instead of rotating the weapon around its center (which looked like "fanning"), weapons now rotate from the hilt/grip point where the player would actually hold them.

## Technical Implementation

### Pivot System Architecture
1. **WeaponPivot Node**: A Node3D created at the grip/hilt position
2. **Weapon Positioning**: The actual weapon is offset from the pivot so the hilt aligns with the pivot point
3. **Animation Target**: Animations rotate the pivot node, not the weapon directly

### Key Functions Modified

#### `position_weapon_in_hand(weapon: Node)`
- Creates a "WeaponPivot" Node3D at the grip position
- Reparents the weapon under the pivot
- Positions weapon so hilt/grip is at pivot origin
- Different offsets for different weapon types (sword vs dagger)

#### `perform_swing_animation(duration: float)`
- Animates the pivot node instead of the weapon directly
- Uses pure rotation (no position changes) for natural arcing motion
- Weapon-specific swing patterns:
  - **Sword**: Overhead to diagonal slash (-60° to +40° on X-axis)
  - **Dagger**: Side to forward thrust (-30° to +15° with Y-axis component)

#### `detach_weapon_from_hold(weapon: Node)`
- Handles cleanup of pivot system when dropping weapons
- Properly removes weapon from pivot and cleans up pivot node
- Maintains world position/rotation during transition

### Weapon Positioning by Type

```gdscript
# Sword Configuration
pivot_node.position = Vector3(0.3, -0.2, -0.5)  # Grip in right hand
weapon.position = Vector3(0, 0, -0.8)            # Blade extends forward

# Dagger Configuration  
pivot_node.position = Vector3(0.2, -0.1, -0.3)  # Closer grip position
weapon.position = Vector3(0, 0, -0.4)            # Shorter blade extension
```

## Animation Improvements

### Natural Swing Motion
- **Windup Phase** (10%): Pull weapon back using TRANS_BACK easing
- **Swing Phase** (60%): Aggressive forward swing with TRANS_QUART
- **Recovery Phase** (30%): Return to rest with TRANS_BOUNCE

### Weapon-Specific Patterns
- **Sword**: Heavy overhead slash motion (larger rotation angles)
- **Dagger**: Quick side-to-forward thrust (smaller, faster motions)
- **Default**: Balanced swing for unknown weapon types

## Benefits of Pivot System

1. **Natural Motion**: Weapons swing in realistic arcs from grip point
2. **Proper Physics**: Matches how weapons actually move when held
3. **Visual Appeal**: No more "fan waving" - aggressive, impactful strikes
4. **Weapon Variety**: Different pivot positions create unique feel per weapon type
5. **Maintainable**: Clean separation between grip position and weapon mesh

## Integration with Combat System

- **Hitbox Positioning**: Still uses weapon_hold position for hit detection
- **Screen Shake**: Triggered on impact for tactile feedback
- **Weapon Info**: Uses existing weapon properties (attack_speed, damage, etc.)
- **State Management**: Proper cleanup when switching/dropping weapons

## Testing Notes

To test the pivot system:
1. Pick up a sword or dagger in the test scene
2. Perform attacks (left mouse button)
3. Observe natural swinging motion from the hilt
4. Compare different weapon types for unique swing patterns
5. Verify weapons can be dropped and picked up properly

The system maintains compatibility with all existing weapon properties while providing much more realistic combat animations.
