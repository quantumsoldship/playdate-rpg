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
    
    -- Position (pixel-based)
    self.x = 0  -- Tile position (for compatibility)
    self.y = 0
    self.pixelX = 0  -- Actual pixel position
    self.pixelY = 0
    
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
    self.pixelX = (x - 1) * 32 + 16
    self.pixelY = (y - 1) * 32 + 16
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
function Enemy:draw(playerPixelX, playerPixelY, tileSize)
    if not self:isAlive() then
        return
    end
    
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Calculate enemy position relative to player (pixel-based)
    local offsetX = (screenWidth / 2) - playerPixelX
    local offsetY = (screenHeight / 2) - playerPixelY
    
    local drawX = offsetX + self.pixelX
    local drawY = offsetY + self.pixelY
    
    -- Only draw if on screen
    if drawX >= -tileSize and drawX <= screenWidth and 
       drawY >= -tileSize and drawY <= screenHeight then
        
        -- Check if we have a custom sprite
        local sprite = self.spriteKey and Enemy.sprites[self.spriteKey]
        
        if sprite then
            -- Draw custom sprite centered
            sprite:draw(drawX - 16, drawY - 16)
        else
            -- Draw default enemy triangle
            gfx.setColor(gfx.kColorBlack)
            gfx.fillTriangle(
                drawX, drawY - 10,
                drawX - 10, drawY + 10,
                drawX + 10, drawY + 10
            )
        end
        
        -- Draw health bar above enemy
        local barWidth = 24
        local barHeight = 3
        local healthPercent = self.currentHP / math.max(1, self.maxHP)
        
        local barX = drawX - barWidth / 2
        local barY = drawY - 18
        
        -- Health bar border
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX, barY, barWidth, barHeight)
        
        -- Health bar background
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX + 1, barY + 1, barWidth - 2, barHeight - 2)
        
        -- Health bar fill
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX + 1, barY + 1, (barWidth - 2) * healthPercent, barHeight - 2)
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
