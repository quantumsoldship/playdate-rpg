# What's New in Playdate RPG

## Major Features Added

### 1. Procedural Dungeon Generation (Enter the Gungeon Style)
- **Room-based dungeons** with 6 rooms per floor
- **Multiple room sizes** - small, medium, and large rooms
- **Smart room placement** using grid-based layout
- **Door connections** between adjacent rooms
- **Special room types**: Start room, exit room, and normal rooms
- **Floor progression** - advance through increasingly difficult floors

### 2. Room Locking System
- **Defeat all enemies to unlock doors** - core gameplay mechanic
- **Visual locked door indicators** - lock icons appear on locked doors
- **Clear feedback** - "Room cleared! Doors unlocked!" message
- **Strategic gameplay** - must clear rooms to progress

### 3. Custom Tile System
- **Upload custom tile images** (32x32 PNG)
- **Define tile properties** via JSON configuration
- **Configurable hitboxes** - precise collision control
- **Tile categories** - organize tiles by type
- **Fallback to programmatic drawing** if no image provided
- **Example tilesets included** for reference

### 4. Custom Enemy Sprites
- **Upload your own enemy images** (32x32 PNG)
- **Sprite key system** - associate sprites with enemy types
- **Automatic sprite loading** from JSON config
- **Health bars on enemies** - visual HP indicators
- **Graceful fallback** - default triangle if sprite not found

### 5. Enhanced UI
- **Visual HP bar** - graphical health display
- **Visual XP bar** - progress to next level
- **Floor indicator** - shows current dungeon floor
- **Polished design** - shadows, borders, and better layout
- **Combat UI improvements** - enhanced character sprites and layouts

### 6. Polish & Feel
- **Improved player sprite** - face with eyes and smile
- **Better enemy design** - enhanced default sprites
- **Lock indicators** - visual feedback for locked doors
- **Goal prompts** - clear indication when near exits
- **Debug mode** - toggle with SELECT button

## How It Works

### Dungeon Flow
1. **Start** in the first room of a new floor
2. **Encounter enemies** in each room
3. **Defeat all enemies** to unlock doors
4. **Move to adjacent rooms** through unlocked doors
5. **Find the exit room** and defeat all enemies
6. **Enter the goal** to advance to the next floor

### Room Layout
```
Grid-based placement:
[Empty] [Room ] [Empty]
[Room ] [Start] [Room ]
[Empty] [Exit ] [Empty]
```

Rooms are connected by doors in all four cardinal directions.

### Customization
- Place `data/tileset.json` to load custom tiles
- Place `data/enemy_sprites.json` to load custom enemy sprites
- Place `data/map.json` to load custom room layouts (advanced)

## Files Changed/Added

### New Files
- `source/dungeon.lua` - Procedural dungeon generator
- `source/tileset.lua` - Tile management system
- `TILE_SYSTEM.md` - Complete tile system guide
- `TILE_QUICKSTART.md` - Quick start guide for tiles
- `ENEMY_SPRITES.md` - Enemy sprite system guide
- `data/tileset_example.json` - Example tileset
- `data/map_example.json` - Example custom map
- `data/enemy_sprites_example.json` - Example enemy sprites

### Modified Files
- `source/main.lua` - Dungeon integration, room locking
- `source/map.lua` - Tileset integration
- `source/enemy.lua` - Sprite support, health bars
- `source/player.lua` - Improved sprite
- `source/ui.lua` - Visual HP/XP bars
- `source/combat.lua` - Enhanced combat UI
- `README.md` - Updated documentation

## Technical Details

### Dungeon Generation Algorithm
1. Initialize 5x5 grid for room placement
2. Place starting room at center
3. Use random walk to place additional rooms
4. Connect adjacent rooms with doors
5. Mark one room as exit (furthest from start)
6. Generate room layouts with walls and obstacles

### Room Structure
```lua
{
    gridX, gridY = position in dungeon grid
    width, height = room dimensions in tiles
    type = "start", "exit", or "normal"
    tiles = 2D array of tile IDs
    doors = list of connections to other rooms
    cleared = whether enemies defeated
}
```

### Tile System
- **Tile IDs 0-5**: Built-in tiles (grass, water, tree, rock, wall, goal)
- **Tile ID 9**: Door tile (for room transitions)
- **Custom tiles**: Start from ID 6+
- **Properties**: walkable, hitbox, category, image path

### Enemy Sprite System
- Sprites stored in `Enemy.sprites` static registry
- Associated with enemies via `spriteKey`
- Loaded automatically at game startup
- Fallback to default triangle shape

## Gameplay Changes

### Before
- Single large map
- Random enemy encounters while walking
- Find goal to advance to next room

### After
- Room-based dungeons with multiple connected rooms
- Enemies placed in rooms at start
- Must defeat all enemies to unlock doors
- Navigate through rooms to find exit
- Advance to next floor for harder challenges

## Balance Changes
- Enemy count scales with floor number
- Larger rooms have more enemies
- Exit rooms have the most enemies (boss room concept)
- Player heals 10 HP when advancing floors

## Future Expansion Ideas
- Boss enemies in exit rooms
- Room types (treasure, shop, puzzle)
- Minimap showing dungeon layout
- Special abilities and power-ups
- More enemy variety with different behaviors
- Animated sprites
- Sound effects and music

## Known Limitations
- Static sprites (no animation yet)
- Limited to 5x5 dungeon grid
- Doors only in cardinal directions
- No diagonal movement

## Developer Notes
- All new features maintain backward compatibility
- Modular design allows easy feature addition
- JSON-based configuration for non-programmers
- Extensive documentation for customization

---

*This game went from a basic RPG to a full-featured dungeon crawler with custom content support!*
