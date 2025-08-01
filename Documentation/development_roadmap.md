# Extraction Roguelike - Development Roadmap

**Project Start Date:** July 16, 2025  
**Current Phase:** Phase 1 - Foundation & Core Systems  
**Last Updated:** July 16, 2025

## Overview

This roadmap tracks the development progress of our turn-based extraction roguelike game. The project is structured in 6 major phases, each building upon the previous to create a complete, polished game experience.

## Project Goals & Vision

- **Core Concept**: Turn-based extraction roguelike combining deep simulation with atmospheric exploration
- **Key Features**: Dual-layer world system, risk/reward extraction mechanics, multi-path character progression
- **Target Platforms**: PC (Windows, Linux, Mac) via Godot 4
- **Estimated Development Time**: 20-24 weeks

---

## Phase 1: Foundation & Core Systems ⏳ *CURRENT PHASE*
**Duration:** Weeks 1-3 (July 16 - August 6, 2025)  
**Goal:** Establish technical foundation and basic gameplay loop

### ✅ Completed Tasks
- [x] Project structure setup
- [x] Godot project configuration
- [x] Autoload singletons (GameManager, EventBus, SaveSystem)
- [x] Core data classes (PlayerData, WorldData, SettingsData)
- [x] Basic input mapping

### 🔄 In Progress Tasks
- [ ] Main scene setup
- [ ] Basic player entity creation
- [ ] Simple movement system
- [ ] Basic UI framework

### 📋 Remaining Tasks

#### Week 1 (July 16-22, 2025)
- [ ] **Player Entity System**
  - [ ] Create Player scene and script
  - [ ] Implement basic movement on grid
  - [ ] Add player stats visualization
  - [ ] Connect to input system

- [ ] **Scene Management**
  - [ ] Create Main.tscn scene
  - [ ] Implement scene transition system
  - [ ] Add basic camera follow
  - [ ] Create placeholder overworld scene

#### Week 2 (July 23-29, 2025)
- [ ] **Basic UI Framework**
  - [ ] Create HUD scene
  - [ ] Implement basic inventory UI
  - [ ] Add character sheet UI skeleton
  - [ ] Create main menu scene

- [ ] **Core Systems Integration**
  - [ ] Connect player movement to world data
  - [ ] Implement basic save/load functionality
  - [ ] Add settings menu
  - [ ] Test core system interactions

#### Week 3 (July 30 - August 5, 2025)
- [ ] **World Foundation**
  - [ ] Create overworld map structure
  - [ ] Implement location discovery system
  - [ ] Add descent point creation
  - [ ] Basic overworld navigation

- [ ] **Testing & Polish**
  - [ ] Unit tests for core systems
  - [ ] Debug menu implementation
  - [ ] Performance profiling setup
  - [ ] Documentation update

### Success Criteria
- [ ] Player can move around overworld
- [ ] Basic UI elements are functional
- [ ] Save/load system works
- [ ] No critical bugs in core systems

---

## Phase 2: Turn-Based Combat & Core Loop
**Duration:** Weeks 4-6 (August 6-26, 2025)  
**Goal:** Implement fundamental gameplay mechanics

### 📋 Planned Tasks

#### Week 4: Combat System Foundation
- [ ] **Turn Manager**
  - [ ] Create TurnManager singleton
  - [ ] Implement turn queue system
  - [ ] Add action point system
  - [ ] Create turn UI indicators

- [ ] **Action System**
  - [ ] Define action types and costs
  - [ ] Implement move actions
  - [ ] Add basic attack actions
  - [ ] Create action validation

#### Week 5: Combat Implementation
- [ ] **Combat Mechanics**
  - [ ] Damage calculation system
  - [ ] Hit chance and critical hits
  - [ ] Status effect system
  - [ ] Combat animation framework

- [ ] **AI Foundation**
  - [ ] Basic enemy AI for testing
  - [ ] AI decision making system
  - [ ] Pathfinding implementation
  - [ ] AI behavior trees

#### Week 6: Extraction Mechanics
- [ ] **Core Extraction Loop**
  - [ ] Weight/encumbrance system
  - [ ] Exit point mechanics
  - [ ] Time pressure implementation
  - [ ] Risk escalation system

- [ ] **Descent Areas**
  - [ ] Basic descent area generation
  - [ ] Room connection system
  - [ ] Loot placement mechanics
  - [ ] Environmental hazards

### Success Criteria
- [ ] Complete gameplay loop: overworld → descent → combat → extraction
- [ ] Turn-based combat feels responsive and strategic
- [ ] Extraction mechanics create meaningful tension
- [ ] Basic AI provides adequate challenge

