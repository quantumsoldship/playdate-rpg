# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.1.0] - 2024-11-20

### Added
- **Utility Module**: New `utils.lua` with 15+ helper functions
  - Coordinate conversion utilities (`tileToPixel`, `pixelToTile`)
  - Math helpers (`clamp`, `distance`, `lerp`, `percentage`)
  - Safe operations (`safeDivide`, `inRange`)
  - Table utilities (`deepCopy`, `shuffleTable`, `tableContains`)
- **Configuration Enhancements**: Added 15+ new config constants
  - Movement settings (PLAYER_SPEED, DIAGONAL_MOVEMENT_FACTOR)
  - Encounter settings (ENEMY_ENCOUNTER_DISTANCE, MIN_ENEMY_SPAWN_DISTANCE)
  - Dungeon generation settings (DUNGEON_ROOMS_PER_FLOOR, grid dimensions)
  - UI settings (HUD_HEIGHT, COMBAT_MAX_LOG_LINES)
- **Input Validation**: Added comprehensive validation across all modules
  - Damage and healing validation in Player and Enemy classes
  - XP gain validation with boundary checks
  - Nil checks for critical game objects

### Changed
- **Refactored Magic Numbers**: Extracted hardcoded values to config constants
  - Replaced all hardcoded `32` (tile size) with `config.TILE_SIZE`
  - Replaced all hardcoded `400/240` (screen dimensions) with config values
  - Unified movement speed and collision detection constants
- **Improved Error Handling**: Added error messages and warnings
  - Better error reporting in Combat initialization
  - Validation warnings in Player takeDamage/heal methods
  - Improved nil checking in main game loop
- **Code Organization**: Better separation of concerns
  - Created reusable utility functions for common operations
  - Unified coordinate conversion logic
  - Consistent percentage calculations using utils
- **Documentation**: Enhanced code comments and function documentation
  - Added parameter descriptions for public methods
  - Improved inline comments explaining logic
  - Better error messages for debugging

### Improved
- **Maintainability**: Easier to modify game parameters via config
- **Robustness**: Reduced crashes from invalid input or missing data
- **Code Quality**: More consistent coding patterns across modules
- **Developer Experience**: Clearer code with better error messages

### Technical Details
- All modules now import and use `config` and `utils`
- Coordinate conversion centralized in utility functions
- Health/XP percentage calculations use safe division
- Distance calculations use utility function

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
