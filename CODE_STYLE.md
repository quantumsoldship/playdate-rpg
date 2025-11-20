# Code Style Guide

This guide documents the coding conventions and best practices used in the Playdate RPG codebase.

## General Principles

1. **Configuration over Magic Numbers**: Use config constants instead of hardcoded values
2. **Validation First**: Validate inputs before processing
3. **Clear Error Messages**: Provide helpful error messages for debugging
4. **Reusable Utilities**: Use utility functions for common operations
5. **Documentation**: Comment complex logic and public APIs

## Module Structure

### Standard Module Template

```lua
-- Module Name
-- Brief description of module purpose

import "CoreLibs/object"
import "config"
import "utils"

local config = import "config"
local utils = import "utils"

class('ClassName').extends()

function ClassName:init()
    ClassName.super.init(self)
    
    -- Validate inputs if any
    -- Initialize instance variables
end

-- Public methods with clear documentation
-- Private helpers follow public methods
```

## Naming Conventions

### Variables
- **Local variables**: `camelCase` (e.g., `currentEnemy`, `playerHealth`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `TILE_SIZE`, `MAX_HEALTH`)
- **Instance variables**: `camelCase` (e.g., `self.pixelX`, `self.currentHP`)

### Functions
- **Public methods**: `camelCase` (e.g., `takeDamage()`, `isWalkable()`)
- **Private helpers**: `camelCase` (e.g., `checkCollision()`, `spawnEnemies()`)
- **Predicates**: Start with `is` or `has` (e.g., `isAlive()`, `hasItem()`)

### Files
- **Module files**: `lowercase.lua` (e.g., `player.lua`, `combat.lua`)
- **Utility files**: Descriptive names (e.g., `utils.lua`, `config.lua`)

## Configuration Values

### When to Add Config Constants

Add values to `config.lua` when they are:
1. Used in multiple places
2. Likely to be tweaked during balancing
3. Represent game mechanics (not implementation details)
4. Would benefit from being exposed to users

### Example
```lua
-- Good - in config.lua
config.PLAYER_SPEED = 2
config.ENEMY_ENCOUNTER_DISTANCE = 20

-- Usage
player.speed = config.PLAYER_SPEED
if distance < config.ENEMY_ENCOUNTER_DISTANCE then
    startCombat(enemy)
end
```

## Input Validation

### Validate All Public Method Inputs

```lua
function Player:takeDamage(damage)
    -- Validate input
    if not damage or damage < 0 then
        print("Warning: Invalid damage value: " .. tostring(damage))
        damage = 0
    end
    
    local actualDamage = math.max(config.MIN_DAMAGE, damage - self.defense)
    self.currentHP = math.max(0, self.currentHP - actualDamage)
    
    return actualDamage
end
```

### Nil Checks for Critical Objects

```lua
function checkCollision(pixelX, pixelY)
    if not player or not currentMap then
        return true -- Safe default
    end
    
    -- Proceed with collision check
end
```

## Using Utility Functions

### Prefer Utils Over Repetition

```lua
-- Good - uses utility
local distance = utils.distance(x1, y1, x2, y2)

-- Avoid - manual calculation
local dx = x2 - x1
local dy = y2 - y1
local distance = math.sqrt(dx * dx + dy * dy)
```

### Common Utility Patterns

```lua
-- Coordinate conversion
local pixelX, pixelY = utils.tileToPixel(tileX, tileY, config.TILE_SIZE)
local tileX, tileY = utils.pixelToTile(pixelX, pixelY, config.TILE_SIZE)

-- Safe percentage calculation
local healthPercent = utils.percentage(currentHP, maxHP)

-- Range checking
if utils.inRange(value, min, max) then
    -- Process value
end

-- Value clamping
local clampedValue = utils.clamp(value, min, max)
```

## Error Handling

### Informative Error Messages

```lua
-- Good - specific error message
if not player or not enemy then
    error("Combat requires both player and enemy")
end

-- Good - warning with context
if roomCount < 1 then
    print("Warning: Invalid room count, using default")
    roomCount = config.DUNGEON_ROOMS_PER_FLOOR
end
```

### Graceful Degradation

