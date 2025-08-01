# Turn-Based Extraction Roguelike - Game Concept Overview

## Core Concept
A turn-based extraction roguelike that combines the deep simulation and emergent storytelling of Caves of Qud with the atmospheric exploration of Moonring, wrapped in a high-stakes extraction mechanic inspired by Tarkov. Players are relic hunters in a post-apocalyptic world where reality has become unstable, venturing into dangerous zones to recover valuable artifacts while managing risk, resources, and the constant threat of losing everything.

## World Structure

### Two-Layer Design
The game employs a dual-layer world structure that creates distinct gameplay experiences:

**Overworld Layer:**
- Functions as the main travel and planning hub
- Features fixed towns and major landmarks for consistency and narrative anchoring
- Serves as safe zones for planning expeditions, trading, upgrading equipment, and character progression
- Provides macro-scale exploration and discovery
- Acts as the stable reference point for the player's journey

**Descent Layer:**
- Semi-procedural dungeons and areas accessed by "descending" from specific overworld locations
- Each overworld location generates different types of procedural content based on context
- This is where extraction mechanics become active and dangerous
- Areas shift and change between visits, maintaining replayability while preserving world coherence

### Location Context System
Different overworld locations generate contextually appropriate descent content:
- Military bases spawn tactical combat scenarios and weapon caches
- Research facilities feature anomalous experiments and scientific equipment
- Urban ruins provide scavenging opportunities and civilian artifacts
- Industrial zones offer mechanical components and hazardous environments

## Core Gameplay Loop

### Extraction Mechanics
The fundamental tension revolves around risk versus reward in a turn-based environment:

**Carrying Capacity System:**
- Weight-based inventory management where heavier items affect mobility and combat effectiveness
- Players must make tactical decisions about what to carry and what to leave behind
- Multiple trip strategy versus single high-risk haul creates meaningful choice
- Encumbrance affects stealth capabilities and movement speed

**Time Pressure in Turn-Based Context:**
- Environmental "heat" builds each turn, increasing danger over time
- Longer stays in descent areas attract more threats and complications
- Extraction windows create urgency without requiring real-time reflexes
- Risk escalation mechanics where areas become progressively more dangerous

**Strategic Depth:**
- Multiple potential exit points from descended areas
- Different extraction routes offer varying risk/reward profiles
- Environmental hazards and anomalies create tactical challenges
- Player actions create cascading effects through the simulation

## Character Progression System

### Multi-Path Progression
The character development system offers several interconnected but distinct advancement paths:

**Traditional Stats and Skills:**
- Core attributes affecting combat effectiveness and survival capabilities
- Skill specialization in various weapon types, survival techniques, and technical abilities
- Meaningful choices that affect gameplay style rather than just numerical improvements

**Comprehensive Perk System:**
- **Weapon Specializations:** Pistols, rifles, melee weapons, explosives, energy weapons
- **Combat Styles:** Stealth, berserker, tactical, defensive approaches
- **Survival Skills:** Scavenging efficiency, environmental resistance, movement optimization
- **Technical Proficiencies:** Hacking, mechanical repair, crafting, vehicle operation
- **Social Abilities:** Faction relations, information gathering, bartering
- **Anomaly Interaction:** Detection, navigation, artifact identification, mutation resistance

**Psyker Abilities:**
- Mental powers with inherent risks and instability
- Potential interference with technological augmentations
- Unique interaction possibilities with anomalous environments
- Social consequences with certain factions and NPCs

**Cybernetic Augmentations:**
- Technological enhancements providing utility and combat advantages
- Weight considerations affecting carrying capacity
- Social stigma creating faction relationship complications
- Potential conflicts with psyker development paths
- Maintenance requirements and vulnerability to certain damage types

### Progression Philosophy
The system emphasizes specialization over generalization, creating meaningfully different playstyles rather than simple power progression. Each path offers distinct gameplay experiences that affect how players approach exploration, combat, and social interactions.

## Procedural Generation Philosophy

### Hybrid Approach
The generation system balances procedural variety with handcrafted soul through several methodologies:

**Template-Based Generation:**
- Hand-designed room layouts, encounter scenarios, and story beats
- Procedural connection and modification systems
- Contextual placement based on overworld location and environmental factors

**Narrative Coherence:**
- Pre-written lore fragments and environmental storytelling elements
- Procedural placement that maintains world consistency and believability
- Historical layers that influence what content appears in each location

**Simulation-Driven Emergence:**
- Systemic interactions create organic narratives rather than scripted events
- Environmental cascades where player actions ripple through the simulation
- Faction presence and territorial control affecting procedural content

**Contextual Intelligence:**
- Overworld influence determining appropriate content types
- Weighted generation systems that respect world logic
- Constraint-based generation maintaining thematic consistency

### Technical Implementation
The procedural system prioritizes meaningful variety over random chaos, ensuring that each descent feels purposeful and connected to the larger world narrative while maintaining the replayability essential to the roguelike experience.

## Combat System Design

### Turn-Based Tactical Combat
The combat system emphasizes environmental awareness and tactical positioning over reflexes:

**Environmental Integration:**
- Anomalies and hazards as tactical elements
- Cover systems and line-of-sight mechanics
- Environmental destruction and manipulation
- Hazard management and exploitation

**Build Diversity:**
- Different character builds create distinct combat approaches
- Stealth specialists versus heavy weapons experts
- Psyker abilities offering unique tactical options
- Cybernetic enhancements providing combat advantages

**Resource Management:**
- Equipment degradation from environmental exposure
- Limited ammunition and supplies
- Medical resources and injury management
- Anomaly exposure and contamination tracking

## Technical Considerations

### Godot 4 Implementation
The concept leverages Godot 4's capabilities while considering the technical challenges of the design:

**World Management:**
- Efficient systems for managing overworld persistence
- Procedural generation that doesn't overwhelm system resources
- Save system handling complex character progression and world state

**Turn-Based Framework:**
- Robust turn management system
- AI systems for NPCs and environmental threats
- Performance optimization for complex simulations

**User Interface:**
- Inventory management systems handling weight and encumbrance
- Character progression interfaces for multiple advancement paths
- Information display for environmental hazards and anomalies

## Design Pillars

### Meaningful Choice
Every decision from character build to inventory management to exploration route should present meaningful tradeoffs with lasting consequences.

### Emergent Storytelling
The interaction of systems should create unique player narratives that feel personal and memorable rather than scripted.

### Tactical Depth
Combat and exploration should reward planning, preparation, and environmental awareness over rapid execution.

### Risk/Reward Balance
The extraction mechanic should create genuine tension where players must evaluate whether potential gains justify the risks involved.

### World Coherence
Despite procedural elements, the world should feel believable, consistent, and lived-in rather than randomly generated.

This comprehensive framework provides the foundation for a unique entry in the extraction roguelike genre, combining the best elements of its inspirations while creating new mechanical interactions and player experiences.