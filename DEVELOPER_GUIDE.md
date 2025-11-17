# Playdate RPG - Developer Guide

## Overview

This is a basic RPG game for the Playdate console, designed to be easily expandable. The game features:

- **Turn-based combat system**
- **Tile-based world exploration**
- **Character progression** (levels, XP, stats)
- **Random enemy encounters**
- **Modular architecture** for easy expansion

## Project Structure

```
source/
├── main.lua       # Main game loop and state management
├── player.lua     # Player character class
├── enemy.lua      # Enemy class and templates
├── map.lua        # Map generation and rendering
├── combat.lua     # Turn-based combat system
├── ui.lua         # UI and HUD rendering
└── pdxinfo        # Project metadata
```

## Game Systems

### 1. Player System (`player.lua`)

The player has the following stats:
- **Level**: Character level (starts at 1)
- **HP**: Health points (increases with level)
- **Attack**: Base attack power
- **Defense**: Damage reduction
- **XP**: Experience points for leveling up

**Expanding the Player:**
```lua
-- Add new stats
self.mana = 100
self.magic = 5

-- Add new methods
function Player:castSpell(spell)
    if self.mana >= spell.cost then
        self.mana = self.mana - spell.cost
        return spell.power
    end
    return 0
end
```

### 2. Enemy System (`enemy.lua`)

Enemies are created with a name and level. Stats scale automatically.

**Creating Custom Enemies:**
```lua
-- Method 1: Direct creation
local boss = Enemy("Dragon Boss", 5)
boss.maxHP = 100
boss.attack = 25

-- Method 2: Using templates
local goblinTemplate = {
    name = "Goblin",
    level = 2,
    maxHP = 15,
    attack = 7,
    defense = 2,
    xpReward = 30,
    goldReward = 10
}
local goblin = Enemy.fromTemplate(goblinTemplate)
```

### 3. Map System (`map.lua`)

The map uses a tile-based system with different terrain types:
- **Grass**: Walkable
- **Water**: Not walkable
- **Trees**: Not walkable
- **Rocks**: Not walkable

**Adding New Tile Types:**
```lua
-- In Map:init()
self.TILE_CAVE = 4

-- In Map:drawTile()
elseif tileType == self.TILE_CAVE then
    -- Draw cave entrance
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, self.tileSize, self.tileSize)
end

-- In Map:isWalkable()
if tile == self.TILE_CAVE then
    return true  -- or false, depending on your needs
end
```

### 4. Combat System (`combat.lua`)

Turn-based combat with a simple attack/run mechanic.

**Expanding Combat:**
```lua
-- Add magic attacks
function Combat:playerMagicAttack(spell)
    if self.player.mana >= spell.cost then
        local damage = spell.power
        local actualDamage = self.enemy:takeDamage(damage)
        self.player.mana = self.player.mana - spell.cost
        self:addLog("You cast " .. spell.name .. " for " .. actualDamage .. " damage!")
        return actualDamage > 0
    end
    return false
end

-- Add items
function Combat:useItem(item)
    if item.type == "healing" then
        self.player:heal(item.healAmount)
        self:addLog("You used " .. item.name .. "!")
    end
end
```

## Controls

### Exploration Mode
- **D-Pad**: Move character
- **A Button**: Interact (in combat: Attack)
- **B Button**: Menu (in combat: Run)

### Combat Mode
- **A Button**: Attack enemy
- **B Button**: Attempt to run

## How to Build

### Requirements
- Playdate SDK (download from https://play.date/dev/)

### Building
1. Install the Playdate SDK
2. Open terminal/command prompt
3. Navigate to the project root
4. Run: `pdc source BasicRPG.pdx`
5. The compiled game will be in `BasicRPG.pdx`

### Running
- **Simulator**: Drag `BasicRPG.pdx` onto the Playdate Simulator
- **Device**: Upload via USB or sideload with the Playdate website

## Expansion Ideas

### Easy Additions

1. **Add More Enemy Types**
   - Create enemy templates in `enemy.lua`
   - Add them to spawn logic in `main.lua`

2. **Create an Inventory System**
   - Expand the `Player.inventory` array
   - Add item pickup logic in exploration
   - Create item usage in combat

3. **Add Equipment System**
   - Already has `weapon` and `armor` fields
   - Create equipment items
   - Implement equip/unequip UI

4. **Create More Maps**
   - Save map layouts to files
   - Load different maps for different areas
   - Add transitions between maps

### Moderate Additions

1. **Add NPCs and Dialogue**
   - Create NPC class similar to Enemy
   - Add dialogue system
   - Implement quest tracking

2. **Create Shops**
   - Add shop locations to maps
   - Implement buy/sell system
   - Use existing `player.gold`

3. **Add Special Abilities**
   - Create skill/spell system
   - Add mana/resource management
   - Implement skill trees

4. **Save/Load System**
   - Use `playdate.datastore.write()`
   - Save player progress
   - Load saved games

### Advanced Additions

1. **Multiple Character Classes**
   - Warrior, Mage, Rogue variants
   - Different stat progressions
   - Class-specific abilities

2. **Story and Quest System**
   - Quest objectives
   - Branching storylines
   - Multiple endings

3. **Dungeon Generation**
   - Procedural dungeon layouts
   - Special rooms and treasures
   - Boss encounters

4. **Multiplayer/Social Features**
   - Score sharing
   - Challenge modes
   - Leaderboards

## Code Style Guidelines

- Use clear, descriptive variable names
- Comment complex logic
- Follow the existing class structure
- Keep systems modular and independent
- Test changes incrementally

## Debugging Tips

1. **Use print() statements** - They appear in the Playdate Simulator console
2. **Check the crash log** - Available in the Simulator menu
3. **Test on simulator first** - Faster iteration than device testing
4. **Watch the console** - Many errors are caught and logged

## Resources

- [Playdate SDK Documentation](https://sdk.play.date/)
- [Playdate Developer Forum](https://devforum.play.date/)
- [Lua Reference Manual](https://www.lua.org/manual/5.4/)

## License

This is a starter template - feel free to modify and distribute as you wish!

## Contributing

This is a personal project template, but improvements are welcome!