---

## Phase 3: Character Progression
**Duration:** Weeks 7-9 (August 27 - September 16, 2025)  
**Goal:** Add depth and replayability through character development

### 📋 Planned Tasks

#### Week 7: Stats & Skills
- [ ] **Attribute System**
  - [ ] Implement primary attributes
  - [ ] Calculate derived statistics
  - [ ] Add attribute point allocation
  - [ ] Create attribute UI

- [ ] **Skill Trees**
  - [ ] Design skill tree structure
  - [ ] Implement skill unlocking
  - [ ] Add skill effects to gameplay
  - [ ] Create skill tree UI

#### Week 8: Equipment & Items
- [ ] **Item System**
  - [ ] Create item database
  - [ ] Implement item properties
  - [ ] Add item generation system
  - [ ] Create item inspection UI

- [ ] **Equipment System**
  - [ ] Equipment slots and restrictions
  - [ ] Equipment effects on stats
  - [ ] Durability and maintenance
  - [ ] Visual equipment representation

#### Week 9: Progression Integration
- [ ] **Experience System**
  - [ ] Experience gain mechanics
  - [ ] Level up rewards
  - [ ] Progression pacing
  - [ ] Achievement system

- [ ] **Character Builds**
  - [ ] Validate different build paths
  - [ ] Balance testing
  - [ ] Build variety showcase
  - [ ] Save/load character builds

### Success Criteria
- [ ] Character progression feels meaningful
- [ ] Multiple viable build paths exist
- [ ] Equipment meaningfully affects gameplay
- [ ] Progression encourages replayability

---

## Phase 4: Procedural Generation
**Duration:** Weeks 10-12 (September 17 - October 7, 2025)  
**Goal:** Create dynamic, replayable content

### 📋 Planned Tasks

#### Week 10: Template System
- [ ] **Room Templates**
  - [ ] Create room template format
  - [ ] Design template library
  - [ ] Implement template loading
  - [ ] Add template variations

- [ ] **Encounter Templates**
  - [ ] Combat encounter design
  - [ ] Environmental challenges
  - [ ] Loot distribution templates
  - [ ] Event trigger templates

#### Week 11: Generation Rules
- [ ] **Context-Based Generation**
  - [ ] Overworld influence system
  - [ ] Biome-specific content
  - [ ] Faction territory effects
  - [ ] Historical influence layers

- [ ] **Difficulty Scaling**
  - [ ] Dynamic difficulty adjustment
  - [ ] Player progress influence
  - [ ] Risk/reward balance
  - [ ] Challenge rating system

#### Week 12: System Integration
- [ ] **Generation Pipeline**
  - [ ] Combine templates and rules
  - [ ] Validate generated content
  - [ ] Performance optimization
  - [ ] Content variety metrics

- [ ] **Quality Assurance**
  - [ ] Playtest generated content
  - [ ] Fix generation issues
  - [ ] Balance content distribution
  - [ ] Add generation debugging tools

### Success Criteria
- [ ] Each descent feels unique but contextually appropriate
- [ ] Generation system performs well
- [ ] Content variety meets design goals
- [ ] No broken or impossible scenarios

---

## Phase 5: Advanced Systems
**Duration:** Weeks 13-16 (October 8 - November 4, 2025)  
**Goal:** Add unique selling points and depth

### 📋 Planned Tasks

#### Week 13: Cybernetics System
- [ ] **Augmentation Mechanics**
  - [ ] Cybernetic capacity system
  - [ ] Installation process
  - [ ] Augmentation effects
  - [ ] Social consequences

- [ ] **Cybernetic Types**
  - [ ] Combat augmentations
  - [ ] Utility enhancements
  - [ ] Sensory improvements
  - [ ] Processing upgrades

#### Week 14: Psyker System
- [ ] **Psyker Abilities**
  - [ ] Ability power system
  - [ ] Risk and instability
  - [ ] Ability progression
  - [ ] Environmental interactions

- [ ] **Psyker Integration**
  - [ ] Faction relationships
  - [ ] Equipment conflicts
  - [ ] Narrative implications
  - [ ] Balance considerations

#### Week 15: Faction & Social Systems
- [ ] **NPC Interactions**
  - [ ] Dialogue system
  - [ ] Reputation mechanics
  - [ ] Trade negotiations
  - [ ] Information gathering

- [ ] **Faction Dynamics**
  - [ ] Territory control
  - [ ] Faction conflicts
  - [ ] Player allegiances
  - [ ] Dynamic events

