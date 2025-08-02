# Torch System Testing Guide

## Overview
We've successfully implemented a pickupable torch system with lighting functionality! The torch integrates with your existing press-E pickup system and adds a new torch lighting mechanic.

## Asset Organization
- **Torch Assets**: Moved to `assets/3d/items/tools/`
  - `Torch_Metal.gltf` - The 3D torch model (ready for future integration)
  - `Table_Spoon.gltf` - Also organized into tools folder

## How to Test the Torch System

### 1. Starting the Game
- Run the test scene as usual
- Look for the console messages about item spawning
- You should see: `Spawned torch at (X, 0.5, Y)`

### 2. Finding the Torch
- The torch spawns near the starting room, opposite side from the sword
- Look for a brown cylindrical object (the torch handle)
- It should be on the ground at about the same position as the sword but on the left side

### 3. Picking Up the Torch
- **Press E** when near the torch (same as existing weapon pickup)
- You should see: `"Picked up: Metal Torch"`
- The torch will attach to your weapon hold position and **become visible in first-person view**
- **First-Person View**: The torch will appear on the right side of your screen, held upright and slightly forward
- **Positioning**: Unlike weapons that are held behind/below, the torch is positioned for visibility and lighting

### 4. Lighting/Extinguishing the Torch
- **Press L** to light or extinguish the torch when it's equipped
- **When lighting**: You'll see `"Torch lit!"` and a warm orange light will appear
- **When extinguishing**: You'll see `"Torch extinguished"` and the light disappears
- **If no fuel**: You'll see `"Cannot light torch - no fuel remaining"`

### 5. Torch Features
- **First-Person Visibility**: Torch is clearly visible in first-person view when equipped
- **Light Source**: Provides warm orange lighting (10 meter range)
- **Burn Time**: 5 minutes (300 seconds) of continuous lighting
- **Particles**: Flame particle effects when lit (orange/yellow particles)
- **Flickering**: Torch will flicker in the last 30 seconds before burning out
- **Fuel System**: Once burned out, torch cannot be relit (expandable for future refueling)
- **Proper Positioning**: Held upright and forward for maximum light visibility

## Controls Summary
- **E**: Pick up/drop items (existing system)
- **L**: Light/extinguish torch when equipped (new feature)
- **Left Click**: Attack with weapons (existing system)

## Technical Details
- **Item Type**: Extends BaseItem class for physics and pickup
- **Weight**: 2.0 units (heavier than dagger, lighter than sword)
- **Visual**: Simple brown cylinder representing torch handle
- **Lighting**: Dynamic OmniLight3D that turns on/off with torch state
- **Effects**: GPU particles for flame effect when lit

## Future Enhancements (Ready to Implement)
1. **3D Model Integration**: Replace cylinder with the actual Torch_Metal.gltf model
2. **Refueling System**: Add torch oil or fuel items to extend burn time
3. **Multiple Torch Types**: Different torches with varying burn times and brightness
4. **Environmental Interactions**: Torches extinguished by water, wind, etc.
5. **Light Detection**: Enemies could be attracted to or repelled by torch light

## Testing Checklist
- [ ] Torch spawns in game world
- [ ] Can pick up torch with E key
- [ ] **Torch is visible in first-person view when equipped**
- [ ] **Torch appears on right side of screen, held upright**
- [ ] L key lights the torch (orange light appears)
- [ ] L key extinguishes the torch (light disappears)
- [ ] Particle effects appear when torch is lit
- [ ] **Light illuminates the environment around the player**
- [ ] Torch burns out after 5 minutes of use
- [ ] Can drop torch with E key when equipped

The torch system is now fully functional and ready for in-game testing!
