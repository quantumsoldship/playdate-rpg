-- Player class
-- Manages player stats, position, and progression

import "CoreLibs/object"

class('Player').extends()

function Player:init()
    Player.super.init(self)
    
    -- Position
    self.x = 0
    self.y = 0
    
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

-- Set player position
function Player:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Move player
function Player:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
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
    local tileSize = 16
    
    local drawX = screenWidth / 2 - tileSize / 2
    local drawY = screenHeight / 2 - tileSize / 2
    
    -- Draw player as a simple character
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(drawX + tileSize/2, drawY + tileSize/2, 6)
    
    -- Draw health bar above player
    local barWidth = 20
    local barHeight = 3
    local healthPercent = self.currentHP / self.maxHP
    
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(drawX - 2, drawY - 8, barWidth + 4, barHeight + 2)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(drawX, drawY - 6, barWidth, barHeight)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(drawX, drawY - 6, barWidth * healthPercent, barHeight)
end
