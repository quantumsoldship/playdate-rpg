# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-11-17

### Added
- Initial release of Basic RPG for Playdate
- Core game systems:
  - Player character with stats (HP, Attack, Defense, Level, XP)
  - Turn-based combat system
  - Tile-based map generation (20x20 grid)
  - Random enemy encounters (10% chance per move)
  - Enemy system with scalable stats
  - Leveling system with automatic stat increases
  - Visual HUD displaying player stats and position
- Exploration features:
  - D-pad movement controls
  - Four terrain types: Grass, Water, Trees, Rocks
  - Visible enemies on map
  - Collision detection
- Combat features:
  - Attack and Run options
  - Damage variance system (±20%)
  - Defense-based damage reduction
  - Combat log display
  - XP and gold rewards
  - Game over on defeat with auto-restart
- Architecture:
  - Modular class-based structure
  - Configuration file for easy customization
  - Template system for enemies and items
  - Equipment framework (weapons and armor)
  - Inventory system foundation
- Documentation:
  - Comprehensive Developer Guide
  - Practical expansion examples
  - Quick reference card
  - Detailed README
  - MIT License

### Technical Details
- Written in Lua for Playdate SDK
- Object-oriented architecture using Playdate's class system
- Modular file structure for easy expansion
- 8 core game modules
- 5 enemy templates included
- 3 item templates for future use

### For Developers
- Easy-to-expand enemy system via templates
- Configuration-based game parameters
- Example implementations for:
  - Magic systems
  - Quest tracking
  - Shop systems
  - NPC dialogues
  - Save/load functionality
  - Custom maps
  - Status effects

## Future Considerations

This is a foundation template. Users can expand with:
- Additional enemy types
- Item and equipment systems
- Multiple maps and dungeons
- NPC interactions and quests
- Magic and special abilities
- Save/load functionality
- Boss battles
- And much more!

---

**Note**: This is a starter template designed for easy expansion. See EXAMPLES.md for implementation ideas.
