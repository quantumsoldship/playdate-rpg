-- Player class
-- Manages player stats, position, and progression

import "CoreLibs/object"
import "config"
import "utils"

local config = import "config"
local utils = import "utils"

class('Player').extends()

function Player:init()
    Player.super.init(self)
    
    -- Position (pixel-based, not tile-based)
    self.x = 0
    self.y = 0
    self.pixelX = 0  -- Actual pixel position
    self.pixelY = 0
    
    -- Movement (use config values)
    self.speed = config.PLAYER_SPEED
    self.size = config.PLAYER_SIZE
    
    -- Stats (use config values where available)
    self.level = config.PLAYER_START_LEVEL
    self.xp = 0
    self.xpToNextLevel = config.PLAYER_XP_TO_LEVEL
    self.maxHP = config.PLAYER_START_HP
    self.currentHP = config.PLAYER_START_HP
    self.attack = config.PLAYER_START_ATTACK
    self.defense = config.PLAYER_START_DEFENSE
    
    -- Inventory (expandable)
    self.inventory = {}
    self.gold = 0
    
    -- Equipment (expandable)
    self.weapon = nil
    self.armor = nil
end

-- Set player position (in pixels)
function Player:setPosition(x, y)
    self.pixelX = x
    self.pixelY = y
    -- Update tile position for compatibility
    self.x, self.y = utils.pixelToTile(x, y, config.TILE_SIZE)
end

-- Set player tile position (converts to pixels)
function Player:setTilePosition(tileX, tileY)
    self.x = tileX
    self.y = tileY
    self.pixelX, self.pixelY = utils.tileToPixel(tileX, tileY, config.TILE_SIZE)
end

-- Move player (pixel-based)
function Player:movePixels(dx, dy)
    self.pixelX = self.pixelX + dx
    self.pixelY = self.pixelY + dy
    
    -- Update tile position
    self.x, self.y = utils.pixelToTile(self.pixelX, self.pixelY, config.TILE_SIZE)
end

-- Get collision bounds
function Player:getBounds()
    return {
        x = self.pixelX - self.size / 2,
        y = self.pixelY - self.size / 2,
        width = self.size,
        height = self.size
    }
end

-- Take damage
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

-- Heal
function Player:heal(amount)
    -- Validate input
    if not amount or amount < 0 then
        print("Warning: Invalid heal amount: " .. tostring(amount))
        return
    end
    
    self.currentHP = math.min(self.maxHP, self.currentHP + amount)
end

-- Check if alive
function Player:isAlive()
    return self.currentHP > 0
end

-- Gain XP
function Player:gainXP(amount)
    -- Validate input
    if not amount or amount < 0 then
        print("Warning: Invalid XP amount: " .. tostring(amount))
        return
    end
    
    self.xp = self.xp + amount
    
    -- Check for level up
    while self.xp >= self.xpToNextLevel do
        self:levelUp()
    end
end

-- Level up
function Player:levelUp()
    self.level = self.level + 1
    self.xp = self.xp - self.xpToNextLevel
    
    -- Increase stats (use config values)
    self.maxHP = self.maxHP + config.LEVEL_UP_HP_BONUS
    self.currentHP = self.maxHP -- Full heal on level up
    self.attack = self.attack + config.LEVEL_UP_ATTACK_BONUS
    self.defense = self.defense + config.LEVEL_UP_DEFENSE_BONUS
    
    -- Increase XP needed for next level
    self.xpToNextLevel = math.floor(self.xpToNextLevel * config.LEVEL_UP_XP_MULTIPLIER)
    
    print("Level Up! Now level " .. self.level)
end

-- Get attack power
function Player:getAttackPower()
    local basePower = self.attack
    
    -- Add weapon bonus if equipped
    if self.weapon and self.weapon.attackBonus then
        basePower = basePower + self.weapon.attackBonus
    end
    
    -- Apply damage variance using utility function
    return utils.applyDamageVariance(basePower, config.DAMAGE_VARIANCE)
end

-- Add item to inventory
function Player:addItem(item)
    table.insert(self.inventory, item)
end

-- Equip weapon
function Player:equipWeapon(weapon)
    self.weapon = weapon
end

-- Equip armor
function Player:equipArmor(armor)
    self.armor = armor
    if armor then
        self.defense = 2 + armor.defenseBonus
    else
        self.defense = 2
    end
end

-- Draw player (center of screen)
function Player:draw()
    local gfx <const> = playdate.graphics
    
    -- Draw at screen center
    local drawX = config.SCREEN_WIDTH / 2
    local drawY = config.SCREEN_HEIGHT / 2
    
    -- Draw character (circle with border)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(drawX, drawY, 11)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(drawX, drawY, 9)
    
    -- Add eyes
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(drawX - 3, drawY - 2, 2)
    gfx.fillCircleAtPoint(drawX + 3, drawY - 2, 2)
    
    -- Add smile
    gfx.drawLine(drawX - 4, drawY + 3, drawX + 4, drawY + 3)
    
    -- Draw health bar above player
    local barWidth = 28
    local barHeight = 4
    local healthPercent = utils.percentage(self.currentHP, self.maxHP)
    
    local barX = drawX - barWidth / 2
    local barY = drawY - 18
    
    -- Health bar shadow
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)
    
    -- Health bar background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(barX, barY, barWidth, barHeight)
    
    -- Health bar fill (black for filled portion)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(barX, barY, barWidth * healthPercent, barHeight)
end
