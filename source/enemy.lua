-- Enemy class
-- Manages enemy stats, AI, and behavior

import "CoreLibs/object"
import "CoreLibs/graphics"
import "config"
import "utils"

local config = import "config"
local utils = import "utils"

class('Enemy').extends()

-- Static sprite registry
Enemy.sprites = {}

function Enemy:init(name, level, spriteKey)
    Enemy.super.init(self)
    
    -- Basic info
    self.name = name or "Enemy"
    self.level = math.max(1, level or 1)  -- Ensure level is at least 1
    self.spriteKey = spriteKey -- Key to look up custom sprite
    
    -- Position (pixel-based)
    self.x = 0  -- Tile position (for compatibility)
    self.y = 0
    self.pixelX = 0  -- Actual pixel position
    self.pixelY = 0
    
    -- Stats scaled by level
    self.maxHP = 10 + (self.level * 5)
    self.currentHP = self.maxHP
    self.attack = 3 + (self.level * 2)
    self.defense = 1 + self.level
    
    -- Rewards
    self.xpReward = 20 * self.level
    self.goldReward = 5 * self.level
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
    self.pixelX, self.pixelY = utils.tileToPixel(x, y, config.TILE_SIZE)
end

-- Take damage
function Enemy:takeDamage(damage)
    -- Validate input
    if not damage or damage < 0 then
        print("Warning: Invalid damage value: " .. tostring(damage))
        damage = 0
    end
    
    local actualDamage = math.max(config.MIN_DAMAGE, damage - self.defense)
    self.currentHP = math.max(0, self.currentHP - actualDamage)
    
    return actualDamage
end

-- Check if alive
function Enemy:isAlive()
    return self.currentHP > 0
end

-- Get attack power
function Enemy:getAttackPower()
    -- Apply damage variance using utility function
    return utils.applyDamageVariance(self.attack, config.DAMAGE_VARIANCE)
end

-- Draw enemy on map (relative to player position)
function Enemy:draw(playerPixelX, playerPixelY, tileSize)
    if not self:isAlive() then
        return
    end
    
    local gfx <const> = playdate.graphics
    
    -- Calculate enemy position relative to player (pixel-based)
    local offsetX = (config.SCREEN_WIDTH / 2) - playerPixelX
    local offsetY = (config.SCREEN_HEIGHT / 2) - playerPixelY
    
    local drawX = offsetX + self.pixelX
    local drawY = offsetY + self.pixelY
    
    -- Only draw if on screen (with margin for partial visibility)
    if not utils.inRange(drawX, -config.OFFSCREEN_MARGIN, config.SCREEN_WIDTH + config.OFFSCREEN_MARGIN) or
       not utils.inRange(drawY, -config.OFFSCREEN_MARGIN, config.SCREEN_HEIGHT + config.OFFSCREEN_MARGIN) then
        return
    end
    
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
    local healthPercent = utils.percentage(self.currentHP, self.maxHP)
    
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
