# API Reference

Complete reference for the Playdate RPG codebase modules and APIs.

## Table of Contents

1. [Configuration](#configuration)
2. [Utilities](#utilities)
3. [Player](#player)
4. [Enemy](#enemy)
5. [Combat](#combat)
6. [Map](#map)
7. [Tileset](#tileset)
8. [Dungeon Generator](#dungeon-generator)
9. [UI](#ui)

---

## Configuration

Module: `config.lua`

Central configuration file containing all game parameters.

### Screen Settings
```lua
config.SCREEN_WIDTH = 400
config.SCREEN_HEIGHT = 240
```

### Tile Settings
```lua
config.TILE_SIZE = 32
config.MAP_WIDTH = 12
config.MAP_HEIGHT = 10
```

### Player Settings
```lua
config.PLAYER_START_HP = 20
config.PLAYER_START_ATTACK = 5
config.PLAYER_START_DEFENSE = 2
config.PLAYER_SPEED = 2
config.PLAYER_SIZE = 16
```

### Movement Settings
```lua
config.DIAGONAL_MOVEMENT_FACTOR = 0.707
```

### Combat Settings
```lua
config.MIN_DAMAGE = 1
config.DAMAGE_VARIANCE = 0.2
config.ESCAPE_CHANCE = 50
config.COMBAT_MAX_LOG_LINES = 8
```

### Encounter Settings
```lua
config.ENEMY_ENCOUNTER_DISTANCE = 20
config.MIN_ENEMY_SPAWN_DISTANCE = 96
config.ENEMY_SPAWN_ATTEMPTS = 50
```

### Dungeon Settings
```lua
config.DUNGEON_ROOMS_PER_FLOOR = 6
config.DUNGEON_GRID_WIDTH = 5
config.DUNGEON_GRID_HEIGHT = 5
config.MAX_ROOM_PLACEMENT_ATTEMPTS = 60
```

---

## Utilities

Module: `utils.lua`

Collection of helper functions for common operations.

### Math Utilities

#### `utils.clamp(value, min, max)`
Constrains a value between min and max.
- **Parameters**: `value` (number), `min` (number), `max` (number)
- **Returns**: Clamped value

#### `utils.distance(x1, y1, x2, y2)`
Calculates Euclidean distance between two points.
- **Parameters**: Coordinates of two points
- **Returns**: Distance as number

#### `utils.lerp(a, b, t)`
Linear interpolation between a and b.
- **Parameters**: `a` (number), `b` (number), `t` (number 0-1)
- **Returns**: Interpolated value

#### `utils.round(num, decimals)`
Rounds number to specified decimal places.
- **Parameters**: `num` (number), `decimals` (number, default 0)
- **Returns**: Rounded value

### Range Utilities

#### `utils.inRange(value, min, max)`
Checks if value is within range (inclusive).
- **Parameters**: `value`, `min`, `max`
- **Returns**: boolean

### Conversion Utilities

#### `utils.tileToPixel(tileX, tileY, tileSize)`
Converts tile coordinates to pixel coordinates (centered).
- **Parameters**: Tile coordinates and size
- **Returns**: `pixelX, pixelY`

#### `utils.pixelToTile(pixelX, pixelY, tileSize)`
Converts pixel coordinates to tile coordinates.
- **Parameters**: Pixel coordinates and tile size
- **Returns**: `tileX, tileY`

### Safety Utilities

#### `utils.safeDivide(numerator, denominator)`
Safe division that returns 0 if denominator is 0.
- **Parameters**: `numerator`, `denominator`
- **Returns**: Result or 0

#### `utils.percentage(current, max)`
Calculate percentage safely.
- **Parameters**: `current`, `max`
- **Returns**: Percentage (0.0 to 1.0)

### Table Utilities

#### `utils.tableContains(table, value)`
Checks if table contains value.
- **Parameters**: `table`, `value`
- **Returns**: boolean

#### `utils.shuffleTable(tbl)`
Shuffles table in place (Fisher-Yates).
- **Parameters**: `tbl` (table)
- **Returns**: Shuffled table

#### `utils.deepCopy(original)`
Creates deep copy of a table.
- **Parameters**: `original` (table or value)
- **Returns**: Copy

---

## Player

Module: `player.lua`

Manages player character state, stats, and behavior.

### Constructor

#### `Player()`
Creates new player with default stats from config.

### Properties

```lua
player.pixelX, player.pixelY  -- Pixel position
player.x, player.y             -- Tile position
player.level                   -- Character level
player.xp                      -- Current XP
player.xpToNextLevel           -- XP required for next level
player.currentHP, player.maxHP -- Health points
player.attack                  -- Attack stat
player.defense                 -- Defense stat
player.speed                   -- Movement speed
player.size                    -- Collision size
player.inventory               -- Item array
player.gold                    -- Gold amount
player.weapon, player.armor    -- Equipment
```

### Methods

#### `player:setPosition(x, y)`
Sets player position in pixels.

#### `player:setTilePosition(tileX, tileY)`
Sets player position by tile coordinates.

#### `player:movePixels(dx, dy)`
Moves player by pixel delta.

#### `player:takeDamage(damage)`
Applies damage (after defense).
- **Returns**: Actual damage dealt

#### `player:heal(amount)`
Heals player (capped at maxHP).

#### `player:isAlive()`
- **Returns**: boolean

#### `player:gainXP(amount)`
Adds XP and checks for level up.

#### `player:levelUp()`
Increases level and stats.

#### `player:getAttackPower()`
- **Returns**: Attack damage with variance and weapon bonus

#### `player:addItem(item)`
Adds item to inventory.

#### `player:equipWeapon(weapon)`
Equips weapon.

#### `player:equipArmor(armor)`
Equips armor and updates defense.

#### `player:draw()`
Draws player at screen center with health bar.

---

## Enemy

Module: `enemy.lua`

Manages enemy state, stats, and sprites.

### Static Properties

```lua
Enemy.sprites  -- Registry of loaded sprites {spriteKey -> image}
```

### Constructor

#### `Enemy(name, level, spriteKey)`
Creates enemy with scaled stats.
- **Parameters**: 
  - `name` (string)
  - `level` (number, min 1)
  - `spriteKey` (string, optional)

### Properties

Similar to Player:
```lua
enemy.name
enemy.level
enemy.pixelX, enemy.pixelY
enemy.currentHP, enemy.maxHP
enemy.attack, enemy.defense
enemy.xpReward, enemy.goldReward
enemy.spriteKey
```

### Methods

#### `Enemy.loadSprite(spriteKey, imagePath)` (static)
Loads and registers enemy sprite.
- **Returns**: boolean success

#### `Enemy.loadSpritesFromJSON(jsonPath)` (static)
Loads multiple sprites from JSON config.

#### `enemy:setPosition(x, y)`
Sets enemy position by tile coordinates.

#### `enemy:takeDamage(damage)`
Applies damage (after defense).
- **Returns**: Actual damage dealt

#### `enemy:isAlive()`
- **Returns**: boolean

#### `enemy:getAttackPower()`
- **Returns**: Attack damage with variance

#### `enemy:draw(playerPixelX, playerPixelY, tileSize)`
Draws enemy relative to player with health bar.

#### `Enemy.fromTemplate(template)` (static)
Creates enemy from template object.
- **Returns**: Enemy instance

---

## Combat

Module: `combat.lua`

Manages turn-based combat encounters.

### Constructor

#### `Combat(player, enemy)`
Initializes combat system.
- **Throws**: Error if player or enemy is nil

### Properties

```lua
combat.player         -- Player reference
combat.enemy          -- Enemy reference
combat.log            -- Combat log array
combat.maxLogLines    -- Max log entries
combat.rewardXP       -- XP reward
combat.rewardGold     -- Gold reward
```

### Methods

#### `combat:addLog(message)`
Adds message to combat log.

#### `combat:playerAttack()`
Player attacks enemy.
- **Returns**: "victory" or "continue"

#### `combat:enemyAttack()`
Enemy attacks player.
- **Returns**: "defeat" or "continue"

#### `combat:draw()`
Renders combat screen with stats and log.

#### `combat:drawHealthBar(x, y, width, current, max)`
Draws health bar at position.

---

## Map

Module: `map.lua`

Manages tile-based maps and rendering.

### Constructor

#### `Map(tileset)`
Creates map with given tileset.

### Properties

```lua
map.width, map.height  -- Map dimensions in tiles
map.tiles              -- 2D array of tile IDs
map.tileset            -- Tileset reference
map.tileSize           -- Tile size in pixels
map.goalX, map.goalY   -- Goal position
```

### Tile Constants

```lua
map.TILE_GRASS = 0
map.TILE_WATER = 1
map.TILE_TREE = 2
map.TILE_ROCK = 3
map.TILE_WALL = 4
map.TILE_GOAL = 5
```

### Methods

#### `map:generate(width, height)`
Generates random map with room boundaries.

#### `map:loadFromJSON(jsonPath)`
Loads map from JSON file.
- **Returns**: boolean success

#### `map:exportToJSON(jsonPath)`
Exports map to JSON file.
- **Returns**: boolean success

#### `map:isWalkable(x, y)`
Checks if tile is walkable.
- **Returns**: boolean

#### `map:getTile(x, y)`
Gets tile ID at position.
- **Returns**: Tile ID or nil

#### `map:setTile(x, y, tileType)`
Sets tile at position.

#### `map:draw(playerPixelX, playerPixelY)`
Draws visible portion of map centered on player.

#### `map:drawTile(tileType, x, y)`
Draws single tile at screen position.

---

## Tileset

Module: `tileset.lua`

Manages tile definitions and rendering.

### Constructor

#### `Tileset()`
Creates empty tileset.

### Properties

```lua
tileset.tiles     -- Tile definitions {id -> tile}
tileset.tileSize  -- Tile size from config
tileset.images    -- Loaded images {id -> image}
```

### Tile Definition Structure

```lua
{
    id = number,
    name = string,
    walkable = boolean,
    image = Image or nil,
    hitbox = {x, y, width, height},
    drawFunc = function(x, y, size),
    category = string
}
```

### Methods

#### `tileset:defineTile(id, properties)`
Defines a tile with properties.

#### `tileset:loadTileImage(id, imagePath)`
Loads image for tile.
- **Returns**: boolean success

#### `tileset:getTile(id)`
Gets tile definition.
- **Returns**: Tile object or nil

#### `tileset:isWalkable(id)`
- **Returns**: boolean

#### `tileset:drawTile(id, x, y)`
Draws tile at screen position.

#### `tileset:createDefaultTileset()`
Creates default tiles with programmatic rendering.

#### `tileset:loadFromJSON(jsonPath)`
Loads tileset from JSON.
- **Returns**: boolean success

#### `tileset:getTilesByCategory(category)`
Gets all tiles in category.
- **Returns**: Array of tiles

---

## Dungeon Generator

Module: `dungeon.lua`

Generates procedural dungeon layouts.

### Constructor

#### `DungeonGenerator()`
Creates generator with grid-based room placement.

### Properties

```lua
generator.gridWidth, generator.gridHeight  -- Grid dimensions
generator.roomGrid                         -- 2D array of rooms
generator.roomTemplates                    -- Room size templates
```

### Room Structure

```lua
{
    gridX, gridY,        -- Grid position
    width, height,       -- Room dimensions
    type,                -- "start", "normal", "exit", "large"
    tiles,               -- 2D tile array
    doors,               -- Door array
    cleared = boolean    -- Completion status
}
```

### Methods

#### `generator:generate(roomCount)`
Generates dungeon with specified room count.
- **Returns**: Array of rooms

#### `generator:canPlaceRoom(x, y)`
Checks if room can be placed at grid position.
- **Returns**: boolean

#### `generator:createRoom(gridX, gridY, roomType)`
Creates room at grid position.
- **Returns**: Room object

#### `generator:generateRoomLayout(room)`
Generates tile layout for room.

#### `generator:connectRooms(room1, room2, direction)`
Connects two rooms with doors.

#### `generator:getRoomAt(gridX, gridY)`
Gets room at grid position.
- **Returns**: Room or nil

---

## UI

Module: `ui.lua`

Manages HUD and menus.

### Constructor

#### `UI(player, roomNumber)`
Creates UI bound to player.
- **Throws**: Error if player is nil

### Properties

```lua
ui.player       -- Player reference
ui.roomNumber   -- Current room/floor number
```

### Methods

#### `ui:draw()`
Draws HUD with player stats, HP bar, XP bar, and floor number.

#### `ui:drawMiniHealthBar(x, y, width)`
Draws small health bar.

#### `ui:drawMenu(menuType)`
Draws menu overlay.
- **Parameters**: `menuType` ("inventory", "stats")

#### `ui:drawInventory()`
Draws inventory menu.

#### `ui:drawStats()`
Draws stats menu.

---

## Usage Examples

### Creating Custom Enemy

```lua
local dragon = Enemy("Dragon", 10, "dragon_sprite")
dragon:setPosition(5, 5)

-- Or from template
local dragonTemplate = config.ENEMY_TEMPLATES.dragon
local dragon = Enemy.fromTemplate(dragonTemplate)
```

### Loading Custom Map

```lua
local map = Map(tileset)
map:loadFromJSON("data/custom_map.json")
```

### Using Utilities

```lua
-- Calculate distance
local dist = utils.distance(player.pixelX, player.pixelY, enemy.pixelX, enemy.pixelY)

-- Convert coordinates
local px, py = utils.tileToPixel(5, 3, config.TILE_SIZE)

-- Safe percentage
local healthPercent = utils.percentage(player.currentHP, player.maxHP)
```

---

For more examples and implementation details, see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) and [EXAMPLES.md](EXAMPLES.md).
