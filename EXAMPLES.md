# Expansion Examples

This file contains practical examples of how to expand the basic RPG game.

## Example 1: Adding a New Enemy Type

### Step 1: Add to config.lua
```lua
config.ENEMY_TEMPLATES = {
    -- ... existing enemies ...
    
    skeleton = {
        name = "Skeleton",
        level = 3,
        maxHP = 22,
        attack = 10,
        defense = 3,
        xpReward = 55,
        goldReward = 15
    }
}
```

### Step 2: Spawn the enemy in main.lua
```lua
-- In spawnEnemies() or anywhere you want
local skeleton = Enemy.fromTemplate(config.ENEMY_TEMPLATES.skeleton)
skeleton:setPosition(10, 10)
table.insert(enemies, skeleton)
```

## Example 2: Creating a Shop System

### Step 1: Create shop.lua
```lua
import "CoreLibs/object"

class('Shop').extends()

function Shop:init()
    Shop.super.init(self)
    self.inventory = {
        Item.fromTemplate(config.ITEM_TEMPLATES.potion),
        Item.fromTemplate(config.ITEM_TEMPLATES.sword),
        Item.fromTemplate(config.ITEM_TEMPLATES.shield)
    }
end

function Shop:buy(player, itemIndex)
    local item = self.inventory[itemIndex]
    if player.gold >= item.price then
        player.gold = player.gold - item.price
        player:addItem(item)
        return true
    end
    return false
end
```

### Step 2: Add shop to map
```lua
-- In map.lua
self.TILE_SHOP = 5

-- Make shops walkable and trigger shop UI
function Map:isWalkable(x, y)
    -- ... existing code ...
    if tile == self.TILE_SHOP then
        return true
    end
end
```

## Example 3: Adding Magic System

### Step 1: Add to player.lua
```lua
function Player:init()
    -- ... existing code ...
    self.mana = 50
    self.maxMana = 50
    self.magic = 5
    self.spells = {}
end

function Player:learnSpell(spell)
    table.insert(self.spells, spell)
end

function Player:castSpell(spell, target)
    if self.mana >= spell.cost then
        self.mana = self.mana - spell.cost
        local damage = self.magic + spell.power
        return target:takeDamage(damage)
    end
    return 0
end
```

### Step 2: Create spell system
```lua
-- spells.lua
local Spells = {
    fireball = {
        name = "Fireball",
        cost = 10,
        power = 15,
        description = "A ball of fire"
    },
    
    heal = {
        name = "Heal",
        cost = 15,
        power = 20,
        description = "Restore health"
    }
}

return Spells
```

## Example 4: Quest System

### Step 1: Create quest.lua
```lua
import "CoreLibs/object"

class('Quest').extends()

function Quest:init(title, description)
    Quest.super.init(self)
    self.title = title
    self.description = description
    self.objectives = {}
    self.completed = false
    self.rewards = {}
end

function Quest:addObjective(objective)
    table.insert(self.objectives, {
        text = objective,
        completed = false
    })
end

function Quest:completeObjective(index)
    if self.objectives[index] then
        self.objectives[index].completed = true
        
        -- Check if all objectives complete
        local allComplete = true
        for _, obj in ipairs(self.objectives) do
            if not obj.completed then
                allComplete = false
                break
            end
        end
        
        if allComplete then
            self.completed = true
        end
    end
end
```

### Step 2: Add quest tracking to player
```lua
function Player:init()
    -- ... existing code ...
    self.activeQuests = {}
    self.completedQuests = {}
end

function Player:acceptQuest(quest)
    table.insert(self.activeQuests, quest)
end

function Player:completeQuest(quest)
    for i, q in ipairs(self.activeQuests) do
        if q == quest then
            table.remove(self.activeQuests, i)
            table.insert(self.completedQuests, quest)
            
            -- Give rewards
            if quest.rewards.xp then
                self:gainXP(quest.rewards.xp)
            end
            if quest.rewards.gold then
                self.gold = self.gold + quest.rewards.gold
            end
            
            break
        end
    end
end
```

