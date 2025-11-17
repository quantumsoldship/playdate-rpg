-- Enemy class
-- Manages enemy stats, AI, and behavior

import "CoreLibs/object"

class('Enemy').extends()

function Enemy:init(name, level)
    Enemy.super.init(self)
    
    -- Basic info
    self.name = name or "Enemy"
    self.level = level or 1
    
    -- Position
    self.x = 0
    self.y = 0
    
    -- Stats scaled by level
    self.maxHP = 10 + (level * 5)
    self.currentHP = self.maxHP
    self.attack = 3 + (level * 2)
    self.defense = 1 + level
    
    -- Rewards
    self.xpReward = 20 * level
    self.goldReward = 5 * level
end

-- Set enemy position
function Enemy:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Take damage
function Enemy:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.defense)
    self.currentHP = self.currentHP - actualDamage
    
    if self.currentHP < 0 then
        self.currentHP = 0
    end
    
    return actualDamage
end

-- Check if alive
function Enemy:isAlive()
    return self.currentHP > 0
end

-- Get attack power
function Enemy:getAttackPower()
    -- Add some randomness (80-120% of base)
    return math.floor(self.attack * (0.8 + math.random() * 0.4))
end

-- Draw enemy on map (relative to player position)
function Enemy:draw(playerX, playerY, tileSize)
    if not self:isAlive() then
        return
    end
    
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Calculate enemy position relative to player
    local offsetX = (screenWidth / 2) - (playerX * tileSize) + (tileSize / 2)
    local offsetY = (screenHeight / 2) - (playerY * tileSize) + (tileSize / 2)
    
    local drawX = offsetX + (self.x - 1) * tileSize
    local drawY = offsetY + (self.y - 1) * tileSize
    
    -- Only draw if on screen
    if drawX >= -tileSize and drawX <= screenWidth and 
       drawY >= -tileSize and drawY <= screenHeight then
        
        -- Draw enemy as a triangle
        gfx.setColor(gfx.kColorBlack)
        gfx.fillTriangle(
            drawX + tileSize/2, drawY + 2,
            drawX + 2, drawY + tileSize - 2,
            drawX + tileSize - 2, drawY + tileSize - 2
        )
    end
end

-- Create enemy from template (for easy expansion)
function Enemy.fromTemplate(template)
    local enemy = Enemy(template.name, template.level)
    
    if template.maxHP then enemy.maxHP = template.maxHP end
    if template.attack then enemy.attack = template.attack end
    if template.defense then enemy.defense = template.defense end
    if template.xpReward then enemy.xpReward = template.xpReward end
    if template.goldReward then enemy.goldReward = template.goldReward end
    
    enemy.currentHP = enemy.maxHP
    
    return enemy
end
