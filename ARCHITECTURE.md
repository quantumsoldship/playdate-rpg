# Architecture Overview

This document provides a visual overview of the game's architecture and data flow.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Main Loop                            │
│                       (main.lua)                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Game State Manager                                      │ │
│  │ - Exploration Mode                                      │ │
│  │ - Combat Mode                                           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Player  │    │   Map    │    │  Enemy   │
    │ (player) │    │  (map)   │    │ (enemy)  │
    └──────────┘    └──────────┘    └──────────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │   UI     │    │  Combat  │    │  Config  │
    │  (ui)    │    │ (combat) │    │ (config) │
    └──────────┘    └──────────┘    └──────────┘
                           │
                           ▼
                    ┌──────────┐
                    │   Item   │
                    │  (item)  │
                    └──────────┘
```

## Data Flow

### Exploration Mode

```
Player Input (D-Pad)
      │
      ▼
┌──────────────────┐
│  Main Loop       │
│  - Update Input  │
└──────────────────┘
      │
      ▼
┌──────────────────┐
│  tryMovePlayer() │
└──────────────────┘
      │
      ▼
┌──────────────────┐        ┌──────────────────┐
│  Map.isWalkable()│◄───────│  Check Collision │
└──────────────────┘        └──────────────────┘
      │
      ├─ Walkable? ──► Move Player ──► Check Enemy Collision
      │                                        │
      │                            ┌───────────┴──────────┐
      │                            │                      │
      └─ Not Walkable ──► Ignore  ▼                      ▼
                              Start Combat        Random Encounter?
                                   │                     (10%)
                                   ▼                      │
                              Combat Mode  ◄──────────────┘
```

### Combat Mode

```
Player Input (A/B Button)
      │
      ├─ A Button ──► Attack
      │                 │
      │                 ▼
      │          ┌──────────────────┐
      │          │ Combat.playerAttack()
      │          └──────────────────┘
      │                 │
      │                 ▼
      │          ┌──────────────────┐
      │          │ Calculate Damage │
      │          └──────────────────┘
      │                 │
      │          ┌──────┴──────┐
      │          │             │
      │          ▼             ▼
      │      Enemy Dead?   Enemy Alive
      │          │             │
      │          ▼             ▼
      │     Victory!    Enemy Attack
      │          │             │
      │          ▼             ▼
      │     Gain XP     Take Damage
      │          │             │
      │          └──────┬──────┘
      │                 │
      │                 ▼
      │          ┌──────────────────┐
      │          │  Check Player HP │
      │          └──────────────────┘
      │                 │
      │          ┌──────┴──────┐
      │          │             │
      │          ▼             ▼
      │      Player Dead   Continue Combat
      │          │
      │          ▼
      │      Game Over
      │
      └─ B Button ──► Run Away
                        │
                        ▼
                   ┌──────────────────┐
                   │  50% Success?    │
                   └──────────────────┘
                        │
                   ┌────┴────┐
                   │         │
                   ▼         ▼
              Escape!   Enemy Attack
```

## Class Relationships

```
Player
├── Stats
│   ├── HP (current/max)
│   ├── Level
│   ├── XP
│   ├── Attack
│   └── Defense
├── Position (x, y)
├── Inventory []
└── Equipment
    ├── Weapon
    └── Armor

Enemy
├── Stats
│   ├── HP (current/max)
│   ├── Level
│   ├── Attack
│   └── Defense
├── Position (x, y)
└── Rewards
    ├── XP
    └── Gold

Map
├── Dimensions (width, height)
├── Tiles [][]
└── Tile Types
    ├── Grass (walkable)
    ├── Water (blocked)
    ├── Tree (blocked)
    └── Rock (blocked)

Combat
├── Player (ref)
├── Enemy (ref)
├── Combat Log []
└── Rewards
    ├── XP
    └── Gold

UI
├── Player (ref)
└── Display Elements
    ├── HUD
    ├── Health Bar
    └── Stats Display

Item
├── Name
├── Type
├── Value
└── Effects
```

## Module Dependencies

```
main.lua
 ├─► player.lua
 ├─► map.lua
 ├─► enemy.lua
 ├─► combat.lua
 │    ├─► player.lua
 │    └─► enemy.lua
 ├─► ui.lua
 │    └─► player.lua
 └─► config.lua

item.lua (optional, for expansion)
```

## Game Loop Sequence

```
1. Initialize()
   ├─ Create Player
   ├─ Generate Map
   ├─ Create UI
   └─ Spawn Enemies

2. Update Loop (60fps)
   │
   ├─ Update Timers
   │
   ├─ State Check
   │   ├─ Exploration?
   │   │   ├─ Handle Input
   │   │   ├─ Move Player
   │   │   └─ Check Encounters
   │   │
   │   └─ Combat?
   │       ├─ Handle Combat Input
   │       ├─ Process Turn
   │       └─ Check Victory/Defeat
   │
   └─ Draw()
       ├─ Clear Screen
       ├─ Draw Map
       ├─ Draw Entities
       └─ Draw UI

3. Repeat Step 2
```

## State Transitions

```
                    ┌──────────────┐
                    │              │
         ┌──────────│ Exploration  │◄─────────┐
         │          │              │          │
         │          └──────────────┘          │
         │                 │                  │
         │  Walk into      │  Random          │
         │  Enemy          │  Encounter       │
         │                 │                  │
         │          ┌──────▼──────┐           │
         │          │             │           │
         └─────────►│   Combat    │───────────┘
                    │             │
                    └──────┬──────┘    Victory or
                           │           Escape
                           │
                    Player │
                    Dies   │
                           │
                    ┌──────▼──────┐
                    │             │
                    │  Game Over  │
                    │             │
                    └──────┬──────┘
                           │
                     Wait 2│sec
                           │
                    ┌──────▼──────┐
                    │             │
                    │  Restart    │──────► Initialize()
                    │             │
                    └─────────────┘
```

## Configuration System

```
config.lua
 ├─ Game Settings
 │   ├─ Screen Dimensions
 │   ├─ Map Size
 │   └─ Tile Size
 │
 ├─ Player Settings
 │   ├─ Starting Stats
 │   └─ Level Up Bonuses
 │
 ├─ Combat Settings
 │   ├─ Damage Variance
 │   └─ Escape Chance
 │
 ├─ Enemy Templates
 │   ├─ Slime
 │   ├─ Goblin
 │   ├─ Wolf
 │   ├─ Orc
 │   └─ Dragon
 │
 └─ Item Templates
     ├─ Potions
     ├─ Weapons
     └─ Armor
```

## Expansion Points

The architecture is designed with several expansion points:

1. **Player System**
   - Add magic/mana system
   - Implement skill trees
   - Add character classes

2. **Combat System**
   - Add special abilities
   - Implement items in combat
   - Add status effects

3. **Map System**
   - Multiple map types
   - Map transitions
   - Custom map loading

4. **Enemy System**
   - AI behaviors
   - Boss mechanics
   - Enemy abilities

5. **Item System**
   - Inventory UI
   - Equipment system
   - Crafting system

6. **New Systems**
   - NPC/Dialogue
   - Quest system
   - Shop system
   - Save/Load

Each expansion point has minimal dependencies on other systems, making it easy to add features independently.