## Example 5: NPC and Dialogue System

### Step 1: Create npc.lua
```lua
import "CoreLibs/object"

class('NPC').extends()

function NPC:init(name, dialogue)
    NPC.super.init(self)
    self.name = name
    self.dialogue = dialogue or {}
    self.x = 0
    self.y = 0
    self.currentDialogue = 1
end

function NPC:setPosition(x, y)
    self.x = x
    self.y = y
end

function NPC:talk()
    local message = self.dialogue[self.currentDialogue]
    
    -- Advance dialogue
    self.currentDialogue = self.currentDialogue + 1
    if self.currentDialogue > #self.dialogue then
        self.currentDialogue = 1
    end
    
    return message
end
```

### Step 2: Create dialogue UI
```lua
-- In ui.lua
function UI:drawDialogue(npcName, message)
    local gfx <const> = playdate.graphics
    
    -- Draw dialogue box
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(20, 160, 360, 60)
    
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(20, 160, 360, 60)
    
    -- Draw NPC name
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    gfx.drawText(npcName, 30, 165)
    
    -- Draw message
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    gfx.drawText(message, 30, 185)
end
```

## Example 6: Save/Load System

```lua
-- In main.lua or a separate save.lua file

function saveGame(player, currentMap)
    local saveData = {
        player = {
            x = player.x,
            y = player.y,
            level = player.level,
            xp = player.xp,
            currentHP = player.currentHP,
            maxHP = player.maxHP,
            attack = player.attack,
            defense = player.defense,
            gold = player.gold,
            inventory = player.inventory
        },
        map = {
            width = currentMap.width,
            height = currentMap.height,
            tiles = currentMap.tiles
        }
    }
    
    playdate.datastore.write(saveData, "savegame")
end

function loadGame()
    local saveData = playdate.datastore.read("savegame")
    
    if saveData then
        -- Restore player
        player = Player()
        player.x = saveData.player.x
        player.y = saveData.player.y
        player.level = saveData.player.level
        -- ... restore all other fields
        
        -- Restore map
        currentMap = Map()
        currentMap.width = saveData.map.width
        currentMap.height = saveData.map.height
        currentMap.tiles = saveData.map.tiles
        
        return true
    end
    
    return false
end
```

## Example 7: Custom Map Layouts

```lua
-- In map.lua
function Map:loadFromString(mapString, width, height)
    self.width = width
    self.height = height
    self.tiles = {}
    
    local index = 1
    for y = 1, height do
        self.tiles[y] = {}
        for x = 1, width do
            local char = mapString:sub(index, index)
            
            if char == '.' then
                self.tiles[y][x] = self.TILE_GRASS
            elseif char == '#' then
                self.tiles[y][x] = self.TILE_ROCK
            elseif char == 'W' then
                self.tiles[y][x] = self.TILE_WATER
            elseif char == 'T' then
                self.tiles[y][x] = self.TILE_TREE
            end
            
            index = index + 1
        end
    end
end

-- Usage:
local customMap = [[
####################
#..................#
#...T..T.....W.....#
#.................##
#....T............##
##...............###
##.....W.....W..####
###...........#####
####################
]]

currentMap:loadFromString(customMap, 20, 9)
```

## Example 8: Status Effects

```lua
-- In player.lua and enemy.lua
function Player:init()
    -- ... existing code ...
    self.statusEffects = {}
end

function Player:addStatusEffect(effect, duration)
    table.insert(self.statusEffects, {
        name = effect,
        duration = duration
    })
end

function Player:updateStatusEffects()
    for i = #self.statusEffects, 1, -1 do
        local effect = self.statusEffects[i]
        
        -- Apply effect
        if effect.name == "poison" then
            self:takeDamage(2)
        elseif effect.name == "regen" then
            self:heal(3)
        end
        
        -- Decrease duration
        effect.duration = effect.duration - 1
        if effect.duration <= 0 then
            table.remove(self.statusEffects, i)
        end
    end
end
```

These examples should give you a solid foundation for expanding the game in any direction you want!
