-- Combat class
-- Manages turn-based combat system

import "CoreLibs/object"
import "CoreLibs/graphics"

class('Combat').extends()

function Combat:init(player, enemy)
    Combat.super.init(self)
    
    self.player = player
    self.enemy = enemy
    
    -- Combat log
    self.log = {}
    self.maxLogLines = 8
    
    -- Rewards
    self.rewardXP = enemy.xpReward
    self.rewardGold = enemy.goldReward
    
    self:addLog("Combat started with " .. enemy.name .. "!")
    self:addLog("Enemy Level: " .. enemy.level .. " HP: " .. enemy.currentHP)
end

-- Add message to combat log
function Combat:addLog(message)
    table.insert(self.log, message)
    
    -- Keep only last N messages
    while #self.log > self.maxLogLines do
        table.remove(self.log, 1)
    end
end

-- Player attacks
function Combat:playerAttack()
    local damage = self.player:getAttackPower()
    local actualDamage = self.enemy:takeDamage(damage)
    
    self:addLog("You attack for " .. actualDamage .. " damage!")
    
    if not self.enemy:isAlive() then
        self:addLog(self.enemy.name .. " defeated!")
        return "victory"
    end
    
    return "continue"
end

-- Enemy attacks
function Combat:enemyAttack()
    local damage = self.enemy:getAttackPower()
    local actualDamage = self.player:takeDamage(damage)
    
    self:addLog(self.enemy.name .. " attacks for " .. actualDamage .. " damage!")
    
    if not self.player:isAlive() then
        self:addLog("You have been defeated!")
        return "defeat"
    end
    
    return "continue"
end

-- Draw combat screen
function Combat:draw()
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Draw background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, screenWidth, screenHeight)
    
    -- Draw border
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(8, 8, screenWidth - 16, screenHeight - 16)
    gfx.drawRect(10, 10, screenWidth - 20, screenHeight - 20)
    
    -- Draw title (centered)
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    local titleText = "* COMBAT *"
    local titleWidth = gfx.getTextSize(titleText)
    gfx.drawText(titleText, (screenWidth - titleWidth) / 2, 20)
    
    -- Draw player section (left side)
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    local leftX = 30
    gfx.drawText("YOU", leftX, 50)
    gfx.drawText("HP: " .. self.player.currentHP .. "/" .. self.player.maxHP, leftX, 66)
    gfx.drawText("ATK: " .. self.player.attack, leftX, 82)
    gfx.drawText("DEF: " .. self.player.defense, leftX, 98)
    
    -- Draw player sprite (aligned)
    gfx.fillCircleAtPoint(leftX + 40, 135, 18)
    
    -- Draw enemy section (right side, aligned)
    local rightX = screenWidth - 150
    gfx.drawText(self.enemy.name, rightX, 50)
    gfx.drawText("HP: " .. self.enemy.currentHP .. "/" .. self.enemy.maxHP, rightX, 66)
    gfx.drawText("LVL: " .. self.enemy.level, rightX, 82)
    
    -- Draw enemy sprite (aligned)
    gfx.fillTriangle(
        rightX + 50, 110,
        rightX + 30, 150,
        rightX + 70, 150
    )
    
    -- Draw health bars (properly aligned)
    self:drawHealthBar(leftX, 120, 100, self.player.currentHP, self.player.maxHP)
    self:drawHealthBar(rightX, 120, 100, self.enemy.currentHP, self.enemy.maxHP)
    
    -- Draw combat log (bottom section, well-aligned)
    gfx.drawRect(20, 165, screenWidth - 40, 50)
    local logY = 170
    for i = math.max(1, #self.log - 3), #self.log do
        gfx.drawText(self.log[i], 25, logY)
        logY = logY + 12
    end
    
    -- Draw controls (centered at bottom)
    local controlText = "A: Attack  B: Run"
    local controlWidth = gfx.getTextSize(controlText)
    gfx.drawText(controlText, (screenWidth - controlWidth) / 2, screenHeight - 20)
end

-- Draw health bar
function Combat:drawHealthBar(x, y, width, current, max)
    local gfx <const> = playdate.graphics
    local height = 10
    local percent = math.max(0, math.min(1, current / max))
    
    -- Border (double line for better visibility)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, width, height)
    gfx.drawRect(x + 1, y + 1, width - 2, height - 2)
    
    -- Background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x + 2, y + 2, width - 4, height - 4)
    
    -- Health (filled portion)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x + 2, y + 2, (width - 4) * percent, height - 4)
end
