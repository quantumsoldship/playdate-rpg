-- Enemy class
-- Manages enemy stats, AI, and behavior

import "CoreLibs/object"
import "CoreLibs/graphics"

class('Enemy').extends()

-- Static sprite registry
Enemy.sprites = {}

function Enemy:init(name, level, spriteKey)
    Enemy.super.init(self)
    
    -- Basic info
    self.name = name or "Enemy"
    self.level = level or 1
    self.spriteKey = spriteKey -- Key to look up custom sprite
    
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

-- Load a sprite for an enemy type
function Enemy.loadSprite(spriteKey, imagePath)
    local gfx <const> = playdate.graphics
    local image = gfx.image.new(imagePath)
    
    if image then
        Enemy.sprites[spriteKey] = image
        print("Loaded enemy sprite: " .. spriteKey)
        return true
    else
        print("Failed to load enemy sprite: " .. imagePath)
        return false
    end
end

-- Load all enemy sprites from a JSON configuration
function Enemy.loadSpritesFromJSON(jsonPath)
    local json = playdate.file.readJSON(jsonPath)
    
    if not json or not json.enemies then
        print("Error: Could not load enemy sprites from " .. jsonPath)
        return false
    end
    
    for _, enemyData in ipairs(json.enemies) do
        if enemyData.spriteKey and enemyData.image then
            Enemy.loadSprite(enemyData.spriteKey, enemyData.image)
        end
    end
    
    return true
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
        
        -- Check if we have a custom sprite
        local sprite = self.spriteKey and Enemy.sprites[self.spriteKey]
        
        if sprite then
            -- Draw custom sprite
            sprite:draw(drawX, drawY)
        else
            -- Draw default enemy triangle
            gfx.setColor(gfx.kColorBlack)
            gfx.fillTriangle(
                drawX + tileSize/2, drawY + 4,
                drawX + 4, drawY + tileSize - 4,
                drawX + tileSize - 4, drawY + tileSize - 4
            )
        end
        
        -- Draw health bar
        local barWidth = 24
        local barHeight = 3
        local healthPercent = self.currentHP / self.maxHP
        
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(drawX + 4, drawY - 5, barWidth, barHeight)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(drawX + 5, drawY - 4, barWidth - 2, barHeight - 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(drawX + 5, drawY - 4, (barWidth - 2) * healthPercent, barHeight - 2)
    end
end

-- Create enemy from template (for easy expansion)
function Enemy.fromTemplate(template)
    local enemy = Enemy(template.name, template.level, template.spriteKey)
    
    if template.maxHP then enemy.maxHP = template.maxHP end
    if template.attack then enemy.attack = template.attack end
    if template.defense then enemy.defense = template.defense end
    if template.xpReward then enemy.xpReward = template.xpReward end
    if template.goldReward then enemy.goldReward = template.goldReward end
    
    enemy.currentHP = enemy.maxHP
    
    return enemy
end