#### Week 16: System Polish
- [ ] **Integration Testing**
  - [ ] Cross-system interactions
  - [ ] Balance validation
  - [ ] Performance optimization
  - [ ] Bug fixing

- [ ] **Content Expansion**
  - [ ] Additional abilities
  - [ ] More faction content
  - [ ] Extended dialogue
  - [ ] Extra encounters

### Success Criteria
- [ ] Cybernetics and psyker systems feel distinct and meaningful
- [ ] Faction relationships create interesting choices
- [ ] Advanced systems integrate well with core gameplay
- [ ] No major balance issues

---

## Phase 6: Polish & Content
**Duration:** Weeks 17-20 (November 5 - December 2, 2025)  
**Goal:** Make the game feel complete and polished

### 📋 Planned Tasks

#### Week 17: Audio Implementation
- [ ] **Sound Effects**
  - [ ] Combat sounds
  - [ ] UI feedback
  - [ ] Environmental audio
  - [ ] Footsteps and movement

- [ ] **Music System**
  - [ ] Background music
  - [ ] Dynamic music triggers
  - [ ] Audio mixing
  - [ ] Music transitions

#### Week 18: Visual Polish
- [ ] **Visual Effects**
  - [ ] Combat effects
  - [ ] Environmental particles
  - [ ] UI animations
  - [ ] Screen transitions

- [ ] **Art Integration**
  - [ ] Character sprites
  - [ ] Environment tiles
  - [ ] Item icons
  - [ ] UI graphics

#### Week 19: Balance & Testing
- [ ] **Gameplay Balance**
  - [ ] Difficulty tuning
  - [ ] Progression pacing
  - [ ] Economy balance
  - [ ] Risk/reward adjustment

- [ ] **Quality Assurance**
  - [ ] Extensive playtesting
  - [ ] Bug fixing
  - [ ] Performance optimization
  - [ ] Accessibility testing

#### Week 20: Final Polish
- [ ] **Content Finalization**
  - [ ] Complete all placeholder content
  - [ ] Final balance pass
  - [ ] Achievement implementation
  - [ ] Tutorial creation

- [ ] **Release Preparation**
  - [ ] Build optimization
  - [ ] Platform testing
  - [ ] Documentation completion
  - [ ] Release candidate creation

### Success Criteria
- [ ] Game feels polished and complete
- [ ] No major bugs or performance issues
- [ ] Content is engaging and balanced
- [ ] Ready for public release

---

## Development Guidelines

### Daily Practices
- [ ] Commit code daily with meaningful messages
- [ ] Update roadmap progress weekly
- [ ] Playtest changes before committing
- [ ] Document major design decisions

### Weekly Reviews
- [ ] Assess progress against roadmap
- [ ] Identify blockers and risks
- [ ] Adjust timeline if necessary
- [ ] Plan next week's priorities

### Quality Standards
- [ ] No functionality without proper error handling
- [ ] All systems must have basic unit tests
- [ ] Performance profiling before optimization
- [ ] User experience validation for all features

---

## Risk Assessment & Mitigation

### High Risk Items
1. **Procedural Generation Complexity**
   - *Risk*: System becomes too complex to maintain
   - *Mitigation*: Start simple, iterate gradually, maintain clear documentation

2. **Save System with Complex Data**
   - *Risk*: Save corruption or version incompatibility
   - *Mitigation*: Version all save formats, implement backup systems, test thoroughly

3. **Turn-Based AI Performance**
   - *Risk*: AI calculations slow down gameplay
   - *Mitigation*: Profile early, optimize algorithms, implement time limits

### Medium Risk Items
1. **Feature Scope Creep**
   - *Mitigation*: Stick to roadmap, defer nice-to-have features to post-launch

2. **Art Asset Pipeline**
   - *Mitigation*: Use placeholder art, establish clear asset requirements early

---

## Post-Launch Roadmap (Tentative)

### Version 1.1 - Content Expansion
- Additional character progression paths
- New faction content
- Extended world areas

### Version 1.2 - Quality of Life
- Advanced UI improvements
- Accessibility features
- Modding support

### Version 2.0 - Major Feature Addition
- Multiplayer extraction mode
- New game+ features
- Campaign mode

---

## Contact & Updates

**Lead Developer:** [Your Name]  
**Repository:** [Project Repository URL]  
**Progress Tracking:** This document (updated weekly)

**Next Review Date:** July 23, 2025  
**Next Milestone:** Complete Phase 1 by August 6, 2025
