-- Player class
-- Manages player stats, position, and progression

import "CoreLibs/object"

class('Player').extends()

function Player:init()
    Player.super.init(self)
    
    -- Position (pixel-based, not tile-based)
    self.x = 0
    self.y = 0
    self.pixelX = 0  -- Actual pixel position
    self.pixelY = 0
    
    -- Movement
    self.speed = 2  -- Pixels per frame
    self.size = 16  -- Player collision size
    
    -- Stats
    self.level = 1
    self.xp = 0
    self.xpToNextLevel = 100
    self.maxHP = 20
    self.currentHP = 20
    self.attack = 5
    self.defense = 2
    
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
    self.x = math.floor(x / 32) + 1
    self.y = math.floor(y / 32) + 1
end

-- Set player tile position (converts to pixels)
function Player:setTilePosition(tileX, tileY)
    self.x = tileX
    self.y = tileY
    self.pixelX = (tileX - 1) * 32 + 16
    self.pixelY = (tileY - 1) * 32 + 16
end

-- Move player (pixel-based)
function Player:movePixels(dx, dy)
    self.pixelX = self.pixelX + dx
    self.pixelY = self.pixelY + dy
    
    -- Update tile position
    self.x = math.floor(self.pixelX / 32) + 1
    self.y = math.floor(self.pixelY / 32) + 1
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
    local actualDamage = math.max(1, damage - self.defense)
    self.currentHP = self.currentHP - actualDamage
    
    if self.currentHP < 0 then
        self.currentHP = 0
    end
    
    return actualDamage
end

-- Heal
function Player:heal(amount)
    self.currentHP = math.min(self.maxHP, self.currentHP + amount)
end

-- Check if alive
function Player:isAlive()
    return self.currentHP > 0
end

-- Gain XP
function Player:gainXP(amount)
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
    
    -- Increase stats
    self.maxHP = self.maxHP + 5
    self.currentHP = self.maxHP -- Full heal on level up
    self.attack = self.attack + 2
    self.defense = self.defense + 1
    
    -- Increase XP needed for next level
    self.xpToNextLevel = math.floor(self.xpToNextLevel * 1.5)
    
    print("Level Up! Now level " .. self.level)
end

-- Get attack power
function Player:getAttackPower()
    local basePower = self.attack
    
    -- Add weapon bonus if equipped
    if self.weapon then
        basePower = basePower + self.weapon.attackBonus
    end
    
    -- Add some randomness (80-120% of base)
    return math.floor(basePower * (0.8 + math.random() * 0.4))
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
    local screenWidth = 400
    local screenHeight = 240
    
    -- Draw at screen center
    local drawX = screenWidth / 2
    local drawY = screenHeight / 2
    
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
    local healthPercent = self.currentHP / math.max(1, self.maxHP)
    
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