```lua
-- Check before use, provide fallback
if not currentRoomEnemies then
    return
end

-- Continue with safe operation
for i, enemy in ipairs(currentRoomEnemies) do
    -- Process enemy
end
```

## Documentation

### Function Documentation Template

```lua
-- Brief function description
-- @param paramName: Description and type
-- @param optionalParam: Description (optional)
-- @return: Description of return value(s)
function ClassName:methodName(paramName, optionalParam)
    -- Implementation
end
```

### Example
```lua
-- Define a tile with properties
-- @param id: Unique tile identifier (number)
-- @param properties: Table containing tile properties
--   - name: Display name (string)
--   - walkable: Whether player can walk on tile (boolean, default true)
--   - image: Image object or nil for programmatic drawing
-- @return: Nothing (modifies tileset in place)
function Tileset:defineTile(id, properties)
    -- Implementation
end
```

## Performance Considerations

### Minimize Calculations in Draw Loop

```lua
-- Good - calculate once
local screenCenterX = config.SCREEN_WIDTH / 2
local screenCenterY = config.SCREEN_HEIGHT / 2

function Player:draw()
    gfx.fillCircleAtPoint(screenCenterX, screenCenterY, 10)
end

-- Avoid - recalculating every frame
function Player:draw()
    gfx.fillCircleAtPoint(config.SCREEN_WIDTH / 2, config.SCREEN_HEIGHT / 2, 10)
end
```

### Cache Frequently Used Values

```lua
-- Good - cache at module level
local gfx <const> = playdate.graphics
local config = import "config"
local utils = import "utils"

-- Use cached references
function draw()
    gfx.clear()
    -- More drawing
end
```

## Testing Considerations

### Design for Testability

```lua
-- Good - easy to test in isolation
function calculateDamage(attack, defense)
    return math.max(config.MIN_DAMAGE, attack - defense)
end

-- Use in method
function Enemy:takeDamage(damage)
    local actualDamage = calculateDamage(damage, self.defense)
    self.currentHP = math.max(0, self.currentHP - actualDamage)
    return actualDamage
end
```

### Validate Assumptions

```lua
-- Add assertions for critical invariants
function Player:levelUp()
    self.level = self.level + 1
    assert(self.level > 0, "Player level must be positive")
    
    -- Continue with level up logic
end
```

## Common Patterns

### Percentage Bars

```lua
-- Standard percentage bar pattern
local percent = utils.percentage(current, max)
local barWidth = 100
local fillWidth = barWidth * percent

gfx.setColor(gfx.kColorBlack)
gfx.drawRect(x, y, barWidth, height)
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(x + 1, y + 1, barWidth - 2, height - 2)
gfx.setColor(gfx.kColorBlack)
gfx.fillRect(x + 1, y + 1, fillWidth - 2, height - 2)
```

### Iterating with Safety

```lua
-- Check collection exists
if not enemies or #enemies == 0 then
    return
end

-- Safe iteration with alive check
for i, enemy in ipairs(enemies) do
    if enemy and enemy:isAlive() then
        enemy:update()
    end
end
```

## Anti-Patterns to Avoid

### Don't Repeat Constants

```lua
-- Bad
if x < 0 or x > 400 or y < 0 or y > 240 then

-- Good
if x < 0 or x > config.SCREEN_WIDTH or y < 0 or y > config.SCREEN_HEIGHT then
```

### Don't Silent Fail

```lua
-- Bad
if not value then
    return
end

-- Good
if not value then
    print("Warning: Missing required value in function X")
    return
end
```

### Don't Assume Values Exist

```lua
-- Bad
local tile = map.tiles[y][x]

-- Good
local tile = nil
if map and map.tiles and map.tiles[y] then
    tile = map.tiles[y][x]
end
```

## Code Review Checklist

Before committing code, verify:

- [ ] All magic numbers moved to config or explained
- [ ] Input parameters validated
- [ ] Error messages are clear and helpful
- [ ] Common operations use utility functions
- [ ] Public methods have documentation comments
- [ ] Nil checks for objects that might not exist
- [ ] Performance considerations for draw/update loops
- [ ] Code follows project naming conventions
- [ ] No silent failures or ignored errors

---

Following these conventions ensures code is maintainable, robust, and easy for others to understand and extend.
